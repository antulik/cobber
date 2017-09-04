task download: :environment do
  DiscourseAdapter.new.download_short
  DiscourseAdapter.new.download_full
end
