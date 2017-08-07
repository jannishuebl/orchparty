FROM ruby:2.4.1-slim
COPY docker-entrypoint .
ENTRYPOINT ["/bin/sh", "docker-entrypoint"]
ADD pkg/ pkg
RUN gem install pkg/orchparty-*

