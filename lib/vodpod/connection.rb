module Vodpod
  # Connection to vodpod.com; retreives JSON data and handles API key/auth.
  class Connection

    attr_accessor :api
    attr_accessor :auth

    # Creates a new connection. Parameters:
    #
    # :api_key => API key
    # :auth => Auth key
    def initialize(params = {})
      @api_key = params[:api_key]
      @auth = params[:auth]
    end

    # Request via GET
    def get(*paths, params = {})
      request :get, *paths, params
    end
 
    # Returns a pod by ID.
    def pod(id)
      Pod.load(self, 'pod_id' => id)
    end

    # Request via POST
    def post(*paths, params = {})
      request :post, *paths, params
    end

    # Perform a JSON request to the Vodpod API for a given path and parameter
    # hash. Returns a parsed JSON document. Automatically provides api_key and
    # auth params if you do not specify them. Method should be one of :get or
    # :post--you should use the #get or #post methods for convenience. Array
    # values for parameters are joined by commas.
    #
    # Example
    #   request :get, :users, :aphyr, :include => [:name]
    def request(method, *paths, params = {})
      defaults = {
        :api_key => @api_key,
        :auth => @auth
      }

      # Join path fragments
      path = Vodpod::BASE_URI + paths.map{|e| Vodpod::escape(e)}.join('/') +
        '.json'
      
      # Construct query fragment
      query = defaults.merge(params).inject('?') { |s, (k, v)|
        if v.kind_of? Array
          v = v.join(',')
        end
        s << "#{Vodpod::escape(k)}=#{Vodpod::escape(v)}&"
      }[0..-2]

      begin
        # Get URI
        case method
        when :get
          # GET request
          uri = URI.parse(path + query)
          res = Net::HTTP.get(uri)
        when :post
          # POST request
          uri = URI.parse(path)
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.post(uri.path, query[1..-1]).body
          end
        else
          # Don't know how to do that kind of request
          raise Error.new("Unsupported request method #{method.inspect}; should be one of :get, :post.")
        end
      rescue => e
        raise Error.new("Error retrieving #{uri.path}#{query}: #{e.message}")
      end

        # Parse response as JSON
        begin
          data = JSON.parse res
        rescue => e
          raise Error, "server returned invalid json: #{e.message}" + "\n\n" + res
        end

        data
      end
    end

    # Searches for videos. Optionally specify :per_page and :page.
    def search(query, params = {})
      list = get('video/search', params.merge(:query => query))['videos']['items']
      return [] unless list

      # Map results to Videos
      list.map do |item|
        # These results use Video.1234... as the ID, so we need to strip.
        store = item['video']
        store['video_id'] = store['video_id'].sub(/^Video\./, '').to_i
        Video.new(self, store)
      end
    end

    # Returns a user by ID.
    def user(id)
      User.new(self, 'user_id' => id)
    end

    # Returns a video by ID.
    def video(id)
      Video.load(self, 'video_id' => id)
    end
  end
end
