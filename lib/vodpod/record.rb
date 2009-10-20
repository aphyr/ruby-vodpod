module Vodpod
  # Represents a generic Vodpod API record.
  #
  # Vodpod objects like Video, Pod, and Tag inherit from this class. It wraps a
  # store (usually the deserialized JSON hash from an API call) with automatic
  # accessors, so you can call video.title instead of video.store['title'].
  # Records are instantiated with a connection object and a default store of an
  # empty hash. 
  class Record
    attr_accessor :values

    def self.casters
      @casters ||= {}
    end

    # Association metaprogramming!
    def self.cast(name, opts = {})
      # Total hack :)
      opts[:class] ||= name.to_s.sub(/s$/, '').capitalize
      casters[name] = opts
    end

    # The given attribute is casted to a DateTime
    def self.date(name, opts = {})
      cast name, opts.merge(:type => :parse, :class => DateTime)
    end

    def self.one(name, opts = {})
      cast name, opts.merge(:type => :one)
    end

    def self.many(name, opts = {})
      cast name, opts.merge(:type => :many)
    end

    # Create a new Record. Takes two parameters: a Connection object so the
    # record can perform further requests, and an optional default value for
    # the value hash
    def initialize(connection, values = {})
      @connection = connection
      @values = values

      self.class.casters.each do |name, cast|
        if values = @values[name.to_s]
          # Lazily load classes
          unless cast[:class].kind_of? Class
            cast[:class] = Vodpod.const_get(cast[:class])
          end

          # Convert sub-values to objects
          @values[name.to_s] = case cast[:type]
          when :one
            cast[:class].new(@connection, values)
          when :many
            values.map do |value|
              cast[:class].new(@connection, value)
            end
          when :parse
            cast[:class].parse(values)
          end
        end
      end
    end

    def ==(other)
      self.class == other.class and self.key == other.key rescue false
    end

    # Pass requests to store by default.
    def method_missing(meth, *args)
      if @values.include? meth.to_s
        @values[meth.to_s]
      end
    end
  end
end
