class GeneratedDoc
  include Redis::Objects

  attr_reader :id

  with_options expiration: 1.hour, marshal: true do
    value :file
    value :generated_at
    value :created_at
    value :message
  end

  def initialize(id)
    @id = id
  end
end
