class MeetupEventsController < ActionController::Base

  def show
    @group_id = params[:group_id]
    @event_id = params[:event_id]

    @event = MeetupAdapter.new.event(@group_id, @event_id)

    respond_to do |format|
      format.pdf {
        pds = GetUsersToPrint.new(@group_id, @event_id).pdf
        send_data pds, filename: 'labels.pdf'
      }
      format.html {
        # @users = GetUsersToPrint.new(@group_id, @event_id).users
        render :show
      }
    end
  end
end
