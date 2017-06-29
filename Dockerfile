FROM centos:7

ENV REFRESHED_AT 2017-03-20
LABEL name=xdmod_distro \
      version=1.0

ENV XDMOD_MAJOR=5.6 \
    XDMOD_VERSION=5.6.0-1.0
ENV XDMOD_RPM=xdmod-${XDMOD_VERSION}.el7.centos

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
    cp yum-local-repo/centos7/yum-local-noarch.repo /etc/yum.repos.d
RUN yum -y install --nogpgcheck $XDMOD_RPM

CMD ["/bin/xdmod-setup"]
