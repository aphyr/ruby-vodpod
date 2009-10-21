module Vodpod
  # A video.
  class CollectionVideo < Record
    one :collection
    many :collection_comments
    many :comments
    date :created_at
    many :tags
    one :user
  end
end
