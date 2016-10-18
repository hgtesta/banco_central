# BancoCentral

A handy Ruby library to consume Central Bank of Brazil (Banco Central do Brasil) WebService. The WebService provided by the BC has lots of updated economic indicators, but it fails short in documentation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'banco_central'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banco_central

## Usage

### last

Get the last value of the IPCA inflation indicator. This method calls `GetUltimoValorXml` method from the WebService.

```ruby
BancoCentral.last(:ipca)
```

### find

Get the indicator's value for a specific date. This method calls `GetValor` method from the WebService.

```ruby
BancoCentral.find(:ipca, "1/1/2010")
```

### all

Get all the values of the indicator. This method calls `GetValoresSeriesXMLResponse` method from the WebService.

```ruby
BancoCentral.all(:ipca)
```

You can also specify an initial or final date:

```ruby
BancoCentral.last(:ipca, start: "1/1/2010")
BancoCentral.last(:ipca, finish: "1/5/2015")
BancoCentral.last(:ipca, start: "1/1/2013", finish: "1/12/2013")
```

### Logging

It is possible to specify the log level with `:log_level` option. Valid values are `:fatal`, `:error`, `:warn`, `:info`, `:debug`. In practice, the log level will affect the output of Savon calls.
```ruby
BancoCentral.all(:ipca, log_level: :debug)
```

The default logger is STDOUT. To use a different one just use the `:logger` option.
```ruby
BancoCentral.all(:ipca, log_level: :debug, logger: @logger)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hgtesta/banco_central. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

