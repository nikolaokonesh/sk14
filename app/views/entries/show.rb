# frozen_string_literal: true

class Views::Entries::Show < Views::Base
  include Phlex::Rails::Helpers::TimeAgoInWords

  def initialize(entry:)
    @entry = entry
  end

  def view_template
    div(class: "lexxy-show") { @entry.content.to_s }

    div(class: "time") do
      plain "Опубликовано "
      plain time_ago_in_words(@entry.created_at)
      plain " назад, "
      render Shared::CreatedAt.new(entry: @entry)
    end


    if @entry.entryable.no_comments?
      plain "Комментарии отключены"
    end
  end
end
