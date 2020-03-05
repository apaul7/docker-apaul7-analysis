FROM ubuntu:bionic
MAINTAINER Alexander Paul <alex.paul@wustl.edu>

LABEL \
  version="0.0.1" \
  description="Image for interactive analysis"

RUN apt-get update && apt-get install -y \
  bzip2 \
  curl \
  default-jdk \
  default-jre \
  git \
  gzip \
  g++ \
  libbz2-dev \
  liblzma-dev \
  nodejs \
  perl \
  python3 \
  python3-pip \
  locales \
  make \
  ncurses-dev \
  rsync \
  vim \
  wget \
  zlib1g-dev && apt-get clean all

RUN locale-gen --no-purge en_US.UTF-8 
WORKDIR /tmp

############
# bcftools #
############
ENV BCFTOOLS_VERSION=1.9
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  cd /tmp/bcftools-$BCFTOOLS_VERSION && \
  make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install && \
  ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION

############
# samtools #
############
ENV SAMTOOLS_VERSION=1.9
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
RUN wget https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf samtools-$SAMTOOLS_VERSION.tar.bz2 && \
  cd /tmp/samtools-$SAMTOOLS_VERSION && \
  make prefix=$SAMTOOLS_INSTALL_DIR && \
  make prefix=$SAMTOOLS_INSTALL_DIR install && \
  ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/bin/samtools && \
  rm -rf /tmp/samtools-$SAMTOOLS_VERSION

###################
# python packages #
###################
RUN pip3 install --upgrade pip && \
  pip install pyyaml unidecode 'setuptools>=18.5' cwltool 'ruamel.yaml==0.14.2'
# default python3
RUN ln -s /usr/bin/python3 /usr/bin/python

##########
# picard #
##########
ENV PICARD_VERSION=2.21.8
ENV PICARD_INSTALL=/opt/picard.jar
RUN wget https://github.com/broadinstitute/picard/releases/download/$PICARD_VERSION/picard.jar && \
  mv picard.jar $PICARD_INSTALL && \
  ln -s $PICARD_INSTALL /usr/bin/picard && \
  rm -rf /tmp

#################
# perl packages #
#################
RUN cpan install CPAN && \
  cpan YAML::XS File Cwd Text::CSV JSON

WORKDIR /

# r? r packages?
# cromwell
# cromwell jar
# vt?
# picard
