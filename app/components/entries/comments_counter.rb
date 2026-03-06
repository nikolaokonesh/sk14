class Components::Entries::CommentsCounter < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID
  register_value_helper :lucide_icon


  def initialize(entry:)
    @entry = entry
  end

  def view_template
    div(id: counter_dom_id, class: "flex") do
      return if comments_count.zero?

      span(class: "opacity-30") { lucide_icon("messages-square") }
      span(class: "text-xs absolute opacity-70 left-5 -top-1") { comments_count }
    end
  end

  private

  def comments_count
    @entry.root.comments_count
  end

  def counter_dom_id
    dom_id(@entry.root, :comments_counter)
  end
end
