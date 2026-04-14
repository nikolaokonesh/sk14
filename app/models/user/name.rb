module User::Name
  extend ActiveSupport::Concern

  included do
    def username(type = :familiar) # или username(:full)
      return slug if name.blank?

      if name.respond_to?(type)
        name.public_send(type)
      else
        name.to_s
      end
    end
  end
end
