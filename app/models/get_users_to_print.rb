class GetUsersToPrint
  attr_reader :event_id, :group_id, :blanks_count

  def initialize(group_id, event_id, blanks_count: 40)
    @group_id = group_id
    @event_id = event_id
    @blanks_count = blanks_count
  end

  def users
    rsvps = MeetupAdapter.new.rsvps(@group_id, @event_id)
    rsvps.select!(&it['response'] == 'yes')
    meetup_ids = rsvps.map(&it['member']['id'])

    users_hash = ForumUser.where(meetup_id: meetup_ids).index_by(&:meetup_id)

    users = rsvps.map do |rsvp|
      meetup_user = MeetupUser.new(rsvp['member'])
      users_hash[meetup_user.id.to_s] || meetup_user
    end

    blanks = blanks_count.times.map do
      OpenStruct.new(
        id: rand(100_000_000),
        name: ''
      )
    end

    users + blanks
  end

  def pdf
    str = ApplicationController.render(
      'partials/pdfs', layout: nil,
      assigns: { users: users },
    )
    WickedPdf.new.pdf_from_string(
      str,
      page_height: 62, page_width: 100,
      margin: { top: 0,
        bottom: 0,
        left: 0,
        right: 0
      }
    )
  end
end
