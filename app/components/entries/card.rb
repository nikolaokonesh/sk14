# frozen_string_literal: true

class Components::Entries::Card < Components::Base
  def initialize(entry:, user:)
    @entry = entry
    @user = user
  end

  def view_template
    li(class: "list-row text-lg gap-0 hover:bg-base-200 active:bg-base-200 duration-100 px-4 py-2") do
      a(href: entry_path(@entry), class: "absolute inset-0 z-10", aria_label: "Читать далее")
      div(class: "flex items-center gap-2") do
        span { @entry.user.username }
        span(class: "text-xs pt-1") { render Components::Shared::CreatedAt.new(entry: @entry) }

        render_images_indicator
        span { render(Components::Entries::ReadBadge.new(entry: @entry, user: @user)) if show_read_state_badge? }
      end
      div(class: "list-col-wrap") do
        span(class: "flex items-center") do
          render Components::Entries::TagsListing.new(entry: @entry)
          render_afisha_mini_badge if @entry.entryable.is_afisha?
        end
        plain truncate(@entry.title, length: 200, omission: "... Читать далее")
      end
    end
  end

  private

  def render_images_indicator
    count = @entry.images_count.to_i
    return if count.zero?

    div(class: "flex items-center") do
      if count == 1
        div(class: "text-base-content/40") do
          plain raw lucide_icon("image", class: "size-4")
        end
      else
        div(class: "relative flex items-center") do
          div(class: "absolute left-1.5 -top-1 text-base-content/20") do
            plain raw lucide_icon("image", class: "size-4")
          end
          div(class: "relative z-10 text-base-content/50 bg-base-100 rounded-sm") do
            plain raw lucide_icon("image", class: "size-4")
          end
        end
      end
    end
  end

  def show_read_state_badge?
    @user && @entry.user_id != @user.id && @entry.post?
  end

  def render_afisha_mini_badge
    span(class: "font-bold uppercase rounded text-[9px] px-1 bg-cyan-500/20 text-cyan-500 mr-1") { "Афиша" }

    post = @entry.entryable
    start_date = Time.zone.parse(post.event_date) rescue nil
    return unless start_date

    duration = post.event_duration.to_i
    end_date = start_date + (duration > 0 ? duration : 1).days
    now = Time.current

    if now > end_date
      # СОБЫТИЕ ПРОШЛО
      span(class: "badge text-ghost badge-xs opacity-50 font-bold uppercase text-[9px] px-1") { "Прошло" }
    elsif now >= start_date && now <= end_date
      # ИДЕТ СЕЙЧАС
      span(class: "badge text-error badge-xs font-bold uppercase text-[9px] px-1 animate-pulse") { "Идет!" }
    else
      # БУДУЩЕЕ (Дата начала)
      span(class: "badge text-primary badge-xs font-bold uppercase text-[9px] px-1") do
        now.to_date == start_date.to_date ? "Сегодня" : I18n.l(start_date, format: "%-d %b")
      end
    end
  end
end
