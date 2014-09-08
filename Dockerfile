FROM gitlab/registry
MAINTAINER Gitlab <info@gitlab.eu>

# Set correct environment variables.
ENV HOME /home/app

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# App
WORKDIR /home/app/registry
ADD . /home/app/registry
RUN bundle install --deployment

# Setup nginx
# RUN rm /etc/nginx/sites-enabled/default
# ADD nginx.conf /etc/nginx/sites-enabled/webapp.conf
# RUN rm -f /etc/services/nginx/down

# RUN rm /etc/nginx/sites-enabled/default
# ADD ./nginx.conf /etc/nginx/sites-enabled/webapp.conf
# RUN rm -f /etc/services/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Install an SSH public keys
ADD ./doc/docker/authorized_keys /tmp/authorized_keys
RUN cat /tmp/authorized_keys > /root/.ssh/authorized_keys && rm -f /tmp/authorized_keys

EXPOSE 80
EXPOSE 700
