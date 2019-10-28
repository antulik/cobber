class CreateMeetupAccessTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :meetup_access_tokens do |t|
      t.jsonb :data
      t.timestamps
    end
  end
end
