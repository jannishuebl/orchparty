# Orchparty

Write your orchestration configuration with a Ruby DSL that allows you to have mixins, imports and variables.

## Why the Hell?

### 1. Powerfull Ruby DSL as a YAML replacement

Yaml is great when it comes to Configuration, it gives a clean syntax that is
build for humans, but is still maschine readable. For most of the
configurations it is good enough. It even supports features like referencing,
inheritence and multiline Strings. 

In our company we run a microservcie architecture with multiple applications,
that by themselves consits of multiple services (container types).
But what we have realizes was that our orchestration configuration grew and got
hell complex, which made globle changes like replacing our logging
infrastucture quite painfull, because we need to touch every single service.

Some features that we wanted to have:

  1. Mixin support
  1. Import from diffrent files
  1. Using Variables in imported config eg. Stack/Service names


Some of the features are build in YAML but were to complex for us to use.


### 2. Use Ruby instead of Templating engines

Most of the Orchestrationframeworks are using a docker-compose.yml derivat.
But what most of them realized is that yml is not enough for komplex
orchestration.

So most of the framework teams stated to allow a templatingengine in the
docker-compose configuration.

But why keep going with a data serialization language when we want to program
our configuration anyway?

### 3. Have one config for multiple Orchestrationframeworks

How much effort is it to get a application running on an
Orchestrationframeworks? We am glad when we find a prebuild docker-compose file
that we can modify eg. for kontena.io, but when we have done it for konena.io we
have to redo nearly all the work for rancher, kubernets etc.

It would be nice if people start to write the opensource application configs in
orchparty and we simple compile the config for all popular orchestrationframeworks.

## Installation

For installation it is nessery to have setup a ruby environment, at lease ruby
2.3 is needed.

Install from rubygems.org

    $ gem install orchparty

Maybe in the future it is possible to run it in a docker container, so no local
ruby environment is needed.

## Usage

See the commandline usage instrucution by running:

    $ orchparty help

## DSL spec

So lets do an example let us orchparty a beutiful app called [app_perf](https://github.com/randy-girard/app_perf) that is a
open source replacement of new relic !

### Applications

app_perf need a postgres to store data, redis for a queing system, a web
handler, where all metrics are send to, and a worker that process the metrics
and inserts them to the postgres db.

```ruby
application "app_perf" do

  service "web" do
    image "blasterpal/app_perf"
    command "bundle exec rails s -p 5000"
    expose 5000
    links do 
      link "redis"
      link "postgres"
    end
  end

  service "worker" do
    image "blasterpal/app_perf"
    command "bundle exec sidekiq"
    links do 
      link "redis"
      link "postgres"
    end
  end

  service "redis" do
    image "redis"
  end

  service "postgres" do
    image "postgres"
  end

end
```


### Applevel Mixins

But maybe we would want a production setup where we do not shipp a postgres
because we want to use an exteral services like RDS from AWS.

```ruby
mixin "app_perf" do

  service "web" do
    image "blasterpal/app_perf"
    command "bundle exec rails s -p 5000"
    expose 5000
    links do 
      link "redis"
    end
  end

  service "worker" do
    image "blasterpal/app_perf"
    command "bundle exec sidekiq"
    links do 
      link "redis"
    end
  end

  service "redis" do
    image "redis"
  end

end

application 'app_perf-dev' do
  mix "app_perf"

  service "web" do
    links do 
      link "postgres"
    end
  end

  service "worker" do
    links do 
      link "postgres"
    end
  end

  service "postgres" do
    image "postgres"
  end

end

application 'app_perf-prod' do
  mix "app_perf"

  service "web" do
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

  service "worker" do
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

end
```

### Servicelevel Mixin

But we might also mixin a logging config in production.

mixin "logging" do

  service "syslog" do
    logging do 
      conf driver: "syslog"
      options do
        opt syslog-address: "tcp://192.168.0.42:123"
      end
    end
  end

end


application 'app_perf-prod' do
  mix "app_perf"

  service "web" do
    mix "logging.syslog"
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

  service "worker" do
    mix "logging.fluentd"
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

end
```

### Commonblock

Maybe we want to add something to all services in one application. Of cause
this also adds the mix "logging.syslog" and environment variables to the redis and postgres service.

```ruby
application 'app_perf-prod' do
  mix "app_perf"

  all do
    mix "logging.syslog"
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

  service "web" do
  end

  service "worker" do
  end

end
```

### Variables

You want to use variables right? Becase DRY ;) well you can: 

```ruby
application "app_perf" do
  variables do
    var image: "blasterpal/app_perf"
  end

  service "web" do
    variables do
      # service local variables
    end
    image -> { image }
    command -> { "bundle exec rails s -p #{ service.expose }" }
    expose 5000
    links do 
      link "redis"
      link "postgres"
    end
  end

  service "worker" do
    image -> { image }
    command "bundle exec sidekiq"
    links do 
      link "redis"
      link "postgres"
    end
  end

  service "redis" do
    image "redis"
  end

  service "postgres" do
    image "postgres"
  end

end
```

special variables:

  1. service:
    - service.name
  1. application:
    - application.name

### Import

Above we assumend that everything is written in one file. If you donot want to
to that use the import feature.

```ruby
import "../logging.rb"
import "./app_perf.rb"

application 'app_perf-prod' do
  mix "app_perf"

  all do
    mix "logging.syslog"
    environment do
      env POSTGRES_HOST: "rds-domain.amazon.com"
    end
  end

end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`,
which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jannishuebl/orchparty.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [GNU Lesser General Public License v3.0](http://www.gnu.de/documents/lgpl-3.0.en.html).
