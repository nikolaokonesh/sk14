# app/components/reactions/picker.rb
class Components::Reactions::Picker < Phlex::HTML
  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    div(class: "max-w-[92vw] overflow-x-auto overflow-y-hidden whitespace-nowrap no-scrollbar flex flex-nowrap gap-1 p-3 bg-base-300 rounded-full shadow-xl border-4 border-slate-500 animate-in slide-in-from-bottom-2") do
      Reaction::EMOJIS.values.each do |emoji|
        button(
          class: "size-8 grid place-items-center cursor-pointer rounded-full hover:scale-120 transition-transform px-1 text-lg",
          data: { action: "click->reactions#select", reactions_content_param: emoji, reactions_entry_id_param: @entry.id }
        ) { emoji }
      end
    end
  end
end
