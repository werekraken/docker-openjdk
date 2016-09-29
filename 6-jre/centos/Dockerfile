FROM centos:7
MAINTAINER Matt Cover <werekraken@gmail.com>

RUN yum -y update \
  && yum clean all

ENV LANG en_US.UTF-8

RUN yum -y install \
    java-1.6.0-openjdk \
  && yum clean all
