# Use jupyter/base-notebook image see:
# https://github.com/jupyter/docker-stacks/tree/master/base-notebook
FROM jupyter/base-notebook:latest

# Image metadata.
ENV IMAGE_NAME="ds-nb-img:base-0.1.0-rc.6"
LABEL image_name="jpvantassel/${IMAGE_NAME}"
LABEL image_name_alt="taccsciapps/${IMAGE_NAME}"
LABEL maintainer="Joseph P. Vantassel <jvantassel@tacc.utexas.edu>"

USER root

ENV AGAVE_GID=816877
ENV AGAVE_GNAME=G-${AGAVE_GID}
ENV NB_USER=jupyter
ENV NB_UID=458981
ENV HOME=/home/${NB_USER}

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
 && apt-get upgrade \
 && apt-get clean \
 && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    emacs-nox \
    vim-tiny \
    nano \
    jed \
    unzip \
    git \
    inkscape \
    openssh-client \
 && apt-get clean

RUN touch ${HOME}/.hushlogin

# Install Julia kernel.
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.1-linux-x86_64.tar.gz \
 && tar zxf julia-1.7.1-linux-x86_64.tar.gz \
 && mv julia-1.7.1 .julia \
 && export PATH="$PATH:/$HOME/.julia/bin" \
 && echo 'using Pkg; Pkg.add("IJulia");' > install_script.jl \
 && julia install_script.jl \
 && rm install_script.jl \
 && rm julia-1.7.1-linux-x86_64.tar.gz

# Install R kernel from pre-built binary.
RUN apt-get update \
 && apt-get install --yes --quiet --no-install-recommends \
    curl \
    gdebi-core \
 && export R_VERSION=4.0.5 \
 && curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb \
 && gdebi --non-interactive --quiet r-${R_VERSION}_1_amd64.deb\
 && /opt/R/${R_VERSION}/bin/R --version \
 && ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R \
 && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript \
 && apt-get install --yes --quiet --no-install-recommends \
    libzmq3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    jupyter-core \
    jupyter-client \
 && echo "install.packages(c('repr', 'IRdisplay', 'IRkernel'), type = 'source', repos = 'http://cran.us.r-project.org');IRkernel::installspec(user = FALSE)" > install_script.r \
 && Rscript install_script.r \
 && jupyter labextension install @techrah/text-shortcuts \
 && rm install_script.r \
 && rm r-4.0.5_1_amd64.deb

# Python requirements.
COPY requirements.txt ${HOME}/.python/requirements.txt
RUN conda install -y nb_conda_kernels && \
    python -m pip install -r ${HOME}/.python/requirements.txt --no-cache-dir && \
    python -m pip freeze > ${HOME}/.python/pip_freeze.txt && \
    jupyter kernelspec uninstall python3 -y

COPY jupyter_notebook_config.py ${HOME}/.jupyter/jupyter_notebook_config.py

# The notebook is run by the TACC userid, not jupyter,
# so permissions need to be open
# TODO (jpv): Prevent blind application of permission.
RUN chown -R ${NB_USER}:${NB_GROUP} ${HOME} && \
	 chmod 777 ${HOME} && \
	 find ${HOME} -type f -exec chmod 666 {} \; && \
	 find ${HOME} -type d -exec chmod 777 {} \; && \
    chmod -R a+rwx $HOME/.julia && \
    chmod -R a+rwx /opt/R && \
    chmod -R a+rwx /opt/conda

# Directory containing user's projects is current named `projects`.
# Rename to be consistent with DesignSafe interface.
RUN mv projects MyProjects

# Cannot delete default user jovyan.
# If jovyan is deleted container will not run.
# Why this is the case is unclear.
# RUN userdel -rf jovyan

# Instead delete jovyan's home directory.
#RUN rm -rf home/jovyan

# Always terinate with user (i.e., non-root) permissions.
USER ${NB_USER}