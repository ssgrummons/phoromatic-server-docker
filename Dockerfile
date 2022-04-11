FROM registry.cirrus.ibm.com/public/ubi8:latest

LABEL maintainer="ssgrummo@us.ibm.com"

ARG PHORONIX_VERSION=10.8.2

RUN yum update -y &&\
    yum install -y php php-xml php-gd php-sqlite3 php-posix php-cli php-json php-zip && \
    yum update -y &&\
    yum install dos2unix -y &&\
    yum autoremove -y &&\
    yum clean all &&\
    rm -rf /var/cache/yum &&\
    alternatives --install /usr/bin/php php /usr/bin/php 100

ENV INSTALL_DIR="/var/lib/phoronix-test-suite"
ENV PHORONIX_USERDIR="/home/phoronix/.phoronix-test-suite"

#RUN useradd -u 1000 -d $INSTALL_DIR -m -s /bin/bash phoromatic

RUN curl -o /tmp/phoronix-test-suite.tar.gz https://phoronix-test-suite.com/releases/phoronix-test-suite-$PHORONIX_VERSION.tar.gz 
RUN tar xzfv /tmp/phoronix-test-suite.tar.gz --directory /var/lib
RUN mkdir -p ${PHORONIX_USERDIR}
ADD resources/phoromatic-user-config.xml ${PHORONIX_USERDIR}/user-config.xml
ADD resources/phoromatic_tests.txt $INSTALL_DIR
ADD resources/run.sh $INSTALL_DIR

RUN dos2unix ${INSTALL_DIR}/run.sh

RUN groupadd -r -g 10101 phoronix &&\
    useradd -r -u 10101 -s /sbin/nologin -M -g phoronix phoronix &&\
    chown -R phoronix:root $INSTALL_DIR &&\
    chmod -R 0777 $INSTALL_DIR  &&\
    chown -R phoronix:root $PHORONIX_USERDIR &&\
    chmod -R 0777 $PHORONIX_USERDIR 

USER 10101

WORKDIR $INSTALL_DIR

EXPOSE 8088 8089

VOLUME ["/home/phoronix/.phoronix-test-suite/phoromatic"]

ENV PTS_SILENT_MODE=1
ENV PTS_IS_DAEMONIZED_SERVER_PROCESS=1
CMD ["./run.sh"]