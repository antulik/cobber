# == Schema Information
#
# Table name: forum_users
#
#  id               :integer          not null, primary key
#  username         :string
#  meetup_id        :string
#  raw_data_short   :jsonb
#  raw_data_full    :jsonb
#  short_updated_at :datetime
#  full_updated_at  :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ForumUser < ApplicationRecord
  def image_url
    path = raw_data_full['avatar_template']
    path = path.sub('{size}', '500')

    if path.start_with?('/')
      "https://forum.ruby.org.au#{path}"
    else
      path
    end
  end

  def background_url
    return if raw_data_full['card_background'].blank?
    path = raw_data_full['card_background'].sub('{size}', '500')
    "https://forum.ruby.org.au#{path}"
  end

  def links
    f = raw_data_full['user_fields']
    regex = /com\/([^\/]+)/
    result = {}

    result[:forum] = username

    twitter_url = f['2'].presence
    if twitter_url
      result[:twitter] = twitter_url.match(regex)&.[](1) || twitter_url
      result[:twitter]&.sub!('@', '')
    end

    github_url = f['1'].presence
    if github_url
      result[:github] = github_url.match(regex)&.[](1) || github_url
      result[:github]&.sub!('@', '')
    end

    website = raw_data_full['website'].presence
    if website
      result[:web] = URI.parse(website).host
    end

    result.group_by(&:last)
  end

  def first_name
    raw_data_full['name'].split.first
  end

  def last_name
    raw_data_full['name'].split.last
  end

  def name
    raw_data_full['name']
  end
end
