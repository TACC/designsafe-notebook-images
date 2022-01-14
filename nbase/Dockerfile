# Use jupyter/base-notebook image see:
# https://github.com/jupyter/docker-stacks/tree/master/base-notebook
FROM jupyter/base-notebook

# Image metadata.
LABEL image_name="jpvantasel/ds-nb-img:nbase-0.1.0rc0"
LABEL maintainer="Joseph P. Vantassel <jpvantassel@tacc.utexas.edu>"

USER root

RUN apt-get update

# The notebooks (NB) group (G) and user (U) information.
ARG AGAVE_GID=816877
ARG AGAVE_GNAME=G-${AGAVE_GID}
ENV NB_USER="jupyter"
ENV NB_UID="558981"
ENV NB_GID=${AGAVE_GID}
ENV NB_GROUP=${AGAVE_GNAME}

# Add jupyter user
# Adapted from image by Joe S: https://github.com/TACC/jupyterhub_images/blob/master/designsafe/Dockerfile
RUN groupadd --gid ${AGAVE_GID} ${AGAVE_GNAME} && \
    adduser --uid ${NB_UID} --ingroup ${AGAVE_GNAME} --home /home/${NB_USER} --shell /bin/bash ${NB_USER}
    
# Cannot delete default user jovyan.
# If jovyan is deleted container will not run.
# Why this is the case is unclear.
    # userdel -r jovyan

USER ${NB_USER}
ENV HOME /home/${NB_USER}
# ENV SHELL /bin/bash
# ENV USER ${NB_USER}

USER root

WORKDIR /home/${NB_USER}/

# Install bare essentials to make the image usable.
# This list is kept short on purpose to keep the image light and portable.
# Future packages should be added only if they are deemed essential for the community.
RUN apt-get install --yes --quiet --no-install-recommends \
   build-essential \
   emacs-nox \
   vim-tiny \
   nano \
   jed \
   unzip \
   git \
   inkscape

# from apt-get man: "Clears out the local repository of retrieved package files."
RUN apt-get clean

# The notebook is run by the TACC userid, not jupyter,
# so permissions need to be open
# TODO (jpv): Prevent blind application of permission.
RUN chown -R ${NB_USER}:${NB_GROUP} /home/${NB_USER} && \
	chmod 777 /home/${NB_USER} && \
	find /home/${NB_USER} -type f -exec chmod 666 {} \; && \
	find /home/${NB_USER} -type d -exec chmod 777 {} \;

RUN touch /home/${NB_USER}/.hushlogin

ADD requirements.txt /home/${NB_USER}/requirements.txt

RUN python -m pip install -r /home/${NB_USER}/requirements.txt --no-cache-dir && \
    python -m pip freeze > /home/${NB_USER}/pip_freeze.txt

# broken PermissionError: [Errno 13] Permission denied: '/home/jovyan/.local'
# RUN chown jupyter /home/jovyan

# broken PermissionError: [Errno 13] Permission denied: '/home/jovyan/.local'
# RUN chown -R jupyter:${NB_GROUP} /home/jovyan/

# this was sucessful but started me in /home/jovyan not /home/jupyter
# RUN chown -R jupyter:${NB_GROUP} /home/jovyan && \
#     chmod 777 /home/jovyan/

# RUN chown jupyter /home/jovyan

# # Add directories to be mounted.
# RUN mkdir -p /home/jupyter/.mnt/projects && \
#     mkdir -p /home/jupyter/.mnt/mydata && \
#     mkdir -p /home/jupyter/.mnt/community && \
#     mkdir -p /home/jupyter/.mnt/public && \
#     mkdir -p /home/jupyter/.mnt/public/nees

# # Symlink directories above to preferred names.
# RUN ln -s /home/jupyter/MyProjects /home/jupyter/.mnt/projects
# RUN ln -s /home/jupyter/MyData /home/jupyter/.mnt/mydata
# RUN ln -s /home/jupyter/CommunityData /home/jupyter/.mnt/community
# RUN ln -s /home/jupyter/NEES /home/jupyter/.mnt/public/nees

# startx and README
# RUN startx &
# RUN echo "Welcome to the DesignSafe-CI JupyterHub. Your DesignSafe-CI home directory is in 'MyData'. Any files you wish to save between sessions must be within that directory." > /home/jupyter/README.txt
# RUN echo "0949f6ce05b1" > /home/jupyter/.imageID

# RUN chown jupyter /home/jupyter

# USER jupyter

# ENV HOME /home/jupyter
# ENV SHELL /bin/bash
# ENV USER jupyter

# RUN chown -R ${NB_USER}:${AGAVE_GNAME} /home/${NB_USER}
# RUN chown -R jupyter: /home/jupyter/util

# Always terinate with user (i.e., non-root) permissions.
USER ${NB_USER}
