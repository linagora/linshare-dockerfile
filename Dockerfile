FROM tomcat:7

## Linshare dockerfile
MAINTAINER Bastien Mennesson <bmennesson@linagora.com>

EXPOSE 8080

RUN wget --progress=bar:force:noscroll http://download.linshare.org/versions/1.9/linshare-core-1.9.5-without-SSO.war -O webapps/linshare.war

COPY ./start.sh /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
