module Vodpod
  # A Tag, attached to a video.
  class Tag < Record
    many :collection_videos, :class => 'CollectionVideo'
    many :collections
    many :users
    many :videos
  end
end
