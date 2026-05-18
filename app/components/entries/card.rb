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

        render_images_preview_row
      end
    end
  end

  private

  def render_images_preview_row
    count = @entry.images_count
    return if count.zero?

    blobs = @entry.preview_blobs_for_list

    div(class: "pointer-events-none relative z-20 mt-2 flex items-center gap-1 overflow-hidden") do
      if blobs.empty?
        render_images_indicator(count)
      else
        blobs.each_with_index do |blob, index|
          img(
            src: url_for(@entry.preview_thumbnail_variant(blob)),
            class: "size-7 rounded-md object-cover ring-1 ring-base-300/70 bg-base-200",
            alt: "Изображение #{index + 1}",
            loading: "lazy",
            decoding: "async"
          )
        end

        render_more_images_badge(count - blobs.size) if count > blobs.size
      end
    end
  end

  def render_images_indicator(count)
    div(class: "flex items-center gap-1 text-base-content/50") do
      plain raw lucide_icon("image", class: "size-4")
      span(class: "text-xs font-semibold") { plain count } if count > 1
    end
  end

  def render_more_images_badge(count)
    div(
      class: [
        "flex size-7 items-center justify-center rounded-md bg-base-200",
        "text-[10px] font-bold text-base-content/70 ring-1 ring-base-300/70"
      ],
      aria_label: "Еще #{count} изображений"
    ) do
      plain "+#{count}"
    end
  end

  def show_read_state_badge?
    # @entry.entryable_type == 'Post' быстрее, чем @entry.post?, так как не лезет в базу
    @user && @entry.user_id != @user.id && @entry.entryable_type == "Post"
  end
end
