$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'banco_central'

require 'active_support'
require 'active_support/test_case'
require 'minitest/autorun'
require 'mocha/mini_test'
require "minitest/reporters"

Minitest::Reporters.use!
