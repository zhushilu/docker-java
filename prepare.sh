#!/bin/sh
VERSION="8"
UPDATE="102"
BUILD="14"

JAVA_TMP_DIR="/tmp/${PRODUCT}1.${VERSION}.0_${UPDATE}"
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/${PRODUCT}-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz"
JAVA_PATH="/usr/lib/java-${VERSION}-oracle"

#PREPARE
#Linux Version
SIG=`cat /etc/*release | grep  ^NAME | cut -c7`

# Alpine
if [ $SIG = "A" ]; then
  GLIBC_VERSION="2.23-r3"
  apk update
  apk upgrade
  apk add --update --progress openssl curl tzdata
  for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do
    curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk;
    apk add --allow-untrusted --update /tmp/${pkg}.apk
  done
fi

# Ubuntu
if [ "$SIG" = "U" ]; then
  export DEBIAN_FRONTEND="noninteractive"
  if [ -n ${http_proxy} ]; then
    APT_PROXY="Acquire::http::Proxy \"$http_proxy\";"
    echo "$APT_PROXY" > /etc/apt/apt.conf.d/99proxy.conf
  fi
  apt-get update
  apt-get install ca-certificates curl \
  -y --no-install-recommends
fi

# INSTALL
cd /tmp
# Download JDK
curl -sSL --retry 3 -o jdk.tar.gz \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "$JAVA_URL"

tar xf jdk.tar.gz
mv "${JAVA_TMP_DIR}" "${JAVA_PATH}"
ln -s "${JAVA_PATH}" "${JAVA_HOME}"
rm -f /tmp/jdk.tar.gz

rm -f /etc/localtime
ln -s "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

# FINISH
if [ "$SIG" = "U" ]; then
  update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1
  update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 1
  update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1
  update-alternatives --set java "${JAVA_HOME}/bin/java"
  update-alternatives --set javaws "${JAVA_HOME}/bin/javaws"
  update-alternatives --set javac "${JAVA_HOME}/bin/javac"
  rm -f /etc/apt/apt.conf.d/99proxy.conf
fi

if [ "$SIG" = "A" ]; then
  if [ "$PRODUCT" = "jre" ]; then
    TODEL=""
  else
    TODEL="jre/"
  fi
  rm -rf ${JAVA_PATH}/*src.zip \
         ${JAVA_PATH}/lib/missioncontrol \
         ${JAVA_PATH}/lib/visualvm \
         ${JAVA_PATH}/lib/*javafx* \
         ${JAVA_PATH}/${TODEL}lib/plugin.jar \
         ${JAVA_PATH}/${TODEL}lib/ext/jfxrt.jar \
         ${JAVA_PATH}/${TODEL}bin/javaws \
         ${JAVA_PATH}/${TODEL}lib/javaws.jar \
         ${JAVA_PATH}/${TODEL}lib/desktop \
         ${JAVA_PATH}/${TODEL}plugin \
         ${JAVA_PATH}/${TODEL}lib/deploy* \
         ${JAVA_PATH}/${TODEL}lib/*javafx* \
         ${JAVA_PATH}/${TODEL}lib/*jfx* \
         ${JAVA_PATH}/${TODEL}lib/amd64/libdecora_sse.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libprism_*.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libfxplugins.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libglass.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libgstreamer-lite.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libjavafx*.so \
         ${JAVA_PATH}/${TODEL}lib/amd64/libjfx*.so
  rm -f /tmp/${pkg}.apk
  ln -s ${JAVA_PATH}/bin/* /usr/local/bin
  rm -rf /var/cache/apk/*
fi
