FROM ubuntu:14.04
ENV DEBIAN_FRONTEND="noninteractive" \
  TIMEZONE="Asia/Shanghai"

COPY prepare.sh /usr/local/bin
RUN prepare.sh
