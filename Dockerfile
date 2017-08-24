FROM centos:7

ENV REFRESHED_AT 2017-08-24
LABEL repo=cisl-repo \
      name=xdmod_distro \
      version=1.4

ENV XDMOD_MAJOR=6.6 \
    XDMOD_VERSION=6.6.0-1.0
ENV XDMOD_RPM=xdmod-${XDMOD_VERSION}.el7.centos
ENV XDMOD_SUPREMM_RPM=xdmod-supremm-${XDMOD_VERSION}.el7.centos

LABEL edu.ucar.cisl.open-xdmod.version ${XDMOD_VERSION}

RUN yum -y update && yum -y install \
    bzip2 \
    epel-release \
    git \
    gmp-devel \
    openssh-clients \
    patch \
    php-gmp \
    sendmail \
    vixie-cron \
    which \
    mod_ssl \
    openssl

RUN yum clean all
RUN yum -y install python2-pip
RUN pip install PyYAML

WORKDIR /usr/local
RUN curl https://repo.ucar.edu/artifactory/binary-local/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar -jxvf - \
    && ln -s phantomjs-2.1.1-linux-x86_64 phantomjs

RUN git clone https://github.com/NCAR/yum-local-repo yum-local-repo && \
    cp yum-local-repo/centos7/yum-local-noarch.repo /etc/yum.repos.d && \
    cp yum-local-repo/centos7/yum-local-x86_64.repo /etc/yum.repos.d

# the supremm module has the dependency on http-parser, which centos will incorporate as a package in the future,
# and then we can move its installation from here to the initial yum installation step above and remove http-parser
# from the yum-local-repo
RUN yum -y install --nogpgcheck http-parser-2.7.1-3.el7 && \
    yum -y install --nogpgcheck $XDMOD_RPM && \
    yum -y install --nogpgcheck $XDMOD_SUPREMM_RPM

WORKDIR /usr/share/xdmod/etl/js
RUN npm install

CMD ["/bin/xdmod-setup"]
