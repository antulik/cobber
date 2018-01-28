class GeneratePdfJob
  include SuckerPunch::Job

  workers 1

  def perform(event_id:, group_id:, blanks_count:)
    doc = GeneratedDoc.new(event_id)

    pdf = GetUsersToPrint.new(group_id, event_id, blanks_count: blanks_count).pdf

    doc.file.value = pdf
    doc.generated_at = Time.now

  rescue StandardError => e
    doc.message.value = e.message
  end
end
