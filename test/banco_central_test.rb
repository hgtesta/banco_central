require 'test_helper'
require_relative 'response_hashes'

# Workaround because we can't stub a method named "call" with Minitest.
# See https://github.com/seattlerb/minitest/issues/414 for details.

class Savon::Client
  def call(command, args)
    FakeResponse.new(command, args)
  end
end

class FakeResponse
  def initialize(command, args)
    @command = command
    @args = args
  end
  def to_hash
    {
      get_valor: HASH_FIND,
      get_ultimo_valor_xml: HASH_LAST,
      get_valores_series_xml: @args[:message][:in0].size > 1 ? HASH_ALL : HASH_ALL_MULTIPLE,
    }[@command]
  end
end

class BancoCentralTest < ActiveSupport::TestCase

  test "that it has a version number" do
    refute_nil ::BancoCentral::VERSION
  end

  test "get_id returns the id of the label" do
    out = BancoCentral.send(:get_id, :dolar)
    assert out, 1
  end

  test "get_id raise exception if label doesn't exist" do
    assert_raises ArgumentError do
      BancoCentral.send(:get_id, :diamond)
    end
  end

  test "get_id returns identical arg if it is not a symbol" do
    out = BancoCentral.send(:get_id, 433)
    assert out, 433
  end

  test "client returns a Savon client object" do
    out = BancoCentral.send(:client)
    assert_instance_of Savon::Client, out
  end

  test "find returns a Numeric" do
    out = BancoCentral.find(:ipca, "01/01/2015")
    assert out.is_a? Numeric
  end

  test "last returns a hash with parsed values" do
    out = BancoCentral.last(:ipca)
    assert out.is_a? Hash
    assert out[:id].is_a? Integer
    assert out[:name].is_a? String
    assert out[:unit].is_a? String
    assert out[:date].is_a? Time
    assert out[:value].is_a? Numeric
    assert out[:periodicity].is_a? Symbol
  end

  test "all returns a hash of values for a single id" do
    out = BancoCentral.all(:ipca, start: "01/01/2015", finish: "01/05/2015")
    assert out.is_a? Hash
    assert out.first.is_a? Array
  end

  test "all returns a hash with a hash for an array with a single id" do
    out = BancoCentral.all([:ipca], start: "01/01/2015", finish: "01/05/2015")
    assert out.is_a? Hash
    assert out.size, 1
    assert out[out.keys.first].is_a? Hash
  end

  test "all returns a hash of hashes of values for an array of ids" do 
    out = BancoCentral.all([:ipca, :igpm], start: "01/01/2015", finish: "01/05/2015")
    assert out.is_a? Hash
    assert out.size, 2
    assert out[out.keys.first].is_a? Hash
  end

end
