FROM jenkins/jnlp-slave:4.3-4

ENV DOCKER_BUILDKIT=1

USER root

ENV DOCKER_VERSION=19.03.8
ENV DOCKER_COMPOSE_VERSION=1.26.0
ENV TINI_VERSION v0.19.0
ENV PYENV_ROOT=/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PATH

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update && \
	apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common build-essential bsdmainutils && \
	apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
		libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev \
		xz-utils tk-dev libffi-dev liblzma-dev python-openssl && \
	# install docker
	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
	apt-get update && \
	apt-get install docker-ce-cli="5:${DOCKER_VERSION}~3-0~debian-$(lsb_release -cs)" && \
	curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose && \
	groupadd -g 999 docker && usermod -u 11011 jenkins && usermod -a -G docker jenkins && \
	# install python
	git clone --single-branch --branch master https://github.com/pyenv/pyenv.git /.pyenv && \
	pyenv install 3.8.2 && \
	ln -s /.pyenv/versions/3.8.2/bin/python3.8 /usr/bin/python3.8 && \
	ln -s /.pyenv/shims/pip /usr/bin/pip3.8 && \
	chown -R jenkins:jenkins /.pyenv && \
	# clean up
	apt-get remove -y build-essential libssl-dev zlib1g-dev libbz2-dev \
		libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev \
		xz-utils tk-dev libffi-dev liblzma-dev python-openssl && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

USER jenkins
RUN cp ~/.bashrc ~/.bashrc_copy && \
	echo 'eval "$(pyenv init -)"' > ~/.bashrc && \
	cat ~/.bashrc_copy >> ~/.bashrc
ENV PYENV_VERSION=3.8.2

ENTRYPOINT ["/tini", "--", "jenkins-agent"]
