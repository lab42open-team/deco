FROM ubuntu:18.04 
MAINTAINER Savvas Paragkamian s.paragkamian@hcmr.gr

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Basic ubuntu tools
RUN apt-get update && apt-get install -y wget \
    && apt-get install -qq -y curl

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update

## install GIT and dependency preesed tzdata(requires interaction from user during installation), update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Athens" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata

RUN apt-get install -y git-all

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

# System libraries for tidyverse
RUN apt-get update
RUN apt-get install -y libpcre3-dev libpcre2-dev libpcre-ocaml-dev libghc-regex-pcre-dev
RUN apt-get update
RUN apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev
RUN apt-get update

# tesseract dependencies
## libraries for images, first, before leptonica
RUN apt-get update
RUN apt-get install -y pkg-config
RUN apt-get install -y automake
RUN apt-get install -y libtool
RUN apt-get install -y libpng-dev
RUN apt-get install -y libjpeg8-dev
RUN apt-get install -y libtiff5-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libwebp-dev
RUN apt-get install -y libopenjp2-7-dev
RUN apt-get install -y libgif-dev
RUN apt-get install -y libsdl-pango-dev
RUN apt-get install -y libicu-dev
RUN apt-get install -y libcairo2-dev
RUN apt-get install -y bc
RUN apt-get update

## leptonica

WORKDIR /home
RUN wget http://www.leptonica.org/source/leptonica-1.80.0.tar.gz
RUN tar -zxf leptonica-1.80.0.tar.gz
WORKDIR /home/leptonica-1.80.0
RUN ./configure
RUN make
RUN make install
# Note that if building Leptonica from source, you may need to ensure that /usr/local/lib is in your library path. This is a standard Linux bug, and the information at Stackoverflow is very helpful.

# Main tools installation

# Ghostscript
WORKDIR /home
RUN wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9533/ghostscript-9.53.3.tar.gz
RUN tar -xvf ghostscript-9.53.3.tar.gz
WORKDIR ghostscript-9.53.3
RUN ./configure
RUN make
RUN make install

# ImageMagick
WORKDIR /home
RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz
RUN tar -zxf ImageMagick.tar.gz
WORKDIR ImageMagick-7.0.10-61
RUN ./configure
RUN make
RUN make install

# jq
RUN apt-get update
RUN apt-get install -y jq
RUN apt-get update

# tesseract OCR
WORKDIR /home
RUN wget https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz
RUN tar -zxf 4.1.1.tar.gz
WORKDIR /home/tesseract-4.1.1
RUN ./autogen.sh
RUN ./configure
RUN LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make
RUN make install
RUN ldconfig
### ldconfig tells applications where they can find the linked libraries. That's why the above command can be needed after installing something new
#RUN make training
#RUN make training-install

### download the supporting languages of tesseract
WORKDIR /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata
RUN wget https://github.com/tesseract-ocr/tessdata_best/raw/master/osd.traineddata
#WORKDIR /home/tesseract-4.1.1
#RUN mv tessdata/ /usr/share/
#RUN export TESSDATA_PREFIX=/usr/share/tessdata/

# gnfinder
WORKDIR /home
RUN wget https://github.com/gnames/gnfinder/releases/download/v0.11.1/gnfinder-v0.11.1-linux.tar.gz
RUN tar -zxf gnfinder-v0.11.1-linux.tar.gz
RUN mv gnfinder /usr/local/bin

# Install R
WORKDIR /home
RUN wget https://ftp.cc.uoc.gr/mirrors/CRAN/src/base/R-4/R-4.0.3.tar.gz
RUN tar -xf R-4.0.3.tar.gz
WORKDIR /home/R-4.0.3
RUN ./configure
RUN make
RUN make install
RUN Rscript -e 'install.packages("tidyverse", repos="https://cran.rstudio.com")'

# Clean the container
## cleanup of files from setup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /home/*

# EMODnet workflow
WORKDIR /home
RUN git clone https://github.com/lab42open-team/EMODnet-data-archaeology.git

# Set "EMODnet-data-archaeology" as my working directory when a container starts
WORKDIR /home/EMODnet-data-archaeology
