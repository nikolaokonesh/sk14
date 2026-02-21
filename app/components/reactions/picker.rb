# app/components/reactions/picker.rb
class Components::Reactions::Picker < Components::Base
  def initialize(entry:)
    @entry = entry
  end

  def view_template
    div(class: "flex gap-1 p-1 bg-base-200 rounded-full shadow-xl border border-base-300 animate-in slide-in-from-bottom-2") do
      Reaction::EMOJIS.values.each do |emoji|
        button(
          class: "hover:scale-150 transition-transform px-1 text-lg",
          data: { action: "click->reactions#select", reactions_content_param: emoji, reactions_entry_id_param: @entry.id }
        ) { emoji }
      end
    end
  end
end
