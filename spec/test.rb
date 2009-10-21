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


    should 'get a user' do
      u = @v.user :aphyr, :include => :followers
      u.followers.should.not.be.empty
      u.followers.first.should.be.kind_of User
      u.key.should == 'aphyr'
    end

    should 'get a collection' do
      c = @v.collection :aphyr, :aphyr, :include => :videos
      c.videos.should.not.be.empty
      c.videos.first.should.be.kind_of CollectionVideo
      c.videos_count.should.be > 10
      c.key.should == 'aphyr'
    end
   
    should 'get a users collections' do
      cs = @v.collections :aphyr
      cs.should.not.be.empty?
      cs.first.should.be.kind_of Collection
      cs.any? { |c| c.key == 'aphyr' }.should.be.true
    end

    should 'get a video' do
      v = @v.video 2336393, :include => :comments
      v.title.should =~ /Queer and Loathing/
      v.comments.should.not.be.empty
      v.comments.first.text.should.not.be.empty
      v.comments.first.user.should.not.be.nil
    end
   
    should 'get a user video' do
      v = @v.video :aphyr, 2336393
      v.should.be.kind_of CollectionVideo
      v.title.should =~ /Queer and Loathing/
    end

    should 'get a collection video' do
      v = @v.video 'aphyr', 'aphyr', 2336393
      v.should.be.kind_of CollectionVideo
      v.title.should =~ /Queer and Loathing/
    end

    should 'get a list of videos' do
      vs = @v.videos :tags => 'awesome', :include => :tags
      vs.total.should > vs.size
      vs.each do |v|
        v.tags.any? { |t| t.name == 'awesome' }.should.be.true
      end
    end

    should 'get a list of videos for a user' do
      vs = @v.videos :aphyr, :tags => 'awesome', :include => :tags
      vs.each do |v|
        v.tags.any? { |t| t.name == 'awesome' }.should.be.true
      end
    end

    should 'get a list of videos in a users collection' do
      vs = @v.videos :aphyr, :aphyr, :tags => 'awesome', :include => :tags
      vs.each do |v|
        v.tags.any? { |t| t.name == 'awesome' }.should.be.true
      end
    end

    should 'search for videos' do
      vs = @v.search 'ultimate frisbee', :include => :tags
      vs.should.not.be.empty
      vs.first.should.be.kind_of Video
      vs.first.tags.should.be.kind_of Array
    end
  end
end
