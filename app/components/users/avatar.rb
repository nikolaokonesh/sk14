class Components::Users::Avatar < Phlex::HTML
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::URLFor
  def initialize(
    user:,
    style: "size-10",
    text_size: "text-xs"
  )
    @user = user
    @style = style
    @text_size = text_size
  end

  def view_template
    div(id: "#{dom_id(@user, "avatar")}", class: "avatar") do
      if @user.avatar.present? && @user.avatar.avatar.attached? && @user.avatar.avatar.persisted?
        div(class: "#{@style} rounded-full skeleton") do
          img(src: url_for(@user.avatar.avatar.representation(:thumbnail)),
              loading: "lazy",
              decoding: "async")
        end
      else
        div(class: "relative inline-flex items-center justify-center #{@style} overflow-hidden bg-gray-100 rounded-full bg-gray-500") do
          plain span(class: "font-medium #{@text_size} text-slate-200 uppercase") {
            if @user.name.present?
              plain @user.name.initials
            else
              plain @user.email[0..1]
            end
          }
        end
      end
    end
  end
end
