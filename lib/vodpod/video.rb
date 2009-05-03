module Vodpod
  # A video
  class Video < Record
    # Loads information on this video by video_id
    def load!
      if video_id
        @store.merge! @connection.get('video/details', :video_id => video_id)["video"]
      end
    end
  end
end
