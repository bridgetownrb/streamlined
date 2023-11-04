# frozen_string_literal: true

require "serbea/helpers" # primarily just for HTML safety polyfill
require "serbea/pipeline"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Streamlined
  class Error < StandardError; end
end

if defined?(Bridgetown)
  Bridgetown.initializer :streamlined do # |config|
  end
end
