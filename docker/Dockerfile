FROM debian:13-slim AS prepare

COPY ani-rss-application/target/ani-rss-application /usr/app/ani-rss
COPY docker/run.sh /run.sh
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh /run.sh /usr/app/ani-rss

FROM debian:13-slim

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PUID=0 PGID=0 UMASK=022
ENV SERVER_PORT=7789 CONFIG=/config TZ=Asia/Shanghai SWAGGER_ENABLED=false

RUN apt-get update && \
    apt-get install -y --no-install-recommends gosu tzdata ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=prepare /usr/app/ani-rss /usr/app/ani-rss
COPY --from=prepare /run.sh /run.sh
COPY --from=prepare /docker-entrypoint.sh /docker-entrypoint.sh
COPY ani-rss-application/target/*.so /usr/app/

WORKDIR /usr/app
VOLUME /config
EXPOSE $SERVER_PORT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]
