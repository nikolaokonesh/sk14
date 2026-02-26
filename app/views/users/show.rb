class Views::Users::Show < Views::Base
  def initialize(
    user:,
    entries:,
    pagy:,
    params:
  )
    @user = user
    @entries = entries
    @pagy = pagy
    @params = params
  end

  def page_title = sanitize(strip_tags(@user.username))
  def layout = Layout

  def view_template
    div(class: "w-full") do
      render Components::Users::Show.new(user: @user)
      if authenticated?
        unless @user == Current.user
          div(class: "mt-5") do
            render Components::Subscriptions::Button.new(user: Current.user, followable: @user)
          end
        end
      end
      div(class: "w-full pt-2 px-2") do
        if authenticated? && Current.user == @user
          turbo_stream_from :entries
          a(href: user_path(@user), data: { turbo_action: "advance" }, class: "px-2") do
            plain "Мои посты: "
            plain span(id: "entries_size") { Current.user.entries_size }
          end
          a(href: trash_index_path, data: { turbo_action: "advance" }, class: "px-2") do
            plain "Удаленные: "
            plain span(id: "trash_size") { Current.user.trash_size }
          end
          if Current.user.subscriptions.present?
            a(href: user_feeds_path, data: { turbo_frame: "entry_content", turbo_action: "advance" }, class: "px-2") do
              plain "Подписки"
            end
          end
        end
      end
      if authenticated?
        if current_page?(user_feeds_path)
          div(class: "mt-6") do
            if @user.followed_tags.present?
              div do
                plain "Ключевые слова:"
                @user.followed_tags.each do |tag|
                  a(href: tag_path(tag), class: "hover:underline pl-2 font-bold") { "##{tag.name}" }
                  turbo_stream_from :tag, tag.id
                end
              end
            end
            if @user.followed_users.present?
              div do
                plain "Пользователи:"
                @user.followed_users.each do |user|
                  a(href: user_path(user), class: "hover:underline pl-2 font-bold") { "@#{user.username}" }
                end
              end
            end
          end
          turbo_stream_from :user, Current.user.id
        end
      end
      div(class: "mt-10") do
        div(class: "h-[66svh] overflow-y-auto overflow-x-visible no-scrollbar", data: { controller: "autoscroll infinite-scroll" }) do
          render Components::Entries::List.new(entries: @entries, pagy: @pagy, params: @params)
        end
      end
    end
  end
end
