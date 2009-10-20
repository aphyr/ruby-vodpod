#!/usr/bin/env ruby
require 'rubygems'
require 'bacon'
require File.join(File.dirname(__FILE__), '../lib/vodpod')

module Vodpod
  describe 'Vodpod' do
    before do
      @v = Vodpod.start :api_key => ARGV.first
    end

    should 'connect to vodpod.com' do
      should.raise(Error) do
        @v.get(:me)
      end
    end
  end
end
