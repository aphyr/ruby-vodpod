#!/usr/bin/env ruby
require 'rubygems'
require 'bacon'
require File.join(File.dirname(__FILE__), '../lib/vodpod')

Bacon.summary_on_exit

module Vodpod
  describe 'Vodpod' do
    before do
      @v = Vodpod.start :api_key => ARGV.first
    end

    should 'detect errors' do
      should.raise(Error) do
        @v.get(:me)
      end
    end

    should 'check whether the connection is available' do
      @v.should.be.ready
      p @v.ready?
    end

    should 'show myself' do
      @v.me
    end
  end
end
