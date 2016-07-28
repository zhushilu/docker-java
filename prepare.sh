#!/bin/sh
VERSION=8
UPDATE=92
BUILD=14
JAVA_HOME="/usr/lib/jvm/java-${VERSION}-oracle"
JDK_DIR="/tmp/jdk1.${VERSION}.0_${UPDATE}"
OPENSSL_DIR="/tmp/openssl-${OPENSSL_VERSION}"
OPENSSL_VERSION=1.0.2h

if [ -n ${http_proxy} ]; then
  APT_PROXY="Acquire::http::Proxy \"$http_proxy\";"
  echo "$APT_PROXY" > /etc/apt/apt.conf.d/99proxy.conf
fi


apt-get update && apt-get install ca-certificates curl \
  gcc libc6-dev libssl-dev make \
  -y --no-install-recommends

cd /tmp
# Download JDK
curl -s -L --retry 3 \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  -o jdk.tar.gz \
  http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/jdk-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz

tar xf jdk.tar.gz

mkdir -p /usr/lib/jvm
mv "${JDK_DIR}" "${JAVA_HOME}"

# Download Openssl
curl -s -L --retry 3 -k \
  -o openssl.tar.gz \
  https://www.openssl.org/source/openssl-"${OPENSSL_VERSION}".tar.gz
tar xf openssl.tar.gz
cd "${OPENSSL_DIR}"
./config --prefix=/usr
make clean
make
make install

# Clean up
apt-get remove --purge --auto-remove -y \
    gcc libc6-dev libssl-dev make
apt-get autoclean && apt-get --purge -y autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

rm -f /etc/localtime
ln -s "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 1
update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1
update-alternatives --set java "${JAVA_HOME}/bin/java"
update-alternatives --set javaws "${JAVA_HOME}/bin/javaws"
update-alternatives --set javac "${JAVA_HOME}/bin/javac"

rm -f /etc/apt/apt.conf.d/99proxy.conf
