$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'banco_central'

require 'active_support'
require 'active_support/test_case'
require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use!
