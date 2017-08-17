# BancoCentral

A simple gem library to fetch social and economic indicators from the Central Bank of Brazil (Banco Central do Brasil) WebService. It fires a SOAP request behind the scenes and parse the result for easy use.

The WebService provided by the BC has lots of updated social and economic indicators, but unfortunately it lacks documentation. You can learn more on the site below.

https://www3.bcb.gov.br/sgspub/

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

Get the last value of the an indicator, and also the name, unit, date and periodicity. This method calls `GetUltimoValorXml` method from the WebService.

```ruby
BancoCentral.last(:dolar)
# => {
#  :id=>1, 
#  :name=>"Taxa de câmbio - Livre - Dólar americano (venda) - diário",
#  :unit=>"u.m.c./US$",
#  :date=>2016-10-18 00:00:00 -0200,
#  :value=>3.1874,
#  :periodicity=>:daily
# }
```

Note that `:dolar` is a convenient label that is translated to a number before the WebService call. There are thousands of indicators, some deprecated, but just a few dozen labels. The code below is the equivalent of the above one.

```ruby
BancoCentral.last(1)
```

Check `BancoCentral::Labels` for a list of available labels, or take a look at the config/labels.yml file. A list of all indicators is available at http://hique.org/indicators.txt

### find

Get the indicator's value for a specific date. It calls `GetValor` method from the WebService and returns only a float number.

```ruby
BancoCentral.find(:ipca, "1/1/2010")
# => 0.75
```

### all

Get all the values of the indicator. This method calls `GetValoresSeriesXMLResponse` method from the WebService.

```ruby
BancoCentral.all(:ipca)
# => {"1/1980"=>"6.62", "2/1980"=>"4.62", "3/1980"=>"6.04", ...
```

You can also specify an initial or final date:

```ruby
BancoCentral.all(:ipca, start: "1/1/2010")
BancoCentral.all(:ipca, finish: "1/5/2015")
BancoCentral.all(:ipca, start: "1/1/2013", finish: "1/12/2013")
```

It is also possible to ask for multiple indicators in the same request. In that case, the result hash will contain a hash for each indicator.
```ruby
BancoCentral.all([:importacoes, :exportacoes])
# => {2946=>{"1/2000"=>"3453879475", "2/2000"=>"4124889858", ...},
#     3034=>{"1/2000"=>"3568862639", "2/2000"=>"4046750398", ...}}
```

The indicators must have the same periodicity.

### Logging

To specify the log level set the `log_level` attribute. Valid values are `:fatal`, `:error`, `:warn`, `:info`, `:debug`. In practice, it will affect the output of Savon calls.
```ruby
BancoCentral.log_level = :debug
```

The default logger is STDOUT. To use a different one just set the `:logger` attribute.
```
BancoCentral.logger = @logger
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hgtesta/banco_central. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

