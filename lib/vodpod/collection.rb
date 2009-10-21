module Vodpod
  # A collection of videos.
  class Collection < Record
    date :created_at
    many :tags
    date :updated_at
    many :videos, :class => 'CollectionVideo'
  end
end
