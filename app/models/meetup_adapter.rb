class MeetupAdapter

  def events(group_id)
    Rails.cache.fetch([:meetup, :events, group_id], expires_in: 12.hours) do
      client = MeetupAdapter::Client.new
      client.events(group_id)
    end
  end

  def event(group_id, event_id)
    events(group_id).detect(&it['id'] == event_id)
  end

  def rsvps(group_id, event_id)
    Rails.cache.fetch([:meetup, :rsvp, group_id, event_id], expires_in: 10.minutes) do
      client = MeetupAdapter::Client.new
      client.rsvps(
        url_name: group_id,
        event_id: event_id
      )
    end
  end

  class Client
    attr_reader :token, :redirect_uri

    def initialize(redirect_uri: 'http://localhost:3000/oauth2/callback')
      token_record = MeetupAccessToken.last
      @token = OAuth2::AccessToken.from_hash(oauth_client, token_record.data) if token_record
      @redirect_uri = redirect_uri
    end

    def auth_url
      oauth_client.auth_code.authorize_url(
        redirect_uri: redirect_uri,
        scope: 'ageless basic'
      )
    end

    def token_from_code(code)
      @token = oauth_client.auth_code.get_token(code, redirect_uri: redirect_uri)
      persist_token!
    end

    def rsvps(url_name:, event_id:, params: {})
      get "/#{url_name}/events/#{event_id}/rsvps", params
    end

    # events 'Ruby-On-Rails-Oceania-Melbourne'
    def events(url_name, params = {})
      get "/#{url_name}/events", params
    end

    private

    def get(path, params = {})
      refresh_token! if token.expired?

      token.get('https://api.meetup.com/' + path, params: params).parsed
    end

    def post(path, params = {})
      refresh_token! if token.expired?

      token.post('https://api.meetup.com/' + path, params: params).parsed
    end

    def oauth_client
      @oauth_client ||= OAuth2::Client.new(ENV['MEETUP_CLIENT_ID'], ENV['MEETUP_SECRET'],
        site: 'https://secure.meetup.com/',
        authorize_url: '/oauth2/authorize',
        token_url: '/oauth2/access',
      )
    end

    def refresh_token!
      @token = token.refresh!
      persist_token!
    end

    def persist_token!
      local_token = token

      Thread.new do
        MeetupAccessToken.all.last&.destroy!
        MeetupAccessToken.create! data: local_token.to_hash
      end.join

      nil
    end
  end
end
