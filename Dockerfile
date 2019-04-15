# Copyright (c) lapotok
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

ARG TEST_ONLY_BUILD

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    'rpy2=2.9*' \
    'r-base=3.5.1' \
    'r-irkernel=0.8*' \
    'r-plyr=1.8*' \
    'r-devtools=1.13*' \
    'r-tidyverse=1.2*' \
    'r-shiny=1.2*' \
    'r-rmarkdown=1.11*' \
    'r-forecast=8.2*' \
    'r-rsqlite=2.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=1.0*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'r-htmltools=0.3*' \
    'r-sparklyr=0.9*' \
    'r-htmlwidgets=1.2*' \
    'r-hexbin=1.27*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN MRAN=https://mran.microsoft.com/snapshot/2019-04-15 \
#  && echo MRAN=$MRAN >> /etc/environment \
  && export MRAN=$MRAN \
  ## MRAN becomes default only in versioned images
  ## Use littler installation scripts
  && Rscript -e "install.packages(c('littler', 'docopt'), repo = '$MRAN')" \
  && ln -s /opt/conda/lib/R/library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s /opt/conda/lib/R/library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s /opt/conda/lib/R/library/littler/bin/r /usr/local/bin/r \
  ## TEMPORARY WORKAROUND to get more robust error handling for install2.r prior to littler update
  && wget -O /usr/local/bin/install2.r https://raw.githubusercontent.com/eddelbuettel/littler/master/inst/examples/install2.r
  && chmod +x /usr/local/bin/install2.r
