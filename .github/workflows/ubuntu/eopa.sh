#!/usr/bin/env bash

# 用法: ./eopa.sh <ADDR> <OPA_VERSION>
ADDR="${1:-0.0.0.0:8181}"
VERSION="${2:-v1.45.1}"

# 检测架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "arm64" ]; then
    echo "不支持的架构: ${ARCH}"
    exit 1
fi

DOWNLOAD_URL="https://github.com/open-policy-agent/eopa/releases/download/${VERSION}/eopa_Linux_${ARCH}"

echo "正在下载 EOPA ${VERSION} (${ARCH})..."
echo "URL: ${DOWNLOAD_URL}"

curl -L -o eopa "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo "下载失败"
    exit 1
fi

chmod +x eopa

./eopa run --server --addr $ADDR > eopa.log 2>&1 &

echo "EOPA 初始化 完成"
