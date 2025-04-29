FROM python:3.12.10-slim

USER root

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/jupyter \
    NB_USER=jupyter \
    NB_UID=458981 \
    NB_PREFIX=/ \
    NGL_DB_USER="dspublic" \
    NGL_DB_PASSWORD="R3ad0nlY" \ 
    NGL_DB_HOST="129.114.52.174" \
    NGL_DB_PORT=3306 \
    NB_GID=816877 \
    NB_GNAME=G-${NB_GID} \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VERSION=1.8.4

# Create user and home directory
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    groupadd --gid ${NB_GID} ${NB_GNAME}

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    r-base \
    r-base-dev \
    libzmq3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${HOME}

COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# Install R kernel
RUN R -e "install.packages('IRkernel', repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

RUN pip uninstall agavepy --yes

# Install Julia kernel
RUN apt-get update && apt-get install -y --no-install-recommends wget

ENV JULIA_VERSION=1.10.2

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    tar zxf julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    mv julia-${JULIA_VERSION} .julia && \
    export PATH="$PATH:/${HOME}/.julia/bin" && \
    echo 'using Pkg; Pkg.add("IJulia");' > install_script.jl && \
    julia install_script.jl && \
    rm install_script.jl && \
    rm julia-${JULIA_VERSION}-linux-x86_64.tar.gz

# Install MATLAB Kernel
ARG MATLAB_RELEASE=r2023a
ARG MATLAB_PRODUCT_LIST="MATLAB"
ARG MATLAB_DEPS_REQUIREMENTS_FILE="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE}/ubuntu20.04/base-dependencies.txt"
ARG MATLAB_DEPS_REQUIREMENTS_FILE_NAME="matlab-deps-${MATLAB_RELEASE}-base-dependencies.txt"

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget ${MATLAB_DEPS_REQUIREMENTS_FILE} -O ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} \
    && export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && xargs -a ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME} -r apt-get install --no-install-recommends -y \
    unzip \
    xvfb \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* ${MATLAB_DEPS_REQUIREMENTS_FILE_NAME}

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=/opt/matlab \
    --products ${MATLAB_PRODUCT_LIST} && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab

RUN pip install kernelutility
RUN mkdir /opt/conda
RUN mkdir /opt/R

RUN chown -R ${NB_USER}:${NB_GROUP} ${HOME} && \
	chmod 777 ${HOME} && \
	find ${HOME} -type f -exec chmod 666 {} \; && \
	find ${HOME} -type d -exec chmod 777 {} \; && \
    chmod -R a+rwx $HOME/.julia && \
    chmod -R a+rwx /opt/R && \
    chmod -R a+rwx /opt/conda

# Switch to the user
USER $NB_USER

# Set the entrypoint for JupyterHub
# CMD ["poetry", "run", "jupyterhub-singleuser"]