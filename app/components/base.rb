# frozen_string_literal: true

class Components::Base < Phlex::HTML
  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Tag
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Truncate
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::TimeTag
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::ButtonTo

  register_value_helper :current_user
  register_value_helper :lucide_icon
  register_value_helper :authenticated?
  register_value_helper :can?

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
