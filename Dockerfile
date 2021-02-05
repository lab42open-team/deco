FROM ubuntu:18.04 
MAINTAINER Savvas Paragkamian s.paragkamian@hcmr.gr

# Basic ubuntu tools
RUN apt-get update && apt-get install -y wget \
    && apt-get install -qq -y curl

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update

# R dependencies
RUN apt-get remove -y r-base-core

RUN apt-get install -y gfortran
RUN apt-get install -y build-essential
RUN apt-get install -y fort77
RUN apt-get install -y xorg-dev
RUN apt-get install -y liblzma-dev libblas-dev gfortran
RUN apt-get install -y gcc-multilib
RUN apt-get install -y gobjc++
RUN apt-get install -y aptitude
RUN aptitude install -y libreadline-dev
RUN apt-get update
RUN apt-get install -y libbz2-dev

RUN export CC=/usr/bin/gcc
RUN export CXX=/usr/bin/g++
RUN export FC=/usr/bin/gfortran
RUN export PERL=/usr/bin/perl

RUN apt-get update
RUN apt-get install -y libpcre3-dev libpcre2-dev libpcre-ocaml-dev libghc-regex-pcre-dev
RUN apt-get install -y libcurl4-openssl-dev

# Install R
WORKDIR /home
RUN wget https://ftp.cc.uoc.gr/mirrors/CRAN/src/base/R-4/R-4.0.3.tar.gz
RUN tar -xf R-4.0.3.tar.gz
WORKDIR /home/R-4.0.3
RUN ./configure 
RUN make
RUN make install
RUN Rscript -e 'install.packages("tidyverse", repos="https://cran.rstudio.com")'

# Ghostscript

#RUN mkdir -p /installs
#RUN cd /installs && wget http://downloads.ghostscript.com/public/binaries/ghostscript-9.53.3-linux-x86_64.tgz
#RUN cd /installs && tar -xvf ghostscript-9.53.3-linux-x86_64.tgz
#
#ENV PATH /installs/ghostscript-9.53.3-linux-x86_64:$PATH
#
#RUN apt-get -y install build-essential
#RUN cd /installs && wget http://downloads.ghostscript.com/public/ghostpdl-9.53.3.tar.gz
#RUN cd /installs && tar -xvf ghostpdl-9.53.3.tar.gz
#RUN apt-get -y install autoconf autogen
#RUN cd /installs/ghostpdl-9.53.3 && ./autogen.sh && ./configure && make -j 5 && make install
