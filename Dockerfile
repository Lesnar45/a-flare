FROM flaresolverr/flaresolverr
USER root
ENV XDG_DATA_HOME="/config" \
    XDG_CONFIG_HOME="/config"

# Install packages
RUN \
# Install jackett
  mkdir -p /app/Jackett && \
  jack_tag=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o /build/jacket.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jack_tag/Jackett.Binaries.Mono.tar.gz && \
  tar zxf /build/jacket.tar.gz -C /app/Jackett --strip-components=1 && \

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
