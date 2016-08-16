#!/bin/sh
JAVA_TMP_DIR="/tmp/jdk1.${VERSION}.0_${UPDATE}"
JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/${PRODUCT}-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz"
JAVA_PATH="/usr/lib/java-${VERSION}-oracle"

apk update
apk upgrade
apk add openssl curl tzdata

#for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do
for pkg in glibc-${GLIBC_VERSION}; do
curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk;
apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk
done

cd /tmp
# Download JDK
curl -sSL --retry 3 -o jdk.tar.gz \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "$JAVA_URL"

tar xf jdk.tar.gz

mv "${JAVA_TMP_DIR}" "${JAVA_PATH}"
ln -s "${JAVA_PATH}" "${JAVA_HOME}"

rm -f /etc/localtime
ln -s "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime


rm -rf ${JAVA_PATH}/*src.zip \
       ${JAVA_PATH}/lib/missioncontrol \
       ${JAVA_PATH}/lib/visualvm \
       ${JAVA_PATH}/lib/*javafx* \
       ${JAVA_PATH}/jre/lib/plugin.jar \
       ${JAVA_PATH}/jre/lib/ext/jfxrt.jar \
       ${JAVA_PATH}/jre/bin/javaws \
       ${JAVA_PATH}/jre/lib/javaws.jar \
       ${JAVA_PATH}/jre/lib/desktop \
       ${JAVA_PATH}/jre/plugin \
       ${JAVA_PATH}/jre/lib/deploy* \
       ${JAVA_PATH}/jre/lib/*javafx* \
       ${JAVA_PATH}/jre/lib/*jfx* \
       ${JAVA_PATH}/jre/lib/amd64/libdecora_sse.so \
       ${JAVA_PATH}/jre/lib/amd64/libprism_*.so \
       ${JAVA_PATH}/jre/lib/amd64/libfxplugins.so \
       ${JAVA_PATH}/jre/lib/amd64/libglass.so \
       ${JAVA_PATH}/jre/lib/amd64/libgstreamer-lite.so \
       ${JAVA_PATH}/jre/lib/amd64/libjavafx*.so \
       ${JAVA_PATH}/jre/lib/amd64/libjfx*.so
rm -f /tmp/${pkg}.apk
rm -f /tmp/jdk.tar.gz
ln -s ${JAVA_PATH}/bin/* /usr/local/bin
