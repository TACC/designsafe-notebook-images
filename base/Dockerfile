# The notebooks (NB) group (G) and user (U) information.
ARG AGAVE_GID=816877
ARG AGAVE_GNAME=G-${AGAVE_GID}
ARG NB_USER=jupyter
ARG NB_UID=458981
ARG HOME=/home/${NB_USER}

# Use jupyter/base-notebook image see:
# https://github.com/jupyter/docker-stacks/tree/master/base-notebook
FROM jupyter/base-notebook:latest

# Image metadata.
LABEL image_name="jpvantasel/ds-nb-img:base-0.1.0-rc.0"
LABEL maintainer="Joseph P. Vantassel <jvantassel@tacc.utexas.edu>"

USER root

# Recall ARGs after they go out of scope folling build stage (i.e., FROM).
ARG AGAVE_GID
ARG AGAVE_GNAME
ARG NB_USER
ARG NB_UID
ARG HOME

# Configure enviroment
ENV NB_GID=${AGAVE_GID} \
    NB_GROUP=${AGAVE_GNAME} \
    NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    HOME=${HOME}

# Add jupyter user
# Adapted from image by Joe S: https://github.com/TACC/jupyterhub_images/blob/master/designsafe/Dockerfile
RUN groupadd --gid ${AGAVE_GID} ${AGAVE_GNAME} && \
    adduser --uid ${NB_UID} --ingroup ${AGAVE_GNAME} --home ${HOME} --shell /bin/bash ${NB_USER}

WORKDIR ${HOME}

USER ${NB_USER}

WORKDIR ${HOME}

USER root

# Install bare essentials to make the image usable.
# This list is kept short on purpose to keep the image light and portable.
# Future packages should be added only if they are deemed essential for the community.
# Following best practices apt-get-related commands should not be split.
RUN apt-get update \
 && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    emacs-nox \
    vim-tiny \
    nano \
    jed \
    unzip \
    git \
    inkscape \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# The notebook is run by the TACC userid, not jupyter,
# so permissions need to be open
# TODO (jpv): Prevent blind application of permission.
RUN chown -R ${NB_USER}:${NB_GROUP} ${HOME} && \
	chmod 777 ${HOME} && \
	find ${HOME} -type f -exec chmod 666 {} \; && \
	find ${HOME} -type d -exec chmod 777 {} \;

RUN touch ${HOME}/.hushlogin

COPY requirements.txt ${HOME}/requirements.txt

RUN python -m pip install -r ${HOME}/requirements.txt --no-cache-dir && \
    python -m pip freeze > ${HOME}/pip_freeze.txt

# Cannot delete default user jovyan.
# If jovyan is deleted container will not run.
# Why this is the case is unclear.
# RUN userdel -rf jovyan

# Instead delete jovyan's home directory.
#RUN rm -rf home/jovyan

# Always terinate with user (i.e., non-root) permissions.
USER ${NB_USER}