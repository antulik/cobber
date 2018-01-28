class GeneratedDocumentsController < ActionController::Base
  def show
    @group_id = params[:group_id]
    event_id = params[:event_id]

    @doc = GeneratedDoc.new(event_id)

    file = @doc.file.value
    @exists = file.present?

    respond_to do |format|
      format.pdf {
        send_data file, filename: "#{@group_id}.pdf"
      }
      format.html
    end
  end

  def create
    group_id = params[:group_id]
    event_id = params[:event_id]

    doc = GeneratedDoc.new(event_id)
    doc.file.delete
    doc.created_at.delete
    doc.message.delete
    doc.generated_at.delete

    doc.created_at.value = Time.now

    GeneratePdfJob.perform_async(
      group_id: group_id,
      event_id: event_id,
      blanks_count: params[:blanks_count].to_i
    )

    redirect_to generated_document_path(group_id: group_id, event_id: event_id)
  end
end
