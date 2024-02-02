FROM internetee/ruby:3.0-buster

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
# ADD vendor/gems/omniauth-tara ./vendor/gems/omniauth-tara

ENV LANG et_EE.UTF-8
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -s | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update > /dev/null && apt-get install -y --no-install-recommends > /dev/null \
    postgresql-client-13=* \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler && bundle install --jobs 20 --retry 5

EXPOSE 3000
