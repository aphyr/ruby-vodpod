#!/usr/bin/env ruby
require 'rubygems'
require 'bacon'
require File.join(File.dirname(__FILE__), '../lib/vodpod')

Bacon.summary_on_exit

unless API_KEY = ARGV.first
  raise ArgumentError, "usage: test.rb <api_key>"
end

module Vodpod
  describe 'Vodpod' do
    before do
      @v = Vodpod.start :api_key => API_KEY
    end

    should 'detect errors' do
      should.raise(Error) do
        @v.get(:foo)
      end
    end

    should 'check whether the connection is available' do
      @v.should.be.ready
    end

    should 'find myself' do
      # CAN HAS USER
      ur = @v.me :include => [:created_at, :collection]
      ur.name.should.not.be.empty
    end

    should 'cast associated objects' do
      @v.me(:include => :collection).collection.should.be.kind_of Collection
    end

    should 'cast datetimes' do
      @v.me(:include => [:created_at]).created_at.should.be.kind_of DateTime
    end

    should 'get videos' do
      v = @v.video 2336393, :include => :comments
      v.title.should =~ /Queer and Loathing/
      v.comments.should.not.be.empty
      v.comments.first.text.should.not.be.empty
      v.comments.first.user.should.not.be.nil
    end

    should 'get users' do
      u = @v.user 'aphyr', :include => :followers
      u.followers.should.not.be.empty
      u.key.should == 'aphyr'
    end
  end
end
