require "banco_central/version"
require "savon"
require "yaml"

# BancoCentral.last(:ipca)
# BancoCentral.all(:ipca)
# BancoCentral.all(:ipca, start: "1/7/2014")
# BancoCentral.all(:ipca, finish: "1/8/2014")
# BancoCentral.all(:ipca, start: "1/7/2014", finish: "1/8/2014")
# BancoCentral.all([:importacoes, :exportacoes])
# BancoCentral.find(:dolar, date: "3/7/2014")
# BancoCentral::LABELS
module BancoCentral

  CONFIG    = YAML.load_file(File.join File.dirname(__dir__), "config/labels.yml")

  WSDL_URI  = CONFIG["wsdl_uri"]

  LABELS    = CONFIG["labels"]

  class << self

    def find(id, date, log_level: nil, logger: nil)
      client(log_level, logger).call(
        :get_valor,
        message: {
          in0: get_id(id),
          in1: date
        }
      ).to_hash[:multi_ref].to_f
    end

    def last(id, log_level: nil, logger: nil)
      xml = client(log_level, logger).call(
        :get_ultimo_valor_xml,
        message: {
          in0: get_id(id)
        }
      ).to_hash[:get_ultimo_valor_xml_response][:get_ultimo_valor_xml_return]

      # Prevent exception when parsing if indicator's name has the & character
      xml.gsub!(/&(?!(?:amp|lt|gt|quot|apos);)/, '&amp;')

      hash = Nori.new.parse(xml)["resposta"]["SERIE"]

      {
        id: get_id(id),
        name: hash["NOME"],
        unit: hash["UNIDADE"],
        date: parse_date(hash["DATA"]),
        value: parse_value(hash["VALOR"]),
        periodicity: parse_periodicity(hash["PERIODICIDADE"])
      }
    end

    # BancoCentral.all([:ipca], start: "1/7/2014")
    def all(id, start: nil, finish: nil, log_level: nil, logger: nil)

      # Build request arguments
      ids = id.is_a?(Array) ? id : [id]
      args = {}
      ids.each_with_index do |_id, i|
        args["ins#{i}:int"] = get_id(_id)
      end

      # Request the WebService
      xml = client(log_level, logger).call(
        :get_valores_series_xml,
        message: {
          in0: args,
          in1: start,
          in2: finish
        }
      ).to_hash[:get_valores_series_xml_response][:get_valores_series_xml_return]

      # Convert response XML to a hash (for one id) or a hash of hashes (more than one id)
      doc = Nokogiri::XML(xml) { |config| config.noblanks }
      data = {}
      doc.css("SERIE").each do |serie|
        array = serie.css("DATA, VALOR").map(&:text)
        data[serie["ID"].to_i] = Hash[array.each_slice(2).to_a]
      end

      id.is_a?(Array) ? data : data[get_id(id)]
    end

    private

      def client(log_level = nil, logger = nil)
        options = {
          encoding: "UTF-8",
          ssl_verify_mode: :none,
          wsdl: WSDL_URI
        }
        if log_level
          options[:log] = true
          options[:log_level] = log_level # one of [:debug, :info, :warn, :error, :fatal]
          options[:logger] = logger if logger
        end
        Savon.client(options)
      end

      def get_id(id)
        return id if id.is_a? Integer
        LABELS[id.to_s] || raise(ArgumentError, 'Label not found')
      end

      def parse_periodicity(periodicity)
        {"D" => :daily, "M" => :monthly, "T" => :quarterly, "A" => :yearly}[periodicity]
      end

      def parse_date(date)
        Time.new(date["ANO"], date["MES"], date["DIA"])
      end

      def parse_value(value)
        value.gsub(",", ".").to_f
      end

  end

end
