FROM --platform=linux/amd64 ruby:3.0.3-bullseye

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update > /dev/null && apt-get install -y --no-install-recommends > /dev/null \
    build-essential=* \
    imagemagick=* \
    curl \
    wget \
    gnupg2 \
    git \
    apt-utils \
    && apt-get dist-upgrade -yf\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN sed -i -e 's/# et_EE.UTF-8 UTF-8/et_EE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=et_EE.UTF-8

ENV LANG et_EE.UTF-8
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc -s | apt-key add -
RUN sh -c 'echo "deb https://apt-archive.postgresql.org/pub/repos/apt bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update > /dev/null && apt-get install -y --no-install-recommends > /dev/null \
    postgresql-client-13=* \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# add repository for Node.js in the LTS version
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -

RUN apt-get install -y --no-install-recommends > /dev/null \
  nodejs \
  qtbase5-dev \
  libqt5webkit5-dev \
  gstreamer1.0-plugins-base \
  libappindicator3-1 \
  gstreamer1.0-tools \
  qtdeclarative5-dev \
  fonts-liberation \
  gstreamer1.0-x \
  libasound2 \
  libnspr4 \
  libnss3 \
  libxss1 \
  libxtst6 \
  xdg-utils \
  qtdeclarative5-dev \
  fonts-liberation \
  gstreamer1.0-x \
  wkhtmltopdf \
  libxslt1-dev \
  libxml2-dev \
  python-dev \
  unzip \    
#   libc6-i386 \
#   lib32gcc-s1 \
  wkhtmltopdf \
  xvfb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Python packages for wordcloud generation
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    python3-dev \
    && pip3 install --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir numpy Pillow matplotlib wordcloud openai dotenv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get autoremove -y && apt-get clean

ENV CHROME_VERSION="128.0.6613.137"

RUN wget -q "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chrome-linux64.zip" \
    && unzip chrome-linux64.zip -d /opt/ \
    && rm chrome-linux64.zip

RUN wget -q "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip" \
    && unzip chromedriver-linux64.zip -d /opt/ \
    && mv /opt/chromedriver-linux64/chromedriver /usr/local/bin/ \
    && rm -rf chromedriver-linux64.zip /opt/chromedriver-linux64

RUN npm install --global yarn

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app
COPY Gemfile Gemfile.lock ./
# ADD vendor/gems/omniauth-tara ./vendor/gems/omniauth-tara
RUN gem install bundler && bundle install --jobs 20 --retry 5

ENV PATH="/opt/chrome-linux64:${PATH}"

# RUN apt-get update && apt-get install -y --no-install-recommends > /dev/null \
#     libc6-i386 \
#     lib32gcc-s1 \
#     wkhtmltopdf \
#     xvfb \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

RUN ln -s /lib/ld-linux.so.2 /lib/ld-linux.so.2 || true

RUN echo '#!/bin/bash\nxvfb-run -a --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf "$@"' > /usr/local/bin/wkhtmltopdf \
    && chmod +x /usr/local/bin/wkhtmltopdf

EXPOSE 3000