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

    # Create a new Record. Takes two parameters: a Connection object so the
    # record can perform further requests, and an optional default value for
    # the value hash
    def initialize(connection, values = {})
      @connection = connection
      @values = values
    end

    # Pass requests to store by default.
    def method_missing(meth, *args)
      if @values.include? meth.to_s
        @values[meth.to_s]
      end
    end
  end
end
