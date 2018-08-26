FROM openjdk:8u171-jre-alpine3.8
MAINTAINER Maksim Kostromin https://github.com/daggerok
ARG VERSION_ARG='0.0.1'
ARG JAVA_OPTS_ARGS='\
 -Djavax.net.debug=ssl \
 -Djava.net.preferIPv4Stack=true \
 -XX:+UnlockExperimentalVMOptions \
 -XX:+UseCGroupMemoryLimitForHeap \
 -XshowSettings:vm '
ARG PORT_ARG=8080
ENV VERSION=${VERSION_ARG} \
    JAVA_OPTS="${JAVA_OPTS} ${JAVA_OPTS_ARGS}" \
    PORT="${PORT_ARG}"
RUN apk --no-cache --update add busybox-suid bash curl unzip sudo openssh-client shadow wget \
 && adduser -h /home/cassandra -s /bin/bash -D -u 1025 cassandra wheel \
 && echo 'cassandra ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
 && sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers \
 && wget --no-cookies \
         --no-check-certificate \
         --header 'Cookie: oraclelicense=accept-securebackup-cookie' \
                  'http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip' \
         -O /tmp/jce_policy-8.zip \
 && unzip -o /tmp/jce_policy-8.zip -d /tmp \
 && mv -f ${JAVA_HOME}/lib/security ${JAVA_HOME}/lib/backup-security || echo 'nothing to backup' \
 && mv -f /tmp/UnlimitedJCEPolicyJDK8 ${JAVA_HOME}/lib/security \
 && apk del busybox-suid openssh-client shadow \
 && rm -rf /var/cache/apk/* /tmp/*
USER cassandra
WORKDIR /home/cassandra
VOLUME /home/cassandra
ENTRYPOINT java ${JAVA_OPTS} -jar ./app.jar
CMD /bin/bash
EXPOSE ${PORT}
HEALTHCHECK --timeout=1s \
            --retries=66 \
            CMD curl -f http://127.0.0.1:${PORT}/cassandra/health || exit 1
RUN wget --no-cookies \
         --no-check-certificate \
           "https://github.com/daggerok/cassandra/releases/download/${VERSION_ARG}/cassandra-${VERSION_ARG}.jar" \
           -O /tmp/jce_policy-8.zip \
 && apk del busybox-suid openssh-client shadow