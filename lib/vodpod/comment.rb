module Vodpod
  # A comment on a video or collectionvideo.
  class Comment < Record
    date :created_at
    one :user
  end
end
