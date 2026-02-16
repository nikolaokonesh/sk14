class Views::Users::Edit < Views::Base
  def initialize(user:)
    @user = user
  end

  def page_title = "Настройки профиля"
  def layout = Layout

  def view_template
    div(class: "min-h-screen bg-base-100") do
      main(class: "container mx-auto px-4 py-6") do
        div(class: "max-w-2xl mx-auto") do
          div(class: "bg-base-200 rounded-lg shadow p-6") do
            h2(class: "text-xl font-semibold mb-6") { page_title }

            div(class: "flex justify-center") do
              turbo_frame_tag :avatar_upload, src: @user.avatar.present? ? edit_user_avatar_path(@user.avatar) : new_user_avatar_path, refresh: :morph do
                div(class: "flex items-center gap") do
                  div(class: "skeleton size-46 rounded-full") { }
                end
              end
            end

            form_with(model: @user, class: "space-y-4") do |f|
              render_form_field(f, :email, "Email") do
                f.email_field :email,
                  class: "input input-bordered w-full",
                  required: true,
                  disabled: true
              end

              render_form_field(f, :name, "Имя и Фамилия") do
                f.text_field :name, maxlength: 50,
                  class:  [ "input w-full", { "input-error": @user.errors[:name].any? } ]
              end

              render_form_field(f, :slug, "Домен") do
                f.text_field :slug, placeholder: "Домен", required: true, pattern: "[a-z0-9]+(?:-[a-z0-9]+)*", class: [ "input w-full", { "input-error": @user.errors[:slug].any? } ]
                div(class: "text-gray-500 text-sm") do
                  plain "https://#{request.domain}/users/#{Current.user.slug}"
                end
              end

              div(class: "flex space-x-4") do
                f.submit "Сохранить", class: "btn btn-primary flex-1"
                a(href: user_path(@user), class: "btn btn-outline flex-1") { "Отмена" }
              end
            end
          end
        end
      end
    end
  end

  private

  def render_form_field(form, field, label, &block)
    div do
      form.label field, label, class: "block text-sm font-medium text-gray-700 mb-1"
      yield
      if @user.errors[field].any?
        p(class: "text-red-500 text-sm mt-1") { @user.errors[field].join(", ") }
      end
    end
  end
end
