class Components::Reactions::List < Phlex::HTML
  def initialize(
    entry:
  )
    @entry = entry
    @summary = entry.reactions.group(:content).count
  end

  def view_template
    div(id: "reactions_entry_#{@entry.id}", class: "flex flex-wrap gap-1 mt-1 empty:hidden") do
      @summary.each do |emoji, count|
        is_active = Current.user.present? && @entry.reactions.exists?(user: Current.user, content: emoji)

        button(
          class: [
            "flex items-center gap-1 px-2 py-0.5 rounded-full text-sm border transition-all active:scale-90",
            is_active ? "bg-primary/20 border-primary text-primary" : "bg-base-100 border-transparent"
          ],
          data: { action: "click->reactions#select", reactions_content_param: emoji, reactions_entry_id_param: @entry.id }
        ) do
          span { emoji }; span(class: "font-bold") { count if count > 1 }
        end
      end
    end
  end
end
