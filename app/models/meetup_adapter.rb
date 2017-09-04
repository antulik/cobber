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
    attr_reader :session
    attr_reader :key

    def initialize
      @key = ENV['MEETUP_KEY']
      @session = Excon.new('https://api.meetup.com/')
    end

    def rsvps(url_name:, event_id:, params: {})
      parse session.get(
        path: "/#{url_name}/events/#{event_id}/rsvps",
        query: with_key(params)
      )
    end

    def events(url_name)
      parse session.get(
        path: "/#{url_name}/events",
        query: with_key
      )
    end

    def parse(value)
      JSON.parse value.body
    end

    def with_key(params = {})
      params.merge(key: key)
    end
  end
end
