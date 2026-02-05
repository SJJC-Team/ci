#!/usr/bin/env bash

# 用法: ./opa.sh <ADDR> <OPA_VERSION>
ADDR="${1:-0.0.0.0:8181}"
VERSION="${2:-v1.13.1}"

# 检测架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ]; then
    ARCH="arm64"
fi

if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    echo "不支持的架构: ${ARCH}"
    exit 1
fi

DOWNLOAD_URL="https://github.com/open-policy-agent/opa/releases/download/${VERSION}/opa_darwin_${ARCH}_static"

echo "正在下载 OPA ${VERSION} (${ARCH})..."
echo "URL: ${DOWNLOAD_URL}"

curl -L -o opa "${DOWNLOAD_URL}"

if [ $? -ne 0 ]; then
    echo "下载失败"
    exit 1
fi

sudo chmod +x opa

./opa run --server --addr $ADDR

echo "OPA 初始化 完成"
