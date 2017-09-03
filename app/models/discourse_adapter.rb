class DiscourseAdapter
  attr_reader :client

  def initialize
    @client = DiscourseApi::Client.new("https://forum.ruby.org.au")
    @client.api_key = ENV['DISCOURSE_KEY']
    @client.api_username = ENV['DISCOURSE_USERNAME']
  end

  def download_short
    users = client.list_users(:active)
    users.map!(&:with_indifferent_access)

    users.each do |user|
      downer = ForumUser.find_by(id: user[:id]) || ForumUser.new(id: user[:id])

      downer.username = user['username']
      downer.raw_data_short = user
      downer.save!
    end
  end

  def download_full
    ForumUser.find_each(&method(:download_full_user))
  end

  def download_full_user(forum_user)
    user = client.user(forum_user.username)

    forum_user.raw_data_full = user
    forum_user.meetup_id = extract_meetup_id_from_discourse_user(user)
    forum_user.save!
  end

  private

  def extract_meetup_id_from_discourse_user(user)
    user['user_fields']['3'].to_s.scan(/\d{5,}/).first
  end
end
