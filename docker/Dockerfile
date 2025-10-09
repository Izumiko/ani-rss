FROM eclipse-temurin:25-jdk-alpine AS jre-builder

# 使用 jlink 创建一个只包含必要模块的自定义 JRE
RUN $JAVA_HOME/bin/jlink \
      --add-modules java.base,java.desktop,java.management,java.security.jgss,java.logging,java.naming,java.net.http,java.sql,java.sql.rowset,java.xml,jdk.httpserver,jdk.naming.dns,jdk.unsupported,java.instrument \
      --strip-debug \
      --no-header-files \
      --no-man-pages \
      --compress=zip-6 \
      --output /custom-jre

COPY ani-rss-application/target/ani-rss.jar /usr/app/ani-rss.jar

# 处理jar文件
RUN apk update && apk add --no-cache unzip zip musl-locales musl-locales-lang && \
    cd /tmp && \
    # 1. 仅从 Fat JAR 中提取 sqlite-jdbc，并保持其原本的 BOOT-INF/lib/... 目录结构
    unzip -q /usr/app/ani-rss.jar "BOOT-INF/lib/sqlite-jdbc-*.jar" && \
    SQLITE_JAR=$(ls BOOT-INF/lib/sqlite-jdbc-*.jar) && \
    # 2. 单独将需要的 .so 提取到一个临时目录
    unzip -q $SQLITE_JAR "org/sqlite/native/Linux-Musl/*/libsqlitejdbc.so" -d /tmp/sqlite-native && \
    ARCH=$(apk --print-arch) && \
    # 3. 将 .so 文件移动到自建 JRE 目录
    cp /tmp/sqlite-native/org/sqlite/native/Linux-Musl/${ARCH}/libsqlitejdbc.so /custom-jre/lib/ && \
    # 4. 直接从 sqlite-jdbc jar 内部删除 native 目录 (使用 zip -d 直接删除，无需解压再压缩)
    zip -qd $SQLITE_JAR "org/sqlite/native/*" && \
    # 5. 使用 jar -u0f 将修改后的 sqlite-jdbc 无损注回原 Fat JAR
    # -u: 更新, -0: 仅存储不压缩, -f: 指定文件
    $JAVA_HOME/bin/jar -u0f /usr/app/ani-rss.jar $SQLITE_JAR

FROM alpine:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/custom-jre
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PUID=0 PGID=0 UMASK=022
ENV SERVER_PORT=7789 CONFIG=/config TZ=Asia/Shanghai SWAGGER_ENABLED=false

# 从 jre-builder 阶段拷贝自定义JRE、处理好的jar
COPY --from=jre-builder /custom-jre /usr/lib/jvm/custom-jre
COPY --from=jre-builder /usr/app/ani-rss.jar /usr/app/ani-rss.jar

# 启动脚本
COPY docker/run.sh /run.sh
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

RUN apk add --no-cache su-exec; \
    sed -i 's/\r//g' /*.sh && chmod +x /docker-entrypoint.sh /run.sh

WORKDIR /usr/app
VOLUME /config
EXPOSE $SERVER_PORT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]
