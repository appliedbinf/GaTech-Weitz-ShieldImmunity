# rm(list=ls())

# (0) About ---------------------------------------------------------------

# 03.30.2020
# Conan Zhao
# czhao98 AT gatech DOT edu
# 08.10.2020
# Aroon Chande
# achande@ihrc.com
#
# This is the R version of the Weitz Shield Immunity model
# found at https://github.com/WeitzGroup/covid_shield_immunity

# Model Parms: use ODE45
#            : reltol=1e-8
#            : maxstep=0.1


stir_model_youngshields_v2 = function(t, y, combpars) {
    # usage: dydt = stir_model_youngshields(t,y,pars,agepars)
    # S-E-Ia-Is-R model with I_s further broken down to I_ha I_hs D
    # There are 8 categories in total, all age-stratified
    with(as.list(c(y, combpars)), {
        
        # Assign things
        dydt     = rep(0, length(y));             # concatenated vector of all variables
        Ia       = sum(y[agepars$Ia_ids]);        # Infected, Asymptomatic
        Is       = sum(y[agepars$Is_ids]);        # Infected, Symptomatic
        R        = sum(y[agepars$R_ids]);         # Recovered
        S        = sum(y[agepars$S_ids]);         # Symptomatic
        E        = sum(y[agepars$E_ids]);         # Exposed
        Rshields = sum(y[agepars$R_ids[3:6]])     # Recovered Shields
        Ntot     = S+E+Ia+Is+R;                   # Total # of individuals
        
        dydt[agepars$S_ids]=-pars$beta_asym*y[agepars$S_ids]*Ia/(Ntot+pars$alpha*Rshields)-pars$beta_sym*y[agepars$S_ids]*Is/(Ntot+pars$alpha*Rshields)+agepars$ageleave*y[agepars$Slock_ids];
        dydt[agepars$E_ids]=pars$beta_asym*y[agepars$S_ids]*Ia/(Ntot+pars$alpha*Rshields)+pars$beta_sym*y[agepars$S_ids]*Is/(Ntot+pars$alpha*Rshields)-pars$gamma_e*y[agepars$E_ids];
        dydt[agepars$Ia_ids]=pars$p*pars$gamma_e*y[agepars$E_ids]-pars$gamma_asym*y[agepars$Ia_ids];
        dydt[agepars$Is_ids]=(rep(1,length(pars$p))-pars$p)*pars$gamma_e*y[agepars$E_ids]-pars$gamma_sym*y[agepars$Is_ids];
        dydt[agepars$Ihsub_ids]=agepars$hosp_frac*(1-agepars$hosp_crit)*pars$gamma_sym*y[agepars$Is_ids]-pars$gamma_h*y[agepars$Ihsub_ids];
        dydt[agepars$Ihcri_ids]=agepars$hosp_frac*agepars$hosp_crit*pars$gamma_sym*y[agepars$Is_ids]-pars$gamma_h*y[agepars$Ihcri_ids];
        dydt[agepars$R_ids]=pars$gamma_asym*y[agepars$Ia_ids]+pars$gamma_sym*y[agepars$Is_ids]*(1-agepars$hosp_frac)+pars$gamma_h*y[agepars$Ihsub_ids]+pars$gamma_h*y[agepars$Ihcri_ids]*(1-agepars$crit_die);
        dydt[agepars$D_ids]=pars$gamma_h*y[agepars$Ihcri_ids]*agepars$crit_die;
        dydt[agepars$Slock_ids]=-agepars$ageleave*y[agepars$Slock_ids];
        
        return(list(dydt))
    })
}

run_core_model = function(outbreak_in = outbreak
                          , pars_in = pars
                          , agepars_in = agepars
                          , population_in = population){
    # Runs figbaseline_youngshields_v2 core model
    # Returns (list): 
    #     y     model out
    #     t     time vector
    #     stats summary model statistics
    
    # Set up Baseline
    pars_baseline = pars_in
    pars_baseline$alpha = 0
    
    # Run Baseline Model
    times_baseline=0:outbreak_in$pTime
    model_out = ode(outbreak_in$y0, times_baseline, stir_model_youngshields_v2, c(pars_baseline, agepars_in), rtol=1e-8, hmax=0.1, method='ode45')
    y_baseline = model_out[,-1]
    t_baseline = model_out[,1]
    
    # Back-solve for when <shield_threshold> individuals exposed and begin shielding
    t_shield = min(which((1-rowSums(y_baseline[,agepars_in$S_ids]))*population_in$N > outbreak_in$shield_threshold))-1 # -1 due to 0-indexing
    
    # Use new starting point for intervention models
    outbreak_shields = outbreak_in
    outbreak_shields$y0=y_baseline[t_shield+1,] # new initial condition
    
    times = 0:outbreak$pTime
    
    # Run Shielding Model
    model_out = ode(outbreak_shields$y0, times, stir_model_youngshields_v2, c(pars_in, agepars_in), rtol=1e-8, hmax=0.1, method='ode45')
    y = model_out[,-1]
    t = model_out[,1]
    
    
    # Stats
    stats=list()
    stats$R=y[,agepars_in$R_ids];
    stats$D=y[,agepars_in$D_ids];
    stats$Htot=y[,agepars_in$Ihsub_ids]+y[,agepars_in$Ihcri_ids];
    stats$Hacu=y[,agepars_in$Ihcri_ids];
    stats$Dday_age=stats$D[2:(nrow(stats$D)),]-stats$D[1:(nrow(stats$D)-1),];
    stats$Dday=rowSums(stats$Dday_age);
    stats$Hacu_day=rowSums(stats$Hacu);
    stats$lock=y[,agepars_in$Slock_ids];
    
    return(list('y' = y, 't' = t, 'stats' = stats))
}





