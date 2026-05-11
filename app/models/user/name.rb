# frozen_string_literal: true

module User::Name
  extend ActiveSupport::Concern

  def username(type = :familiar)
    return slug if name.blank?

    name.respond_to?(type) ? name.public_send(type) : name.to_s
  end
end
