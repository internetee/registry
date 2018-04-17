# /bin/sh
docker-compose down
docker-compose build
docker-compose run app rake db:setup:all
docker-compose run app rake db:migrate
docker-compose run app rake dev:prime
