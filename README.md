# Semantic Logging in Rails

This repo has some example code to get semantic logging working with rails.

Two gems are used:

* [lograge](https://github.com/roidrage/lograge)
* [semantic_logger](https://github.com/rocketjob/rails_semantic_logger)

These two gems in theory have the same function: to quickly add semantic logging in some form to a Rails project. Both gems have downsides so this repo includes a small bit of code how to glue them together and get the best of both worlds (plus ActiveRecord support).

The interesting stuff is in:
* [the logging initializer](config/initializers/semantic_logging.rb) - sets up semantic logging for Rails
* [the graylog initializer](config/initializers/graylog.rb) - connects the rails app to the Graylog instance
* [boot.rb](config/boot.rb) - ensures *rails server* running locally also uses semantic logging

Although Elasticsearch is not used in this project currently, I included the monkey patch to get semantic logging working with Elasticsearch as an example. It can be found in [the elasticsearch initializer](config/initializers/elasticsearch.rb)

The only controller is the [Users controller](app/controllers/users_controller.rb), which has an action which logs a statement then sleeps for a random amount of time

A [docker-compose](https://docs.docker.com/compose/) config is included. It provides a quick way to bring a Graylog testing instance online. The Rails app is configured to log to this Graylog instance in addition to the standard Rails logging.
