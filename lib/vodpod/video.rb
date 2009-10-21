module Vodpod
  # A video.
  class Video < Record
    many :collections
    many :comments
    date :created_at
    many :tags
    date :updated_at
    many :users
  end
end
