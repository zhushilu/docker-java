FROM ubuntu
ENV TIMEZONE="Asia/Shanghai" \
VERSION="8" \
UPDATE="102" \
BUILD="14" \
PRODUCT="jdk" \
JAVA_HOME="/usr/lib/java"

COPY prepare.sh /usr/local/bin
RUN prepare.sh
