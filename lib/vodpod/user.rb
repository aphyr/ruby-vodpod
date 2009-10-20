module Vodpod
  # A Vodpod user, associated with a pod and with videos.
  class User < Record
    one  :collection
    many :collections
    date :created_at
    many :followers, :class => User
    many :following, :class => User
    many :tags
    date :updated_at
    many :videos
  end
end
