FROM ubuntu:20.04

USER root

# cmd line arguments
ARG AGAVE_GID=816877
ARG AGAVE_GNAME=G-${AGAVE_GID}

# set for start_notebook.sh
# TODO (jpv): Check if still use start_notebook.sh
ENV NB_USER=jupyter \
    NB_GID=${AGAVE_GNAME} \
    NB_GROUP=${AGAVE_GNAME}

# create group -> use provided (or default) gid and gname
RUN groupadd --gid ${AGAVE_GID} ${AGAVE_GNAME}

# create user -> provide user id; add to gid; make home dir; set default shell; provide user name
RUN useradd --uid 458981 --gid ${AGAVE_GNAME} -m --home /home/${NB_USER} --shell /bin/bash ${NB_USER}

RUN apt-get update
RUN apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    emacs-nox \
    vim-tiny \
    nano \
    unzip \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    libgl1-mesa-glx \
    lmodern \
    netcat \
    # ---- nbconvert dependencies ----
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    # ----
    tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get install software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update
RUN apt-get install python3.9

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

RUN pip install -r /home/jupyter/requirements.txt

# RUN pip freeze > /home/jupyter/current_reqs.txt

# RUN apt-get -y update && apt-get install -y dvipng texlive-latex-extra texlive-fonts-recommended

# RUN pip install git+https://github.com/Kitware/ipyparaview.git \
#  && jupyter nbextension enable --py --sys-prefix ipyparaview

# RUN chown jupyter /home/jovyan

RUN mkdir /home/jupyter/projects && \
    mkdir /home/jupyter/mydata && \
    mkdir /home/jupyter/community && \
    mkdir /home/jupyter/public && \
    mkdir /home/jupyter/public/nees

RUN ln -s /home/jupyter/MyProjects /home/jupyter/projects
RUN ln -s /home/jupyter/MyData /home/jupyter/mydata
RUN ln -s /home/jupyter/CommunityData /home/jupyter/community
RUN ln -s /home/jupyter/NEES /home/jupyter/public/nees

# startx and README
RUN startx &
# RUN echo "Welcome to the DesignSafe-ci JupyterHub terminal. Your DesignSafe-ci home directory is in 'mydata.' Any files you wish to save between sessions must be within that directory. OpenSees is availavble to run interactively here. " > /home/jupyter/README.txt
# RUN echo "0949f6ce05b1" > /home/jupyter/.imageID
# COPY rbnb.jar /home/jupyter/util/rbnb.jar

# COPY actors.py /opt/conda/lib/python3.6/site-packages/agavepy

USER jupyter

# # examples
# RUN mkdir -p /home/jupyter/util
# ADD agavepy_example.ipynb /home/jupyter/util/agavepy_example.ipynb
# ADD opensees-submit-example.ipynb /home/jupyter/util/opensees-submit-example.ipynb