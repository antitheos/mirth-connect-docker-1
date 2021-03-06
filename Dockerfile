FROM java
MAINTAINER Ade Ayoade <antitheos@gmail.com>

ENV MIRTH_CONNECT_VERSION 3.4.1.8057.b139

# Mirth Connect is run with user `connect`, uid = 1000
# If you bind mount a volume from the host or a data container, 
# ensure you use the same uid
RUN useradd -u 1000 mirth

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends authbind && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu


RUN touch /etc/authbind/byport/80 && \
  chown mirth:mirth /etc/authbind/byport/80 && \
  chmod 755 /etc/authbind/byport/80

RUN touch /etc/authbind/byport/443 && \
  chown mirth:mirth /etc/authbind/byport/443 && \
  chmod 755 /etc/authbind/byport/443
  
VOLUME /opt/mirth-connect/appdata

RUN \
  cd /tmp && \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mv Mirth\ Connect/* /opt/mirth-connect/ && \
  chown -R mirth /opt/mirth-connect

WORKDIR /opt/mirth-connect

EXPOSE 80 443

COPY mirth.properties /opt/mirth-connect/conf/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["authbind", "java", "-jar", "mirth-server-launcher.jar"]