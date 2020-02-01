# Nxt docker image
#
# to use:
#
# 1. install docker, see docker.com
# 2. clone the git repo including this Dockerfile
# 3. build the container with ```docker build -t nxt .```
# 4. run the created nxt container with ```docker run -d -p 127.0.0.1:6868:7876 -p 6899:7874 nxt```
# 5. inspect with docker logs (image hash, find out with docker ps, or assign a name)

FROM phusion/baseimage
# start off with standard ubuntu images

# Set local and enable UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C
ENV LC_ALL C.UTF-8

#java8
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get install -y ant && \
    apt-get clean;
# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;
RUN apt-get install gnupg2  -y
RUN gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 75CEBDE82D6BECC940EC0D22B3E38C4A2BBDBA1E
# run and compile nxt
RUN mkdir /ndex
ADD . /ndex
# repo has
ADD contrib/docker_start.sh /docker_start.sh
# set nxt to listen on all interfaces
RUN echo 'nxt.allowedBotHosts=*' >> /ndex/conf/nxt.properties
RUN echo 'nxt.apiServerHost=0.0.0.0' >> /ndex/conf/nxt.properties
RUN chmod +x /docker_start.sh

RUN cd /ndex; ./compile.sh
# both Nxt ports get exposed
EXPOSE 6899 6868
CMD ["/docker_start.sh"]
