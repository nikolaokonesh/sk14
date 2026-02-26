class Components::Comments::Form::LexxyPrompt < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::Tag

  def initialize(
    entry:
  )
    @entry = entry
  end

  def view_template
    tag.lexxy_prompt(
      trigger: "@",
      name: "mention",
      src: entry_participants_path(@entry),
      "remote-filtering": true,
      # "insert-editable-text": true,
      # "supports-space-in-searches": false,
      "empty-results": "Нет пользователя, обновите страницу для обновления списка"
    )
  end
end
