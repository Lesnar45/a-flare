FROM flaresolverr/flaresolverr
USER root
ENV XDG_DATA_HOME="/config" \
    XDG_CONFIG_HOME="/config"
RUN apk --no-cache add curl icu-libs jq wget
RUN apk --no-cache add libssl1.0 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main
# Install packages
RUN \
  mkdir -p \
	/app/Jackett && \
 if [ -z ${JACKETT_RELEASE+x} ]; then \
	JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 curl -o \
 /tmp/jacket.tar.gz -L \
	"https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.${JACKETT_ARCH}.tar.gz" && \
 tar xf \
 /tmp/jacket.tar.gz -C \
	/app/Jackett --strip-components=1 && \
 echo "**** fix for host id mapping error ****" && \
 chown -R root:root /app/Jackett && \
# cleanup
  rm -rf /build/*

# add local files
COPY root /

# ports and volumes
VOLUME /config /downloads
EXPOSE 9117
ENV LOG_LEVEL=info
EXPOSE 8191

CMD ["npm", "start", "&"]
