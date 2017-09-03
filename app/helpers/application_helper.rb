module ApplicationHelper
  def font_size(text)
    case text.size
    when it >= 13
      'font-size: 25px;'
    when it >= 11
      'font-size: 30px;'
    when it >= 10
      'font-size: 31px;'
    when it >= 9
      'font-size: 31px;'
    when it >= 8
      'font-size: 31px;'
    end
  end
end
