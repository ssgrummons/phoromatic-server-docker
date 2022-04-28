FROM fedora:latest

LABEL maintainer="samuel.grummons@gmail.com"

ARG PHORONIX_VERSION=10.8.3

RUN yum update -y &&\
    yum install -y php php-xml php-gd php-sqlite3 php-posix php-cli php-json php-zip && \
    yum update -y &&\
    yum install dos2unix -y &&\
    yum autoremove -y &&\
    yum clean all &&\
    rm -rf /var/cache/yum &&\
    alternatives --install /usr/bin/php php /usr/bin/php 100

ENV INSTALL_DIR="/var/lib/phoronix-test-suite"
ENV PHORONIX_CACHE="/var/cache/phoronix-test-suite"

RUN curl -o /tmp/phoronix-test-suite.tar.gz https://phoronix-test-suite.com/releases/phoronix-test-suite-$PHORONIX_VERSION.tar.gz 
RUN tar xzfv /tmp/phoronix-test-suite.tar.gz --directory /var/lib
RUN mkdir -p ${PHORONIX_CACHE}
ADD resources/phoromatic-user-config.xml /etc/phoronix-test-suite.xml
ADD resources/phoromatic_tests.txt $INSTALL_DIR
ADD resources/run.sh $INSTALL_DIR

RUN dos2unix ${INSTALL_DIR}/run.sh

RUN chmod -R ugo+rw ${PHORONIX_CACHE} &&\
    chmod -R ugo+rwx ${INSTALL_DIR} &&\
    chmod -R ugo+rw /var/lib &&\
    chmod -R ugo+rw /etc 

WORKDIR $INSTALL_DIR

EXPOSE 8088 8089

VOLUME ["${INSTALL_DIR}/phoromatic"]

CMD ["./run.sh"]