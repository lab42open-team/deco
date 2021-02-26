FROM savvasparagkamian/deco:base
MAINTAINER Savvas Paragkamian s.paragkamian@hcmr.gr

# DECO workflow download from git

WORKDIR /home
RUN git clone https://github.com/lab42open-team/deco.git

#  Change the root password by nothing at all.
RUN echo "root:Docker!" | chpasswd

# Set the permissions properly
RUN chmod 777 /home/deco \
 && chmod g+s /home/deco

# Set "deco" as my working directory when a container starts
WORKDIR /home/deco
