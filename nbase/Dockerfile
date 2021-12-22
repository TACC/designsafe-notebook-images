FROM jupyter/base-notebook

USER root

# Jupyter GIDs
ARG AGAVE_GID=816877
ARG AGAVE_GNAME=G-${AGAVE_GID}
# start_notebook.sh looks for these values
ENV NB_USER=jupyter \
    NB_GID=${AGAVE_GNAME} \
    NB_GROUP=${AGAVE_GNAME}

RUN groupadd --gid ${AGAVE_GID} ${AGAVE_GNAME} && \
    useradd --uid 458981 --gid ${AGAVE_GNAME} -m --home /home/${NB_USER} --shell /bin/bash ${NB_USER}

RUN apt-get update
#RUN apt-get install --yes --quiet --no-install-recommends \
#    build-essential \
#    emacs-nox \
#    vim-tiny \
#    nano \
#    jed \
#    unzip \
#    git \
#    inkscape

#RUN apt-get install --yes --quiet --no-install-recommends \
#    libsm6 \
#    libxext-dev \
#    libxrender1 \
#    libgl1-mesa-glx \
#    lmodern \
#    netcat

#RUN apt-get install --yes --quiet --no-install-recommends \
#    # ---- nbconvert depesndencies ----
#    texlive-xetex \
#    texlive-fonts-recommended \
#    texlive-plain-generic \
#   # ----
#    # tzdata # possibly took a very long time
#    dvipng \
#    texlive-latex-extra \
#    texlive-fonts-recommended

###############################################
# Persistent local jupyter kernels
###############################################
# $LOCAL_ENVS/tmnt/bin/python -m ipykernel install --prefix $JUPYTER_WORK --name tmnt --display-name "tmnt python"
#  *Must use full path*
# refresh main jupyter to load the new kernel option
#ENV JUPYTER_PATH=/home/jupyter/mydata/jupyter_packages/share/jupyter:$JUPYTER_PATH
#ENV JUPYTER_WORK=/home/jupyter/mydata/jupyter_packages
###############################################
# Permissions
###############################################
# The notebook is run by the TACC userid, not jupyter,
# so permissions need to be open
RUN chown -R jupyter:${NB_GROUP} /home/jupyter && \
	chmod 777 /home/jupyter && \
	find /home/jupyter -type f -exec chmod 666 {} \; && \
	find /home/jupyter -type d -exec chmod 777 {} \;
##################################################################
# Turn off errors from login since gid does not exist in container
##################################################################
RUN touch /home/jupyter/.hushlogin

ADD requirements.txt /home/jupyter/requirements.txt

RUN python -m pip install -r /home/jupyter/requirements.txt

RUN python -m pip freeze > /home/jupyter/pip_freeze.txt

# RUN chown jupyter /home/jovyan

# RUN mkdir /home/jupyter/projects && \
#     mkdir /home/jupyter/mydata && \
#     mkdir /home/jupyter/community && \
#     mkdir /home/jupyter/public && \
#     mkdir /home/jupyter/public/nees

# RUN ln -s /home/jupyter/MyProjects /home/jupyter/projects
# RUN ln -s /home/jupyter/MyData /home/jupyter/mydata
# RUN ln -s /home/jupyter/CommunityData /home/jupyter/community
# RUN ln -s /home/jupyter/NEES /home/jupyter/public/nees

RUN mkdir /home/jupyter/MyProjects && \
    mkdir /home/jupyter/MyData && \
    mkdir /home/jupyter/CommunityData && \
    mkdir /home/jupyter/NEES

# startx and README
RUN startx &
RUN echo "Welcome to the DesignSafe-CI JupyterHub. Your DesignSafe-CI home directory is in 'MyData'. Any files you wish to save between sessions must be within that directory." > /home/jupyter/README.txt
RUN echo "0949f6ce05b1" > /home/jupyter/.imageID

USER jupyter