#
# Image used to download, compile and run Ceylon sources in a very simple way
#
FROM ceylon/ceylon:1.3.0-jre8-redhat

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

LABEL org.ceylon-lang.dockerfile.description="Image used to download, compile and run Ceylon sources in a very simple way" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="1.0"

ENV LANG=en_US.utf8

ADD start-app.sh start-app.sh

ENTRYPOINT ["/app/start-app.sh"]
CMD []

