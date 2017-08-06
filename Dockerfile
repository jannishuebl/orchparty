FROM ruby:2.3.1-slim
RUN apt-get update && apt-get install -y git
RUN mkdir /orchparty
WORKDIR /orchparty
ADD Gemfile .
ADD orchparty.gemspec .
ADD lib lib
ADD .git .git
RUN bundle install --without development test
ADD . .
RUN rake install
COPY docker-entrypoint /usr/local/bin/
ENTRYPOINT ["/bin/sh", "docker-entrypoint"]