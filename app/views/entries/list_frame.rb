class Views::Entries::ListFrame < Components::Base
  def initialize(
    entries:,
    pagy:,
    params:
  )
    @entries = entries
    @pagy = pagy
    @params = params
  end

  def view_template
    turbo_frame_tag :entries_list, target: "_top", refresh: :morph do
      div(class: "w-full min-h-full") do
        render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
        render Components::Entries::ButtonNewBadge.new
        div(class: "snap-end") { }
      end
    end
  end
end
