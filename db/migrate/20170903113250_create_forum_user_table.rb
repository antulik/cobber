class CreateForumUserTable < ActiveRecord::Migration[5.1]
  def change
    create_table :forum_users do |t|
      t.string :username
      t.string :meetup_id
      t.jsonb "raw_data_short"
      t.jsonb "raw_data_full"
      t.timestamp :short_updated_at
      t.timestamp :full_updated_at
      t.timestamps
    end

    create_table :generated_docs do |t|
      t.string :name
      t.string :url
      t.binary :data
    end
  end
end
