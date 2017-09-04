class PreviewsController < ActionController::Base
  def show
    user = ForumUser.find_by(username: params[:q])

    if user && user.full_updated_at < 1.minute.ago
      DiscourseAdapter.new.download_full_user(user)
    end

    @users = [user].compact
  end
end
