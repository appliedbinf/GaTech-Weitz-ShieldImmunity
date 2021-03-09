FROM rocker/shiny-verse

MAINTAINER Aroon Chande "achande@ihrc.com, mail@aroonchande.com"

RUN apt update && apt install gnupg -y

RUN echo "deb http://security.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9D6D8F6BC857C906 
RUN apt-get update && apt-get upgrade -y

RUN apt-get update && apt-get install -y \
    sudo \
    cron \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 \
    sqlite3 \
    locales \
    git \
    vim-tiny \
    less \
    wget \
    fonts-texgyre \
    texinfo \
    locales \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    python3-pip


RUN locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN R -e 'packages = c("shiny", "tidyverse", \
    "shinyWidgets", "waiter", "cowplot", \
    "deSolve", "reshape2", "remotes", \
    "leaflet", "leaflet.extras", "RCurl", \
    "sf"); \
    install.packages(packages); \
    remotes::install_github("JohnCoene/echarts4r.suite")'
