FROM ubuntu:24.04

LABEL \
  version="1.0.0" \
  description="Image for interactive analysis" \
  maintainer="Alexander Paul <alex.paul@wustl.edu>"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-utils \
  bc \
  build-essential \
  bzip2 \
  curl \
  default-jdk \
  default-jre \
  gcc-multilib \
  git \
  gzip \
  g++ \
  jq \
  libbz2-dev \
  libcurl4-openssl-dev \
  libevent-dev \
  liblzma-dev \
  libncurses5-dev \
  libsqlite3-dev \
  nodejs \
  perl \
  libssl-dev \
  libffi-dev \
  locales \
  make \
  ncurses-dev \
  rsync \
  tzdata \
  unzip \
  vim \
  wget \
  zlib1g-dev && apt-get clean all

RUN locale-gen --no-purge en_US.UTF-8 

RUN mkdir /opt/jars

WORKDIR /tmp

##########
# HTSLIB #
##########
ENV HTSLIB_VERSION=1.20
ENV HTSLIB_INSTALL=/opt/htslib/
RUN wget https://github.com/samtools/htslib/releases/download/$HTSLIB_VERSION/htslib-$HTSLIB_VERSION.tar.bz2 && \
    tar --bzip2 -xf htslib-$HTSLIB_VERSION.tar.bz2 && \
    cd /tmp/htslib-$HTSLIB_VERSION && \
    make prefix=$HTSLIB_INSTALL && \
    make prefix=$HTSLIB_INSTALL install && \
    ln -s $HTSLIB_INSTALL/bin/* /usr/local/bin/ && \
    rm -rf /tmp/htslib-$HTSLIB_VERSION /tmp/htslib-$HTSLIB_VERSION.tar.bz2

############
# bcftools #
############
ENV BCFTOOLS_VERSION=1.20
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  cd /tmp/bcftools-$BCFTOOLS_VERSION && \
  make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install && \
  ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/local/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION /tmp/bcftools-$BCFTOOLS_VERSION.tar.bz2

############
# samtools #
############
ENV SAMTOOLS_VERSION=1.20
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools
RUN wget https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf samtools-$SAMTOOLS_VERSION.tar.bz2 && \
  cd /tmp/samtools-$SAMTOOLS_VERSION && \
  make prefix=$SAMTOOLS_INSTALL_DIR && \
  make prefix=$SAMTOOLS_INSTALL_DIR install && \
  ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/local/bin/samtools && \
  rm -rf /tmp/samtools-$SAMTOOLS_VERSION /tmp/samtools-$SAMTOOLS_VERSION.tar.bz2


##########
# picard #
##########
ENV PICARD_VERSION=2.27.4
ENV PICARD_INSTALL=/opt/jars/picard.jar
RUN wget https://github.com/broadinstitute/picard/releases/download/$PICARD_VERSION/picard.jar && \
  mv picard.jar $PICARD_INSTALL

#########
# fgbio #
#########
ENV FGBIO_VERSION=2.2.1
ENV FGBIO_INSTALL=/opt/jars/fgbio.jar
RUN wget https://github.com/fulcrumgenomics/fgbio/releases/download/$FGBIO_VERSION/fgbio-$FGBIO_VERSION.jar && \
  mv fgbio-$FGBIO_VERSION.jar $FGBIO_INSTALL

###########
# bamutil #
###########
#ENV BAM_UTIL_VERSION=1.0.15
#ENV LIB_STAT_GEN_VERSION=1.0.14
#ENV BAM_UTIL_INSTALL=/opt/BamUtil
#RUN wget https://github.com/statgen/bamUtil/archive/v$BAM_UTIL_VERSION.tar.gz && \
#    tar -zxvf v$BAM_UTIL_VERSION.tar.gz && rm v$BAM_UTIL_VERSION.tar.gz && \
#    wget https://github.com/statgen/libStatGen/archive/v$LIB_STAT_GEN_VERSION.tar.gz && \
#    tar -zxvf v$LIB_STAT_GEN_VERSION.tar.gz && rm v$LIB_STAT_GEN_VERSION.tar.gz && \
#    mv libStatGen-$LIB_STAT_GEN_VERSION libStatGen && \
#    cd bamUtil-$BAM_UTIL_VERSION && \
##    USER_WARNINGS="" make && \
#    make install INSTALLDIR=$BAM_UTIL_INSTALL && \
#    ln -s $BAM_UTIL_INSTALL/bam /usr/local/bin/BamUtil

##########
#Cromwell#
##########
ENV CROMWELL_VERSION="38-b3ea353"
ENV CROMWELL_INSTALL=/opt/jars/cromwell.jar
RUN wget https://github.com/tmooney/cromwell/releases/download/$CROMWELL_VERSION/cromwell-$CROMWELL_VERSION-SNAP.jar \
    && mv cromwell-$CROMWELL_VERSION-SNAP.jar /opt/cromwell.jar


# Define a timezone so Java works properly
RUN ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime \
    && echo "America/Chicago" > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

ENV PYTHON_VERSION="3.8.6"
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz \
  && tar -xf Python-$PYTHON_VERSION.tgz \
  && cd Python-$PYTHON_VERSION \
  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
  && ./configure \
    --build="$gnuArch" \
    --enable-optimizations \
    --enable-option-checking=fatal \
  && make -j "$(nproc)" \
    LDFLAGS="-Wl,--strip-all" \
  && make install

# default python3
RUN ln -s /usr/bin/python3 /usr/bin/python

#################
# perl packages #
#################
RUN cpan install CPAN && \
  cpan \
  Cwd \
  Excel::Writer::XLSX \
  File \
  JSON \
  Sort::Key::Natural \
  Text::CSV \
  YAML::XS

###################
# python packages #
###################
RUN pip3 install --upgrade pip && \
  pip install \
  biopython \
  cwltool \
  fastparquet \
  joblib \
  jupyter \
  matplotlib \
  pandas \
  pyarrow \
  pysam \
  PyVCF3 \
  pyyaml \
  'ruamel.yaml<=0.16.5,>=0.12.4' \
  scikit-learn \
  setuptools \
  shap \
  umi_tools \
  unidecode \
  vcfpy \
  xgboost \
  xlsx2csv \
  xlsxwriter

RUN mkdir /opt/git/ && \
  cd /opt/git/ && \
  git clone https://github.com/apaul7/merge-sv-records.git


ENV STRLING_VERSION="0.5.2"
RUN cd /usr/local/bin/ && \
  wget https://github.com/quinlan-lab/STRling/releases/download/v${STRLING_VERSION}/strling && \
  chmod +x strling

ENV BEDTOOLS_VERSION="2.31.0"
RUN cd /usr/local/bin/ && \
  wget https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools.static && \
  mv bedtools.static bedtools && \
  chmod +x bedtools

ENV SOMALIER_VERSION="0.2.19"
RUN cd /usr/local/bin/ && \
  wget https://github.com/brentp/somalier/releases/download/v${SOMALIER_VERSION}/somalier && \
  chmod +x somalier
ENV SLIVAR_VERSION="0.3.0"
RUN cd /usr/local/bin && \
  wget https://github.com/brentp/slivar/releases/download/v${SLIVAR_VERSION}/slivar && \
  wget https://github.com/brentp/slivar/releases/download/v${SLIVAR_VERSION}/pslivar && \
  chmod +x slivar && \
  chmod +x pslivar

ENV NODE_VERSION="v16.9.1"
ENV NODE_INSTALL_DIR=/opt/node
RUN cd /tmp && \
  curl -fsSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz -o node-${NODE_VERSION}-linux-x64.tar.gz && \
  tar -xzvf node-${NODE_VERSION}-linux-x64.tar.gz && \
  rm node-${NODE_VERSION}-linux-x64.tar.gz && \
  mv node-${NODE_VERSION}-linux-x64 $NODE_INSTALL_DIR && \
  ln -s $NODE_INSTALL_DIR/bin/* /usr/local/bin/

RUN rm -rf /tmp/*
WORKDIR /
