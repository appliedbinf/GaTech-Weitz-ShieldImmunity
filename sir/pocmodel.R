#function with the three options, core, soft, hard
#Then do the ode 
#that's it

#Main function (calls following functions)
SIR_shield = function(t,y0,shield="core",pars){
    if (shield=="core"){
        y = ode(y0, t, sir_shield_core, pars)
        y = as.data.frame(y, stringsAsFactors = F) #arrange data
        
    } else if (shield=="hard"){
        y = ode(y0, t, sir_shield_hard, pars)
        y = as.data.frame(y, stringsAsFactors = F) #arrange data
        
    } else if (shield=="soft"){
        y = ode(y0, t, sir_shield_soft, pars)
        y = as.data.frame(y, stringsAsFactors = F) #arrange data
        
    }
    
    return(y)
    
}

#Core shield equations
sir_shield_core = function(t,y,pars){
    with(as.list(pars),{
        # SIR Model
        S = y[1]
        I = y[2]
        R = y[3]
        # The model
        dSdt = -pars$beta*S*I/(S+I+(1+pars$alpha)*R)
        dIdt = pars$beta*S*I/(S+I+(1+pars$alpha)*R)-pars$gamma*I
        dRdt = pars$gamma*I
        
        dydt = list(c(dSdt, dIdt, dRdt))
        
        return(dydt)})}

#Hard shield
sir_shield_hard = function(t,y,pars){
    with(as.list(pars),{
        # SIR Model
        S = y[1]
        I = y[2]
        R = y[3]
        # The model
        dSdt = -pars$beta*S*I*(1-(1+pars$alpha)*R)^2/(1-R)^2
        dIdt = pars$beta*S*I*(1-(1+pars$alpha)*R)^2/(1-R)^2-pars$gamma*I
        dRdt = pars$gamma*I
        
        dydt = list(c(dSdt, dIdt, dRdt))
        
        return(dydt)})}

#Soft shield
sir_shield_soft = function(t,y,pars){
    with(as.list(pars),{
        # SIR Model
        S = y[1]
        I = y[2]
        R = y[3]
        # The model
        dSdt = -pars$beta*S*I/((1+pars$alpha*R)^2)
        dIdt = pars$beta*S*I/((1+pars$alpha*R)^2)-pars$gamma*I
        dRdt = pars$gamma*I
        
        dydt = list(c(dSdt, dIdt, dRdt))
        
        return(dydt)})}


#The following loop calls the functions for the CORE shielding with different alpha values
# y=data.frame()
# for(alpha in pars$alpha_range){
#     pars['alpha']=alpha
#     y_curr = SIR_shield(t,y0,shield="core",pars)
#     y_curr = cbind(y_curr,alpha=rep(pars$alpha,length(t)))
#     y=rbind(y,y_curr)
# }
# 
# ggplot(data=y,aes(time,I,group=alpha,color=alpha)) + 
#     geom_line() + 
#     xlab("Time (days)") + 
#     ylab("Fraction Infected") 
