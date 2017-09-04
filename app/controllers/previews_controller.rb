class PreviewsController < ActionController::Base
  helper_method :users_with_cool_tags

  def show
    user = ForumUser.find_by(username: params[:q])

    if user && user.full_updated_at < 1.minute.ago
      DiscourseAdapter.new.download_full_user(user)
    end

    @users = [user].compact
  end

  private

  def users_with_cool_tags
    ForumUser.where.not(meetup_id: nil)
  end
end
