FROM ubuntu:latest

# Install fortran dependencies
# Inspiration taken from [https://github.com/modern-fortran/modern-fortran-docker]
RUN apt update -y
RUN apt install -yq git curl make cmake gfortran libcoarrays-dev libopenmpi-dev libcoarrays-openmpi-dev libcaf-openmpi-3
# Vim to edit files from witihn the container
RUN apt install -yq vim

# For CPU / memory stress testing [https://manpages.debian.org/testing/stress/stress.1.en.html]
RUN apt -y install stress

ENV ALF_HOME=/alf
# These variables silence the complaints from running mpifort as root
ENV OMPI_ALLOW_RUN_AS_ROOT=1
ENV OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

## Copy alf source code into the container
RUN mkdir -p /alf
COPY . /alf
	
# Compile, and create directory for the results
RUN cd /alf/src && make
RUN mkdir -p /alfresults

WORKDIR "/alf"
