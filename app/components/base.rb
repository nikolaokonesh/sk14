# frozen_string_literal: true

class Components::Base < Phlex::HTML
  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Tag
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Truncate
  include Phlex::Rails::Helpers::Sanitize
  include Phlex::Rails::Helpers::StripTags
  include Phlex::Rails::Helpers::AssetPath
  include Phlex::Rails::Helpers::TurboStreamFrom
  include Phlex::Rails::Helpers::TurboStream
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::DOMID
  include Phlex::Rails::Helpers::CurrentPage
  # include Phlex::Rails::Helpers::LinkTo
  # include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::ButtonTo
  # include Phlex::Rails::Helpers::ContentFor
  # include Phlex::Rails::Helpers::TimeTag
  # include Phlex::Rails::Helpers::TimeAgoInWords
  # include Phlex::Rails::Helpers::NumberToHumanSize
  # include Phlex::Rails::Helpers::T

  register_value_helper :authenticated?
  register_value_helper :current_user_id
  register_value_helper :current_user
  register_value_helper :lucide_icon
  register_value_helper :can?
  register_value_helper :request
  # register_value_helper :cant?
  # register_value_helper :local_assigns
  register_value_helper :controller_name
  # register_value_helper :action_name

  def cache_store
    Rails.cache
  end

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
