module Vodpod
  class Tag < Record
    def inspect
      "<Vodpod::Tag #{@store['_value']} (#{count})>"
    end

    def to_s
      @store['_value']
    end
  end
end
