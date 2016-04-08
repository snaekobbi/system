FROM ubuntu:15.04

MAINTAINER Jostein Austvik Jacobsen

# Set working directory to home directory
WORKDIR /root/

# Set up repositories
RUN apt-get install -y software-properties-common
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list

# Set locale
RUN locale-gen en_GB en_GB.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL C.UTF-8

# Install Java
RUN apt-get update && apt-get install -y openjdk-7-jre openjdk-8-jre
ENV JAVA_7_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV JAVA_8_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install some basic tools
RUN apt-get update && apt-get install -y wget unzip curl

# Install golang
#RUN wget "https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz" \
RUN wget "https://storage.googleapis.com/golang/go1.4.1.linux-amd64.tar.gz" \
    && tar -xvvf go*.tar.gz \
    && rm go*.tar.gz
ENV PATH $PATH:/root/go/bin
ENV GOROOT /root/go

# Install some more tools
RUN apt-get update && apt-get install -y maven git subversion mercurial bzr ansible vim make gcc sudo lame


# Pipeline 2 CLI from Pipeline 2 v1.9 (requires Java 7 because the cli refuses to use '1.8.0_45-internal')
RUN wget --no-verbose https://github.com/daisy/pipeline-assembly/releases/download/v1.9/pipeline2-1.9-webui_linux.zip \
    && unzip pipeline2-1.9-webui_linux.zip \
    && mv daisy-pipeline/cli dp2-cli \
    && rm daisy-pipeline pipeline2-*.zip -rf \
    && sed -i 's/starting:.*/starting: false/' dp2-cli/config.yml \
    && mv dp2-cli/dp2 dp2-cli/dp2-cli


# Install latest version of the Pipeline 2 engine, braille modules, and Web UI

ENV MAVEN_CENTRAL "http://repo1.maven.org/maven2"
ENV SONATYPE_STAGING "https://oss.sonatype.org/content/groups/staging"
ENV SONATYPE_SNAPSHOTS "https://oss.sonatype.org/content/repositories/snapshots"

ENV ENGINE_VERSION "1.9.11-20160408.082142-7"
ENV WEBUI_VERSION "2.1.3"
ENV MOD_CELIA_VERSION "1.1.1-20160325.111013-1"
ENV MOD_DEDICON_VERSION "1.4.0-20160325.110919-1"
ENV MOD_MTM_VERSION "1.4.1-20160325.140047-5"
ENV MOD_NLB_VERSION "1.6.1-20160325.133755-2"
ENV MOD_NOTA_VERSION "1.1.1-20160407.181802-5"
ENV MOD_SBS_VERSION "1.3.2-20160325.134355-1"

COPY src/setup.sh /root/setup.sh
RUN /root/setup.sh

COPY src/dp2 /root/dp2-cli/dp2
ENV PATH $PATH:/root/dp2-cli

# Bind engine to 0.0.0.0 instead of localhost
RUN sed -i 's/org.daisy.pipeline.ws.host=.*/org.daisy.pipeline.ws.host=0.0.0.0/' /opt/daisy-pipeline2/etc/system.properties

EXPOSE 8181 9000

CMD service pipeline2d start && service daisy-pipeline2-webui start && tail -f /var/log/daisy-pipeline2/daisy-pipeline.log
