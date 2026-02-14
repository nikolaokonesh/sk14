class Views::Users::Avatars::Form < Views::Base
  def initialize(user_avatar:)
    @user_avatar = user_avatar
  end

  def layout = Layout

  def view_template
    turbo_frame_tag :avatar_upload, refresh: :morph do
      turbo_stream.update :flash do
        render Components::Shared::Flash.new
      end

      turbo_stream.update dom_id(Current.user, "avatar") do
        render Components::Users::Avatar.new(user: Current.user)
      end

      form_with(model: @user_avatar, class: "contents", data: { controller: "auto-submit" }) do |form|
        tag.div class: "flex items-center gap", data: { controller: "upload-preview", upload_preview_default_image_value: Current.user.email.first } do
          label(class: "flex items-center gap") do
            plain form.file_field :avatar, class: "sr-only",  accept: "image/jpg, image/jpeg, image/png, image/gif, image/webp", data: { upload_preview_target: "input", action: "auto-submit#submit" }
            plain span(class: "sr-only") { "Upload avatar" }
            div(class: "avatar") do
              div(class: "w-48 -m-1 z-10 rounded-full skeleton") do
                if Current.user.avatar.present? && Current.user.avatar.avatar.attached? && Current.user.avatar.avatar.persisted?
                  img(src: url_for(Current.user.avatar.avatar.representation(:thumbnail)), data: { upload_preview_target: "image" }, loading: "lazy")
                else
                  div(class: "relative inline-flex items-center justify-center w-48 h-48 overflow-hidden bg-gray-100 rounded-full dark:bg-gray-600", data_upload_preview_target: "image", action: "upload-preview#previewImage") do
                    span(class: "font-medium text-5xl text-gray-600 dark:text-gray-300 uppercase") do
                      if Current.user.name.present?
                        plain Current.user.name.initials
                      else
                        plain Current.user.email[0..1]
                      end
                    end
                  end
                end
              end
            end
            if Current.user.avatar.present? && Current.user.avatar.avatar.attached? && Current.user.avatar.avatar.persisted?
              a(href: user_avatar_path(Current.user.avatar), class: "flex items-center", data: { turbo_method: :delete, turbo_confirm: "Вы точно хотите удалить аватар?", upload_preview_target: "removeInput" }) do
                div(class: "bg-base-300 p-2 absolute rounded-full z-10 -mt-20 -ml-5 tooltip", data: { tip: "Удалить" }) do
                  lucide_icon("x")
                end
              end
            end
          end
        end
        if @user_avatar.errors[:avatar].any?
          p(class: "text-red-500 text-sm mt-1") { @user_avatar.errors[:avatar].join(", ") }
        end
      end
    end
  end
end
