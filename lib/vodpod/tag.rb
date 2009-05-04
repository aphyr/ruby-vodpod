module Vodpod
  # A Tag, attached to a video. There isn't a way yet to go from tags to videos
  # that I'm aware of, but it might happen in the future.
  class Tag < Record
    def inspect
      "<Vodpod::Tag #{@store['_value']} (#{count})>"
    end

    def to_s
      @store['_value']
    end
  end
end
