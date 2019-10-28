class MeetupGroupsController < ActionController::Base

  def index
  end

  def show
    @group_id = params[:group_id]
    @events = MeetupAdapter.new.events(@group_id)
  end
end
