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
      users = with_wait do
        client.get("admin/users/list/active.json?page=#{page}")[:body]
      end

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
    user = with_wait do
      client.user(forum_user.username)
    end

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

  def with_wait
    yield
  rescue DiscourseApi::TooManyRequests => e
    seconds = eval(e.message)['extras']['wait_seconds'] + 1
    puts "Too many requests, sleeping #{seconds} seconds ..."

    sleep seconds
    retry
  end
end
