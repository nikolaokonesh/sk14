# frozen_string_literal: true

class Components::Entries::Card < Components::Base
  # Добавляем read_entry_ids в initialize
  def initialize(entry:, user:, read_entry_ids: nil)
    @entry = entry
    @user = user
    @read_entry_ids = read_entry_ids
  end

  def view_template
    li(class: "list-row text-lg gap-0 hover:bg-base-200 active:bg-base-200 duration-100 px-4 py-2") do
      a(href: entry_path(@entry), class: "absolute inset-0 z-10", aria_label: "Читать далее")

      div(class: "flex items-center gap-2") do
        # Благодаря includes(:user) в контроллере, здесь запроса не будет
        span { @entry.user.username }
        span(class: "text-xs pt-1") { render Components::Shared::CreatedAt.new(entry: @entry) }

        render_images_indicator

        # Передаем Set с ID прочтений в ReadBadge
        if show_read_state_badge?
          span { render Components::Entries::ReadBadge.new(entry: @entry, read_entry_ids: @read_entry_ids) }
        end
      end

      div(class: "list-col-wrap") do
        span(class: "flex items-center") do
          render Components::Entries::TagBadge.new(entry: @entry)

          # Используем делегированный метод из Entry
          if @entry.is_afisha?
            render Components::Entries::AfishaBadge.new(entry: @entry.entryable, size: :sm)
          end
        end

        # Метод title теперь должен быть в модели Entry (возвращать строку, а не объект ActionText)
        plain @entry.title
      end
    end
  end

  private

  def render_images_indicator
    # images_count в модели Entry должен просто проверять размер уже загруженной коллекции embeds_attachments
    count = @entry.images_count
    return if count.zero?

    div(class: "flex items-center") do
      if count == 1
        div(class: "text-base-content/40") { plain raw lucide_icon("image", class: "size-4") }
      else
        div(class: "relative flex items-center") do
          div(class: "absolute left-1.5 -top-1 text-base-content/20") { plain raw lucide_icon("image", class: "size-4") }
          div(class: "relative z-10 text-base-content/50 bg-base-100 rounded-sm") { plain raw lucide_icon("image", class: "size-4") }
        end
      end
    end
  end

  def show_read_state_badge?
    # @entry.entryable_type == 'Post' быстрее, чем @entry.post?, так как не лезет в базу
    @user && @entry.user_id != @user.id && @entry.entryable_type == "Post"
  end
end
