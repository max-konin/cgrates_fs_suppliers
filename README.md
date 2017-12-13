# CGrates fs suppliers

## Requirements
* ruby (>= 2.3.0)
* bundler

## Installation
* install ruby
* install bundler `gem install bundler`
* clone this repo
* in repo dir: `bundle install --without development test --deployment --quiet`
* edit config.yml

## Run

Foreground:

`ruby bin/server.rb`

Daemon:

* Start `ruby bin/daemon.rb start`
* Stop `ruby bin/daemon.rb stop`
* Status `ruby bin/daemon.rb status`
* Restart `ruby bin/daemon.rb restart`

## Testing
`rspec spec`
