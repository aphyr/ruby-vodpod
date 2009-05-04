#!/usr/bin/ruby

# Vodpod API bindings for Ruby

require 'rubygems'
require 'json'
require 'uri'
require 'net/http'

module Vodpod
  BASE_URI = 'http://api.vodpod.com/api/'
  ROOT = File.dirname(__FILE__)

  # Load library
  require "#{ROOT}/vodpod/version"
  require "#{ROOT}/vodpod/error"
  require "#{ROOT}/vodpod/connection"
  require "#{ROOT}/vodpod/record"
  require "#{ROOT}/vodpod/user"
  require "#{ROOT}/vodpod/tag"
  require "#{ROOT}/vodpod/pod"
  require "#{ROOT}/vodpod/video"

  # Performs URI escaping so that you can construct proper
  # query strings faster.  Use this rather than the cgi.rb
  # version since it's faster.  (Stolen from Camping).
  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      '%'+$1.unpack('H2'*$1.size).join('%').upcase
    }.tr(' ', '+')
  end
  module_function :escape

  # Creates a connection with the provided parameter hash, and yields it in a
  # block. Example:
  #
  #   Vodpod.start(:api_key => api_key, :auth => auth) do |v|
  #     pod = v.pod('aphyr')
  #     p pod.created_at
  #   end
  def self.start(params)
    yield Connection.new(params) 
  end
end
