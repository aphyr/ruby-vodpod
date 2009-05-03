module Vodpod
  # Represents a pod.
  class Pod < Record
    # Actually loads information for this pod.
    def load!
      if pod_id
        @store.merge! @connection.get('pod/details', :pod_id => pod_id)["pod"]
      end
    end

    # Returns an array of Tags associated with this pod, by frequency of use.
    def tags
      list = @connection.get('pod/tags', :pod_id => pod_id)['tags']['items']
      list.map do |item|
        Tag.new(@connection, item['t'])
      end
    end
  end
end
