FROM ruby:3.0.3-alpine

RUN apk update && apk upgrade
RUN apk add --update --no-cache \
  build-base \
  curl \
  git \
  gnupg1 \
  libffi-dev \
  libsodium-dev \
  libxml2 \
  libxml2-dev \
  shared-mime-info \
  postgresql-dev \
  tzdata \
  yarn && rm -rf /var/cache/apk/*

ENV APP_HOME /opt/webapps/app
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/
RUN gem install bundler && bundle install

COPY . $APP_HOME

RUN rm -rf $APP_HOME/tmp/*
RUN mkdir -p /opt/webapps/app/tmp/pids
EXPOSE 3000
CMD bundle exec rails db:migrate \
  && bundle exec rails s -b 0.0.0.0
