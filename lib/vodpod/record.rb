module Vodpod
  # Represents a generic Vodpod API record.
  class Record
    attr_accessor :store

    # Like Record.new, but also calls load!
    def self.load(*params)
      record = new(*params)
      record.load! if record.respond_to? :load!
      record
    end

    def initialize(connection, params = {})
      @connection = connection
      @store = params
    end

    # Pass requests to store by default.
    def method_missing(meth, *args)
      if @store.include? meth.to_s
        @store[meth.to_s]
      end
    end
  end
end
