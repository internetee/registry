# FROM gitlab/registry
FROM slimmed
MAINTAINER Gitlab <info@gitlab.eu>

# Initial build
# SSH authorized keys setup
# ADD ./doc/docker/ssh/authorized_keys /root/.ssh/authorized_keys
#
# Apache2 setup
# ADD ./doc/docker/apache2/ /etc/apache2/sites-enabled

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Set correct environment variables.
ENV RAILS_ENV production 
ENV HOME /home/app

# Registry
WORKDIR /home/app/registry
ADD . /home/app/registry
RUN chown -R app:www-data .; chmod -R 750 .; chmod g+s .; umask 027
RUN setuser app ls -la /home/app/registry/vendor/
# RUN setuser app ls -la /home/app/registry/vendor/bundle
RUN rm /home/app/registry/vendor/bundle -rf
RUN setuser app bundle install --deployment
RUN setuser app rake assets:precompile

# Registry test
WORKDIR /home/app/registry-test
ADD . /home/app/registry-test
RUN chown -R app:www-data .; chmod -R 750 .; chmod g+s .; umask 027
RUN setuser app bundle install

# Ports
# Registry admin:
EXPOSE 80  
# EPP:
EXPOSE 700 
# Test env what jenkins uses
# for debugging only:
# EXPOSE 81

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
