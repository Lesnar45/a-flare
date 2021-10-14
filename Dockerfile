FROM flaresolverr/flaresolverr
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
ARG JACKETT_ARCH="LinuxAMDx64"
USER root
ENV XDG_DATA_HOME="/config" \
    XDG_CONFIG_HOME="/config"
RUN apk --no-cache add curl icu-libs jq wget tar
RUN apk --no-cache add libressl-dev
WORKDIR /opt

# ports and volumes
VOLUME /config /downloads
EXPOSE 9117
ENV LOG_LEVEL=info
EXPOSE 8191
#Install dependencies and install mono
RUN apk add --update wget tar bzip2 curl-dev && apk add mono --update-cache --repository http://nl.alpinelinux.org/alpine/edge/testing/ --allow-untrusted && rm -Rfv /var/cache/apk/*

#Create group and user
RUN addgroup -S jackett && adduser -s /bin/false -h /usr/share/Jackett -G jackett -S jackett && mkdir -p /usr/share/Jackett && chown -R jackett: /usr/share/Jackett

#Wget Jackett decompress then cleanup
RUN wget --no-check-certificate -q https://github.com/Jackett/Jackett/releases/download/v0.18.992/Jackett.Binaries.Mono.tar.gz && tar -zxf Jackett.Binaries.Mono.tar.gz && rm -v /opt/Jackett.Binaries.Mono.tar.gz

#Set the owner
RUN chown -R jackett: /opt/Jackett

#Map /config to host defined config path (used to store configuration from supervisor)
VOLUME /config

#Map /root/.config/Jackett to host defined config path (used to store configuration from Jackett)

VOLUME /root/.config/Jackett

#Expose port for http
EXPOSE 9117
RUN npm start &
#Run
ENTRYPOINT ["/usr/bin/mono", "--debug", "/opt/Jackett/JackettConsole.exe"]
CMD ["-x", "true"]

