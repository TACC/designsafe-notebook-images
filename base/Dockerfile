FROM jupyter/scipy-notebook

USER root

# Jupyter GIDs
ARG AGAVE_GID=816877
ARG AGAVE_GNAME=G-${AGAVE_GID}
# start_notebook.sh looks for these values
ENV NB_USER=jupyter \
    NB_GID=${AGAVE_GNAME} \
    NB_GROUP=${AGAVE_GNAME}
   # SHELL=/bin/bash

RUN groupadd --gid ${AGAVE_GID} ${AGAVE_GNAME} && \
    useradd --uid 458981 --gid ${AGAVE_GNAME} -m --home /home/${NB_USER} --shell /bin/bash ${NB_USER}
# While not ideal, this is required since the users that are injected
# into the container do not exist.
#ENV HOME=/home/${NB_USER} \
#    USER=${NB_USER} \
#    LC_ALL=en_US.UTF-8 \
 #   LANG=en_US.UTF-8 \
#    LANGUAGE=en_US.UTF-8

RUN apt-get update && apt-get install -yq --no-install-recommends \
    build-essential \
    emacs-nox \
    vim-tiny \
    git \
    inkscape \
    jed \
    libsm6 \
    libxext-dev \
    libxrender1 \
    lmodern \
    netcat \
    python-dev \
    # ---- nbconvert dependencies ----
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    # ----
    tzdata \
    unzip \
    nano \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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

RUN apt update
RUN apt install -y libgl1-mesa-glx

RUN pip install numpy==1.19.1
RUN pip install scipy==1.5.2
RUN pip install agavepy==1.0.0a10
RUN pip install matplotlib==3.3.1
RUN pip install pandas==1.1.2
RUN pip install itk==5.1.1
RUN pip install itkwidgets==0.32.0
RUN pip install vtk
RUN pip install adcircpy==1.0.12
RUN pip install openseespy==3.3.0.1.1

RUN apt-get -y update && apt-get install -y dvipng texlive-latex-extra texlive-fonts-recommended

RUN pip install git+https://github.com/Kitware/ipyparaview.git \
 && jupyter nbextension enable --py --sys-prefix ipyparaview

RUN chown jupyter /home/jovyan

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
RUN echo "Welcome to the DesignSafe-ci JupyterHub terminal. Your DesignSafe-ci home directory is in 'mydata.' Any files you wish to save between sessions must be within that directory. OpenSees is availavble to run interactively here. " > /home/jupyter/README.txt
RUN echo "0949f6ce05b1" > /home/jupyter/.imageID
COPY rbnb.jar /home/jupyter/util/rbnb.jar

COPY actors.py /opt/conda/lib/python3.6/site-packages/agavepy


USER jupyter

# examples
RUN mkdir -p /home/jupyter/util
ADD agavepy_example.ipynb /home/jupyter/util/agavepy_example.ipynb
ADD opensees-submit-example.ipynb /home/jupyter/util/opensees-submit-example.ipynb