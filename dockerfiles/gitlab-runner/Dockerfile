FROM gitlab/gitlab-runner:v9.4.1

ADD custom-entrypoint /custom-entrypoint

ENTRYPOINT ["/usr/bin/dumb-init", "/custom-entrypoint"]

