class DiscourseAdapter
  attr_reader :client

  def initialize
    @client = DiscourseApi::Client.new("https://forum.ruby.org.au")
    @client.api_key = ENV['DISCOURSE_KEY']
    @client.api_username = ENV['DISCOURSE_USERNAME']
  end

  def list_users
    return to_enum(__callee__) unless block_given?

    page = 1
    loop do
      users = client.get("admin/users/list/active.json?page=#{page}")[:body]

      users.each do |user|
        yield user
      end

      page += 1
      break if users.size < 100
    end
  end

  def download_short
    users = list_users.to_a
    users.map!(&:with_indifferent_access)

    users.each do |user|
      downer = ForumUser.find_by(id: user[:id]) || ForumUser.new(id: user[:id])

      downer.username = user['username']
      downer.raw_data_short = user
      downer.short_updated_at = Time.now
      downer.save!
    end
  end

  def download_full
    ForumUser.find_each(&method(:download_full_user))
  end

  def download_full_user(forum_user)
    user = client.user(forum_user.username)

    forum_user.raw_data_full = user
    forum_user.full_updated_at = Time.now
    forum_user.meetup_id = extract_meetup_id_from_discourse_user(user)
    forum_user.save!
  rescue DiscourseApi::NotFoundError
    forum_user.destroy!
  end

  private

  def extract_meetup_id_from_discourse_user(user)
    user['user_fields']['3'].to_s.scan(/\d{5,}/).first
  end
end
