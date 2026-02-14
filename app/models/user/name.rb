module User::Name
  extend ActiveSupport::Concern

  included do
    def username
      if name.present?
        name.familiar
      else
        email.split("@").first
      end
    end

    def name_full
      if name.present?
        name.full
      else
        email.split("@").first
      end
    end
  end
end
