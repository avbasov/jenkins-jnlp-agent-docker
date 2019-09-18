FROM jenkins/jnlp-slave:3.29-1

ENV DOCKER_BUILDKIT=1

USER root

ENV DOCKER_VERSION=19.03.2
ENV DOCKER_COMPOSE_VERSION=1.24.1

RUN apt-get update && \
	apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common build-essential bsdmainutils && \
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
	apt-get update && \
	apt-get install docker-ce-cli="5:${DOCKER_VERSION}~3-0~debian-$(lsb_release -cs)" && \
	rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

RUN groupadd -g 999 docker && usermod -u 11011 jenkins && usermod -a -G docker jenkins

USER jenkins
