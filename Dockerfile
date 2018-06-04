FROM ruby:2.3
MAINTAINER maciej.szlosarczyk@internet.ee

RUN apt-get update > /dev/null && apt-get install -y > /dev/null \
    build-essential \
    nodejs \
    imagemagick \
    postgresql-client

RUN apt-get install -y > /dev/null \
    qt5-default \
    libqt5webkit5-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    qtdeclarative5-dev \
    gstreamer1.0-x

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
EXPOSE 3000
