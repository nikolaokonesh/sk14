class User < ApplicationRecord
  rolify
  has_person_name

  include ActionText::Attachable

  include Authentication
  include Name
  include Slug
  include Validate
  include Association

  def content_type
    "application/vnd.actiontext.mention"
  end
end
