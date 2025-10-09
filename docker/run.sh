#!/bin/sh

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

path="./"
jar="ani-rss.jar"
jar_path=$path$jar

exec java -Xms60m -Xmx1g -Xss256k \
      -Dfile.encoding=UTF-8 \
      -Xgcpolicy:gencon \
      -Xshareclasses:none \
      -Xquickstart -Xcompressedrefs \
      -Xtune:virtualized \
      -XX:+UseStringDeduplication \
      -XX:-ShrinkHeapInSteps \
      -XX:TieredStopAtLevel=1 \
      -XX:+IgnoreUnrecognizedVMOptions \
      -XX:+UseCompactObjectHeaders \
      --enable-native-access=ALL-UNNAMED \
      --add-opens=java.base/java.net=ALL-UNNAMED \
      --add-opens=java.base/sun.net.www.protocol.https=ALL-UNNAMED \
      -jar $jar_path
