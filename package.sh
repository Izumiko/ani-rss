#!/bin/bash

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

mvn -B package -Pnative -DskipTests --file pom.xml

if [ $? -ne 0 ]; then
  echo -e "${RED}Native 二进制文件编译失败${NC}"
  exit 1
fi

echo -e "${GREEN}Native 二进制文件编译完成${NC}"
