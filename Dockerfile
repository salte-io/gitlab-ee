FROM gitlab/gitlab-ee:13.2.1-ee.0
LABEL MAINTAINER=dave@salte.io

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt install -y nodejs

RUN mkdir -p /opt/gitlab/embedded/service/gitlab-shell/hooks/pre-receive.d && \
    mkdir -p /opt/gitlab/embedded/service/gitlab-shell/hooks/post-receive.d && \
    mkdir -p /opt/gitlab/embedded/service/gitlab-shell/hooks/update.d

ADD application /opt/application

RUN npm install --prefix /opt/application && \
    chmod +x /opt/application/bin/the-hook.js

RUN ln -s /opt/application/bin/the-hook.js /opt/gitlab/embedded/service/gitlab-shell/hooks/update.d/the-hook
