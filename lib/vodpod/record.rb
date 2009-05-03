module Vodpod
  # Represents a generic Vodpod API record.
  class Record
    attr_accessor :store

    def initialize(connection, params = {})
      @connection = connection
      @store = params

      self.load!
    end

    # Pass requests to store by default.
    def method_missing(meth, *args)
      if @store.include? meth.to_s
        @store[meth.to_s]
      end
    end
  end
end
