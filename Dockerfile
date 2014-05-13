FROM ubuntu:14.04
MAINTAINER Yasser Nabi "yassersaleemi@gmail.com"
VOLUME ["/var/lib/jenkins"]
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_JAVA_ARGS '-Djava.awt.headless=true'
ENV JENKINS_MAXOPENFILES 8192
ENV JENKINS_PREFIX /jenkins
ENV JENKINS_ARGS '--webroot=/var/cache/jenkins/war --httpPort=8080 --ajp13Port=-1'
ENV TZ Europe/London
ENV DEBIAN_FRONTEND noninteractive
EXPOSE 8080 2812 22 36562 33848/udp

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
        apt-get -y install curl && \
        curl -s -L http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | apt-key add - && \
        apt-key update && \
        echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list && \
        apt-get update && \
        apt-get -y install \
            openssh-server \
            monit \
            openjdk-7-jre-headless \
            git \
            subversion \
            jenkins

ADD ./monit.d/ /etc/monit/conf.d/
ADD ./jenkins.sudoers /etc/sudoers.d/jenkins
ADD ./jenkins_init_wrapper.sh /jenkins_init_wrapper.sh
ADD ./plugins_script /plugins_script
ADD ./start.sh /start.sh
ADD ./config.xml $JENKINS_HOME/config.xml

RUN /plugins_script/download_plugins.sh

ENTRYPOINT ["/bin/bash", "/start.sh"]
