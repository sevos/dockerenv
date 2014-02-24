FROM ubuntu

RUN apt-get update && apt-get install -y curl git-core libxml2-dev libxslt-dev libpq-dev libsqlite3-dev libqtwebkit-dev && \curl -sSL https://get.rvm.io | bash -s stable && echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc
RUN /bin/bash -l -c 'rvm install 2.0.0'
RUN /bin/bash -l -c 'rvm 2.0.0 do gem install bundler'
RUN mkdir /root/.ssh && echo "Host github.com\nStrictHostKeyChecking no" >> /root/.ssh/config
ENV SSH_AUTH_SOCK /tmp/ssh-agent.sock
ENV HOME /