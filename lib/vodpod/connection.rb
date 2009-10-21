module Vodpod
  # Connection to vodpod.com; retreives JSON data and handles API key/auth.
  class Connection
    TIMEOUT = 5
    attr_accessor :api
    attr_accessor :auth

    # Creates a new connection. Parameters:
    #
    # :api_key => API key
    # :auth_key => Auth key
    # :timeout => How many seconds to wait before giving up on API calls.
    def initialize(params = {})
      @api_key = params[:api_key]
      @auth_key = params[:auth_key]
      @timeout = params[:timeout] || TIMEOUT
    end

    # Gets a collection by user and collection key.
    def collection(user, collection, *args)
      Collection.new self, get(:users, user, :collections, collection, *args)
    end

    # Request via GET
    def get(*args)
      request :get, *args
    end
 
    # Returns the user associated with this API key.
    def me(*args)
      User.new self, get(:me, *args)
    end

    # Request via POST
    def post(*args)
      request :post, *args
    end

    # Pings the API with our API key to check whether or not we are ready to
    # make requests.
    def ready?
      get or false
    end

    # Perform a JSON request to the Vodpod API for a given path and parameter
    # hash. Returns a parsed JSON document. Automatically provides api_key and
    # auth params if you do not specify them. Method should be one of :get or
    # :post--you should use the #get or #post methods for convenience. Array
    # values for parameters are joined by commas.
    #
    # Example
    #   request :get, :users, :aphyr, :include => [:name]
    def request(method, *args)
      defaults = {
        :api_key => @api_key,
        :auth_key => @auth
      }

      # Get parameters
      if args.last.kind_of? Hash
        params = args.pop
      else
        params = {}
      end

      # Construct query fragment
      query = defaults.merge(params).inject('?') { |s, (k, v)|
        if v.kind_of? Array
          v = v.join(',')
        end
        s << "#{Vodpod::escape(k)}=#{Vodpod::escape(v)}&"
      }[0..-2]

      # Join path fragments
      path = Vodpod::BASE_URI + args.map{|e| Vodpod::escape(e)}.join('/') + '.json'

      begin
        # Get URI
        case method
        when :get
          # GET request
          uri = URI.parse(path + query)
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.open_timeout = @timeout
            http.read_timeout = @timeout
            http.get(uri.path + query)
          end
        when :post
          # POST request
          uri = URI.parse(path)
          res = Net::HTTP.start(uri.host, uri.port) do |http|
            http.open_timeout = @timeout
            http.read_timeout = @timeout
            http.post(uri.path, query[1..-1])
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
        data = JSON.parse res.body
      rescue => e
        raise Error, "server returned invalid json: #{e.message}" + "\n\n" + res
      end

      # Check for errors
      if data[0].false?
        raise Error, data[1]['message']
      end

      # Return data section
      data[1]
    end

    # Gets a user by key
    def user(key, *args)
      User.new self, get(:users, key, *args)
    end

    # Retrieves a specific video by key.
    # Three senses:
    #
    # 1. video(video) => Video
    # 2. video(user, video) => CollectionVideo
    # 2. video(user, collection, video) => CollectionVideo
    #
    # Which sense is determined by the index of the integer video key, so
    # you can safely chain calls like:
    #
    #   video(123, :comments, :page => 2)
    #
    # to get the 2nd page of comments associated with the video.
    def video(*args)
      key = args.find { |e| Integer === e }
      i = args.index(key)
      
      case i
      when 0
        Video.new self, get(:videos, *args)
      when 1
        CollectionVideo.new self, get(:users, args.shift, :videos, *args)
      when 2 
        CollectionVideo.new self, get(:users, args.shift, :collections, args.shift, :videos, *args)
      else
        raise ArgumentError, "usage: video(video), video(user, video), video(user, collection, video)"
      end
    end

    # Gets a list of videos
    # Three senses:
    #
    # 1. videos() => An array of Videos
    # 2. videos(user) => An array of CollectionVideos
    # 3. videos(user, collection) => An array of CollectionVideos
    #
    # The sense is determined by the number of arguments before a hash (or if
    # no options hash is given, the number of arguments).
    def videos(*args)
      opts = args.find { |e| Hash === e }
      i = args.index(opts) || args.size
      case i
      when 0
        RecordSet.new self, Video, get(:videos, *args)
      when 1
        RecordSet.new self, CollectionVideo, get(:users, args.shift, :videos, *args)
      when 2
        RecordSet.new self, CollectionVideo, get(:users, args.shift, :collections, args.shift, :videos, *args)
      else
        raise ArgumentError, "usage: videos(), videos(user), videos(user, collection)"
      end
    end
  end
end
