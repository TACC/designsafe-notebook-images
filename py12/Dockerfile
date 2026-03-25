# 24.04 ships with Python 3.12
ARG UBUNTU_VERSION=24.04

FROM quay.io/jupyter/base-notebook:ubuntu-${UBUNTU_VERSION} AS base1

USER root



# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/jupyter \
    NB_USER=jupyter \
    NB_UID=458981 \
    NB_PREFIX=/ \
    NGL_DB_USER="dspublic" \
    NGL_DB_PASSWORD="" \ 
    NGL_DB_HOST="129.114.52.174" \
    NGL_DB_PORT=3306 \
    NB_GID=816877 \
    NB_GNAME=G-${NB_GID} \
    POETRY_HOME=/opt/poetry \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_VERSION=1.8.4 \
    MPI_DIR=/opt/ompi

# Create user and home directory
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    groupadd --gid ${NB_GID} ${NB_GNAME}

# Install dependencies (include Node.js for keplergl build)
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
    wget \
    gnupg \
    lsb-release \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb && \
    apt install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb && \
    apt-get update && \
    apt-get install -y \
    cmake \
    libarrow-dev \
    libparquet-dev && \
    rm ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb

WORKDIR ${HOME}

# Ensure setuptools is installed first (provides pkg_resources)
RUN pip install --upgrade pip setuptools wheel
RUN apt-get install python3-setuptools

RUN pip install "Cython>=0.29.34"

COPY requirements.txt .
RUN pip install -r requirements.txt && \
    rm requirements.txt

RUN pip install --no-cache-dir keplergl || echo "keplergl skipped"


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
ARG MATLAB_RELEASE=R2024b
ARG MATLAB_PRODUCT_LIST="MATLAB"
ARG MATLAB_INSTALL_LOCATION="/opt/matlab"
ARG UBUNTU_VERSION=24.04

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ARG MATLAB_DEPS_URL="https://raw.githubusercontent.com/mathworks-ref-arch/container-images/main/matlab-deps/${MATLAB_RELEASE}/ubuntu${UBUNTU_VERSION}/base-dependencies.txt"
ARG MATLAB_DEPENDENCIES="matlab-deps-${MATLAB_RELEASE}-base-dependencies.txt"
ARG ADDITIONAL_PACKAGES="wget curl unzip ca-certificates xvfb git vim"
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install --no-install-recommends -y ${ADDITIONAL_PACKAGES}\
    && wget $(echo ${MATLAB_DEPS_URL} | tr "[:upper:]" "[:lower:]") -O ${MATLAB_DEPENDENCIES} \
    && xargs -a ${MATLAB_DEPENDENCIES} -r apt-get install --no-install-recommends -y \
    && apt-get clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* ${MATLAB_DEPENDENCIES}

RUN curl -fsSL https://www.mathworks.com/mpm/glnxa64/mpm -o mpm && \
    chmod +x mpm && \
    ./mpm install --release=${MATLAB_RELEASE} --destination=${MATLAB_INSTALL_LOCATION} \
    --products ${MATLAB_PRODUCT_LIST} \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s ${MATLAB_INSTALL_LOCATION}/bin/matlab /usr/local/bin/matlab

RUN MATLAB_VERSION=$(cat ${MATLAB_INSTALL_LOCATION}/VersionInfo.xml | grep -oP '(\d{2}\.\d{1})') && \
    env LD_LIBRARY_PATH=${MATLAB_INSTALL_LOCATION}/bin/glnxa64 python -m pip install -U matlabengine==${MATLAB_VERSION}.* || \
    echo "Failed to install MATLAB Engine for Python... skipping ..."

RUN python -m pip install -U jupyter-matlab-proxy

RUN pip install matlab_kernel && \
    python -m matlab_kernel install --user

#### Try to get MPI working
RUN apt-get -q update \
    && apt-get install -y \
    python3 python3-dev python3-pip \
    gcc gfortran binutils \
    && pip3 install --upgrade pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.bz2 .
RUN tar xf openmpi-3.1.4.tar.bz2 \
    && cd openmpi-3.1.4 \
    && ./configure --prefix=${MPI_DIR} \
    && make -j4 all \
    && make install \
    && cd .. && rm -rf \
    openmpi-3.1.4 openmpi-3.1.4.tar.bz2 /tmp/*

RUN apt update \
    && apt-get install -y libopenmpi-dev

RUN pip3 install --user -U setuptools \
    && pip3 install --user mpi4py

WORKDIR ${HOME}

RUN mkdir /opt/R

# OpenSees Executable
RUN pip install openseespy
COPY --from=taccaci/opensees:latest /usr/local/bin/OpenSees /usr/local/bin/OpenSees
COPY --from=taccaci/opensees:latest /usr/local/bin/OpenSeesSP /usr/local/bin/OpenSeesSP
COPY --from=taccaci/opensees:latest /usr/local/bin/OpenSeesMP /usr/local/bin/OpenSeesMP

COPY --from=taccaci/opensees:latest /usr/local/lib/tcl8.6 /usr/local/lib/tcl8.6

# Add SQLite3, PyMySQL, and SQLAlchemy
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libsqlite3-dev \
    sqlite3 \
    libmariadb-dev \
    libscalapack-openmpi-dev \
    && pip install --no-cache-dir PyMySQL \
    && cd /usr/lib/x86_64-linux-gnu/ \
    && ln -s libscalapack-openmpi.so.2.2.1 libscalapack-openmpi.so.2.1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:$LD_LIBRARY_PATH 
RUN pip install --no-cache-dir SQLAlchemy

RUN apt-get update && \
    apt-get install -y --no-install-recommends texlive-full && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Fix permissions
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
# CMD ["jupyterhub-singleuser"]