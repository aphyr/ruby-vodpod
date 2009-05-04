module Vodpod
  # A Vodpod user, associated with a pod and with videos.
  class User < Record
    # Returns recent activity by people related to this user. Not working
    # yet--maybe a Vodpod bug?
    def network_activity
      @connection.get('user/network_activity', :user_id => user_id)
    end

    def inspect
      if @store
        "<Vodpod::User #{@store['username']}>"
      else
        "<Vodpod::User>"
      end
    end

    def to_s
      @store['username']
    end
  end
end
