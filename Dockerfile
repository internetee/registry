FROM internetee/ruby:3.0-buster

# # RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4EB27DB2A3B88B8B
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git \
#     postgresql-client \
#   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get remove -y google-chrome-stable
RUN apt-get purge -y google-chrome-stable
RUN apt-get autoremove -y && apt-get clean

ENV CHROME_VERSION="128.0.6613.137"

RUN wget -q "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chrome-linux64.zip" \
    && unzip chrome-linux64.zip -d /opt/ \
    && rm chrome-linux64.zip

RUN wget -q "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip" \
    && unzip chromedriver-linux64.zip -d /opt/ \
    && mv /opt/chromedriver-linux64/chromedriver /usr/local/bin/ \
    && rm -rf chromedriver-linux64.zip /opt/chromedriver-linux64

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
# ADD vendor/gems/omniauth-tara ./vendor/gems/omniauth-tara
RUN gem install bundler && bundle install --jobs 20 --retry 5

ENV PATH="/opt/chrome-linux64:${PATH}"

EXPOSE 3000
