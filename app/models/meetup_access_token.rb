# == Schema Information
#
# Table name: meetup_access_tokens
#
#  id         :integer          not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MeetupAccessToken < ApplicationRecord
end
