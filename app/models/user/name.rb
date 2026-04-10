module User::Name
  extend ActiveSupport::Concern

  included do
    def username
      if name.present?
        name.familiar
      else
        slug
      end
    end

    def name_full
      if name.present?
        name.full
      else
        slug
      end
    end
  end
end
