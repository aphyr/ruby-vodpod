module Vodpod
  # A video.
  class Video < Record
    # Loads information on this video by video_id
    def load!
      if video_id
        @store.merge! @connection.get('video/details', :video_id => video_id)["video"]
      end
    end

    def to_s
      @store['title']
    end

    # Update the title, description, and/or tags for this video. Returns
    # the updated video. Seems to create video records okay, but they aren't
    # viewable and don't appear in collections for editing immediately.
    def update(params)
      new_params = params.merge(
        :video_id => @store['video_id']
      )

      # Post
      Video.new(@connection.post('video/update', new_params)['video'])
    end

    # Returns the User for this video.
    def user
      return nil unless @store['user']

      User.new(@connection, @store['user'])
    end
  end
end
