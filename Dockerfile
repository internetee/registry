FROM internetee/ruby:3.0-buster

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y postgresql-client-13

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
# ADD vendor/gems/omniauth-tara ./vendor/gems/omniauth-tara
RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000
