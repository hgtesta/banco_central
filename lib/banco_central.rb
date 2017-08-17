# frozen_string_literal: true

require 'banco_central/version'
require 'savon'
require 'yaml'

# Fetch social and economic indicators from the Central Bank of Brazil
# (Banco Central do Brasil) WebService. It fires a SOAP request behind
# the scenes and parse the result for easy use.
module BancoCentral

  CONFIG   = YAML.load_file(File.join(File.dirname(__dir__), 'config/labels.yml'))
  WSDL_URI = CONFIG['wsdl_uri']
  LABELS   = CONFIG['labels']

  class << self

    attr_accessor :log_level
    attr_accessor :logger

    # Get the indicator's value for a specific date. It calls +GetValor+ method
    # from the WebService and returns only a float number.
    #
    #   BancoCentral.find(:dolar, "3/7/2014")
    #   => 0.75
    def find(id, date)
      client.call(
        :get_valor,
        message: {
          in0: label_to_int(id),
          in1: date
        }
      ).to_hash[:multi_ref].to_f
    end

    # Get the last value of the an indicator, and also the name, unit, date and
    # periodicity. This method calls +GetUltimoValorXml+ method from the
    # WebService.
    #
    #   BancoCentral.last(:dolar)
    #   => {
    #    :id => 1,
    #    :name => "Taxa de câmbio - Livre - Dólar americano (venda) - diário",
    #    :unit => "u.m.c./US$",
    #    :date => 2016-10-18 00:00:00 -0200,
    #    :value => 3.1874,
    #    :periodicity => :daily
    #   }
    def last(id)
      indicator_xml = sanitize(last_as_xml(id))
      indicator = Nori.new.parse(indicator_xml)['resposta']['SERIE']
      {
        id: label_to_int(id),
        name: indicator['NOME'],
        unit: indicator['UNIDADE'],
        date: parse_date(indicator['DATA']),
        value: parse_value(indicator['VALOR']),
        periodicity: parse_periodicity(indicator['PERIODICIDADE'])
      }
    end

    # Get all the values of the indicator. This method calls
    # +GetValoresSeriesXMLResponse+ method from the WebService.
    #
    # This method accepts a string, symbol or an array of string or
    # symbols as indicator names. In case an array is given, it will
    # return a hash of hashes.
    #
    #   BancoCentral.all(:ipca)
    #   => {"1/1980"=>"6.62", "2/1980"=>"4.62", ... }
    #
    #   BancoCentral.all(:ipca, start: "1/7/2014", finish: "1/8/2014")
    #   => {"7/2014"=>"0.01", "8/2014"=>"0.25"}
    #
    #   BancoCentral.all([:importacoes, :exportacoes])
    #   => {
    #        2946 => {"1/1954"=>"122603000", "2/1954"=>"125851000", ...},
    #        3034 => {"1/1973"=>"370706000", "2/1973"=>"390279000", ...}
    #      }
    #
    def all(id, start: nil, finish: nil)
      indicators_xml = all_as_xml(id, start, finish)
      indicators_doc = Nokogiri::XML(indicators_xml, &:noblanks)

      # Convert response XML to a hash (for one id) or a hash of
      # hashes (for more than one id)
      indicators = {}
      indicators_doc.css('SERIE').each do |serie|
        array = serie.css('DATA, VALOR').map(&:text)
        indicators[serie['ID'].to_i] = Hash[array.each_slice(2).to_a]
      end

      id.is_a?(Array) ? indicators : indicators[label_to_int(id)]
    end

    private

    # Prevent exception when parsing if indicator's name has the & character
    def sanitize(indicator_name)
      indicator_name.gsub(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')
    end

    def client
      options = {
        encoding: 'UTF-8',
        ssl_verify_mode: :none,
        wsdl: WSDL_URI
      }
      if @log_level
        options[:log] = true
        options[:log_level] = @log_level
        options[:logger] = @logger if @logger
      end
      Savon.client(options)
    end

    def last_as_xml(id)
      client
        .call(
          :get_ultimo_valor_xml,
          message: {
            in0: label_to_int(id)
          }
        )
        .to_hash[:get_ultimo_valor_xml_response][:get_ultimo_valor_xml_return]
        .gsub("<?xml version='1.0' encoding='ISO-8859-1'?>\n", '')
    end

    def all_as_xml(id, start, finish)
      ids = id.is_a?(Array) ? id : [id]

      # Build SOAP request arguments
      args = {}
      ids.each_with_index do |indicator_id, i|
        args["ins#{i}:int"] = label_to_int(indicator_id)
      end

      # Request the WebService
      client
        .call(
          :get_valores_series_xml,
          message: {
            in0: args,
            in1: start,
            in2: finish
          }
        )
        .to_hash[:get_valores_series_xml_response][:get_valores_series_xml_return]
        .gsub("<?xml version='1.0' encoding='ISO-8859-1'?>\n", '')
    end

    def label_to_int(id)
      if id.is_a? Integer
        id
      else
        LABELS[id.to_s] || raise(ArgumentError, 'Label not found')
      end
    end

    def parse_periodicity(periodicity)
      {
        'D' => :daily,
        'M' => :monthly,
        'T' => :quarterly,
        'A' => :yearly
      }[periodicity]
    end

    def parse_date(date)
      Time.new(date['ANO'], date['MES'], date['DIA'])
    end

    def parse_value(value)
      value.tr(',', '.').to_f
    end
  end
end
