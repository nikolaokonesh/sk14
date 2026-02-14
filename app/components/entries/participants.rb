# frozen_string_literal: true

class Components::Entries::Participants < Components::Base
  def initialize(users:)
    @users = users
  end

  def view_template
    @users.each do |user|
      username = user.username

      tag.lexxy_prompt_item(search: username, sgid: user.attachable_sgid) do
        tag.template(type: "menu") do
          div(class: "flex items-center gap-2 p-3 cursor-pointer") do
            if user.avatar.present? && user.avatar.avatar.attached? && user.avatar.avatar.persisted?
              img(src: url_for(user.avatar.avatar.representation(:thumbnail)))
            else
              div(class: "relative inline-flex items-center justify-center size-6 overflow-hidden bg-gray-100 rounded-full bg-gray-500") do
                plain span(class: "font-medium text-xs text-slate-200 uppercase") {
                  if user.name.present?
                    plain span(class: "text-xs") { user.name.initials }
                  else
                    plain span(class: "text-xs") { user.email[0..1] }
                  end
                }
              end
            end
            plain username
          end
        end
        tag.template(type: "editor") do
          plain "@#{username}"
        end
      end
    end
  end
end
