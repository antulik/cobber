class MeetupUser
  attr_reader :attrs, :first_name, :last_name, :image_url, :name, :id

  def initialize(attrs)
    @attrs = attrs
    @first_name, @last_name = attrs['name'].split(' ', 2)
    @id = attrs['id']
    @image_url = attrs['photo'].try(:[], 'photo_link')
    @name = attrs['name']
  end

  def background_url
  end

  def links
  end
end
