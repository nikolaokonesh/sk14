module ApplicationHelper
  include Pagy::Frontend

  def year_now
    Time.current.year
  end

  def dom_id_for_records(*records, prefix: nil)
    records.map do |record|
      dom_id(record, prefix)
    end.join("_")
  end
end
