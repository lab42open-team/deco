FROM ubuntu:18.04 
MAINTAINER Savvas Paragkamian s.paragkamian@hcmr.gr

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Basic ubuntu tools
RUN apt-get update && apt-get install -y wget \
 && apt-get install -qq -y curl

RUN apt-get update && apt-get install -y \
    software-properties-common \
 && apt-get update

## install GIT and dependency preesed tzdata(requires interaction from user during installation), update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Europe" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select Athens" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata \
    git-all

# R dependencies
RUN apt-get remove -y r-base-core \
 && apt-get update && apt-get install -y \
    gfortran \
    build-essential \
    fort77 \
    xorg-dev \
    liblzma-dev \
    libblas-dev \
    gcc-multilib \
    gobjc++ \
    aptitude

RUN aptitude install -y libreadline-dev
RUN apt-get update && apt-get install -y libbz2-dev

RUN export CC=/usr/bin/gcc \
 && export CXX=/usr/bin/g++ \
 && export FC=/usr/bin/gfortran \
 && export PERL=/usr/bin/perl

# System libraries for tidyverse
RUN apt-get update && apt-get install -y \
    libpcre3-dev \
    libpcre2-dev \
    libpcre-ocaml-dev \
    libghc-regex-pcre-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
 && apt-get update

# tesseract dependencies
## libraries for images, first, before leptonica
RUN apt-get update && apt-get install -y \
    pkg-config \
    automake \
    libtool \
    libpng-dev \
    libjpeg8-dev \
    libtiff5-dev \
    zlib1g-dev \
    libwebp-dev \
    libopenjp2-7-dev \
    libgif-dev \
    libsdl-pango-dev \
    libicu-dev \
    libcairo2-dev \
    bc \
 && apt-get update

## leptonica

WORKDIR /home
RUN wget http://www.leptonica.org/source/leptonica-1.80.0.tar.gz \
 && tar -zxf leptonica-1.80.0.tar.gz
WORKDIR /home/leptonica-1.80.0
RUN ./configure \
 && make \
 && make install
# Note that if building Leptonica from source, you may need to ensure that /usr/local/lib is in your library path. This is a standard Linux bug, and the information at Stackoverflow is very helpful.

# Main tools installation

# Ghostscript
WORKDIR /home
RUN wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9533/ghostscript-9.53.3.tar.gz \
 && tar -xvf ghostscript-9.53.3.tar.gz
WORKDIR ghostscript-9.53.3
RUN ./configure \
 && make \
 && make install

# ImageMagick
WORKDIR /home
RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz \
 && tar -zxf ImageMagick.tar.gz
 && rm ImageMagick.tar.gz
 && mv ImageMagick* ImageMagick
WORKDIR ImageMagick
RUN ./configure \
 && make \
 && make install

# jq
RUN apt-get update && apt-get install -y jq \
 && apt-get update

# tesseract OCR
WORKDIR /home
RUN wget https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz \
 && tar -zxf 4.1.1.tar.gz
WORKDIR /home/tesseract-4.1.1
RUN ./autogen.sh \
 && ./configure \
 && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make \
 && make install \
 && ldconfig
### ldconfig tells applications where they can find the linked libraries. That's why the above command can be needed after installing something new
#RUN make training
#RUN make training-install

### download the supporting languages of tesseract
WORKDIR /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata_best/raw/master/eng.traineddata \
 && wget https://github.com/tesseract-ocr/tessdata_best/raw/master/osd.traineddata

# gnfinder
WORKDIR /home
RUN wget https://github.com/gnames/gnfinder/releases/download/v0.11.1/gnfinder-v0.11.1-linux.tar.gz \
 && tar -zxf gnfinder-v0.11.1-linux.tar.gz \
 && mv gnfinder /usr/local/bin

# Install R
WORKDIR /home
RUN wget https://ftp.cc.uoc.gr/mirrors/CRAN/src/base/R-4/R-4.0.3.tar.gz \
 && tar -xf R-4.0.3.tar.gz
WORKDIR /home/R-4.0.3
RUN ./configure \
 && make \
 && make install \
 && Rscript -e 'install.packages("tidyverse", repos="https://cran.rstudio.com")'

# Clean the container
## cleanup of files from setup
RUN rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /home/*

# EMODnet workflow download from git
WORKDIR /home
RUN git clone https://github.com/lab42open-team/EMODnet-data-archaeology.git

#  Change the root password by nothing at all.
RUN echo "root:Docker!" | chpasswd

# Set the permissions properly
RUN chmod 777 /home/EMODnet-data-archaeology \
 && chmod g+s /home/EMODnet-data-archaeology

# Set "EMODnet-data-archaeology" as my working directory when a container starts
WORKDIR /home/EMODnet-data-archaeology
