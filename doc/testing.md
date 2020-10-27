Testing local project without docker container
-------

Setup test databases:

    RAILS_ENV=test rake db:setup:all

Run basic test (no EPP tests):

    rake


Testing using docker container
-------

It's strongly recommended to test/debug registry application using docker containers from https://github.com/internetee/docker-images .
For doing so first setup containers as per docker images documentation (https://github.com/internetee/docker-images/blob/master/README.MD), then in docker images directory run the following:

    docker-compose run registry bundle exec rake RAILS_ENV=test COVERAGE=true

To run single test:

    docker-compose run registry bundle exec rails test <path_to_test> RAILS_ENV=test COVERAGE=true

Allowed testing email list
==========================

All allowed testing emails are located under config/initialized/settings.rb file.

