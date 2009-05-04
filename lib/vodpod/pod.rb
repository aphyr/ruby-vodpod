module Vodpod
  # Represents a pod.
  class Pod < Record
    # Administrative users
    def admins
      if items = @store['users']['admins']
        case items
        when {}
          # No results
          []
        when Array
          # More than one result
          items.map do |item|
            User.new(@connection, item['user'])
          end
        else
          # One result
          [User.new(@connection, items['user'])]
        end
      else
        []
      end
    end

    # Following users
    def followers
      if items = @store['users']['followers']
        case items
        when {}
          # No results
          []
        when Array
          # More than one result
          items.map do |item|
            User.new(@connection, item['user'])          
          end
        else
          # One result
          [User.new(@connection, items['user'])]
        end
      else
        []
      end
    end

    # Loads information for this pod from the API.
    def load!
      if pod_id
        @store.merge! @connection.get('pod/details', :pod_id => pod_id)["pod"]
      end
    end

    # Posts a new video to a pod. Returns the video posted.
    # 
    # Optional parameters:
    #   :title       => 'Cats with captions!'
    #   :description => 'Ahh the internet...'
    #   :tags        => 'foo bar baz' or ['foo', 'bar', 'baz']
    def post(url, params = {})
      new_params = params.merge(
        :pod_id => @store['pod_id'],
        :url => url
      )
      # Convert tags to string if necessary
      if new_params[:tags].kind_of? Array
        new_params[:tags] = new_params[:tags].join(' ')
      end

      # Post
      Video.new(@connection.post('video/post', new_params)['video'])
    end
    
    # Searches for videos. Optionally specify :per_page and :page.
    def search(query, params = {})
      # Get list of videos
      params = params.merge(:pod_id => @store['pod_id'], :query => query)
      list = @connection.get('pod/search', params)['videos']['items']

      return [] unless list

      # Map results to Videos
      list.map do |item|
        store = item['video']
        #store['video_id'].sub!(/^Video\./, '')
        Video.new(@connection, store)
      end
    end

    # Returns an array of Tags associated with this pod, by frequency of use.
    def tags
      list = @connection.get('pod/tags', :pod_id => pod_id)['tags']['items']
      list.map do |item|
        Tag.new(@connection, item['t'])
      end
    end

    # Returns the associated user for this pod.
    def user
      return nil unless @store['user']

      User.new(@connection, @store['user'])
    end

    # Videos in a pod. You can use :sort, :per_page, :page, and :tag_id to
    # paginate and filter.
    def videos(params = {})
      # Get list of videos
      params = params.merge(:pod_id => @store['pod_id'])
      list = @connection.get('pod/videos', params)['videos']['items']

      return [] unless list      

      # Map to objects
      list.map do |item|
        Video.new(@connection, item['video'])
      end
    end
  end
end
