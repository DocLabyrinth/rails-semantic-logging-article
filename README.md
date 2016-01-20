# Semantic Logging in Rails

This repo has some example code to get semantic logging working with rails.

Two gems are used:

* [lograge](https://github.com/roidrage/lograge)
* [semantic_logger](https://github.com/rocketjob/rails_semantic_logger)

These two gems in theory have the same function: to quickly add semantic logging in some form to a Rails project. Both gems have downsides so this repo includes a small bit of code how to glue them together and get the best of both worlds (plus ActiveRecord support).

The interesting stuff is in [the logging initializer](config/initializers/semantic_logging.rb)
