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

    # Perform a JSON request to the Vodpod API for a given path and parameter
    # hash. Returns a parsed JSON document. Automatically provides api_key and
    # auth params if you do not specify them.
    def get(path, params = {})
      defaults = {
        :api_key => @api_key,
        :auth => @auth
      }

      # Construct query fragment
      query = defaults.merge(params).inject('?') { |s, (k, v)|
        s << "#{Vodpod::escape(k)}=#{Vodpod::escape(v)}&"
      }[0..-2]

      # URI to fetch
      uri = URI.parse(Vodpod::BASE_URI + path + '.js' + query)

      begin
        # Get URI
        JSON.parse Net::HTTP.get(uri)
      rescue => e
        raise Error.new("Error retrieving #{uri}: #{e.message}")
      end
    end

    # Searches for videos. Optionally specify :per_page and :page.
    def search(query, params = {})
      list = get('video/search', params.merge(:query => query))['videos']['items']
      pp list
      list.map do |item|
        Video.new(self, item['video'])
      end
    end

    # Returns a pod by ID.
    def pod(id)
      Pod.new(self, 'pod_id' => id)
    end
  end
end
