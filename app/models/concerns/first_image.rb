module FirstImage
  extend ActiveSupport::Concern

  included do
    # this is first image
    def image_url_helper(image)
      image.representation(resize_to_fill: [ 100, 100 ])
    end

    def image_helper(post)
      image = post.content.embeds.find(&:image?)
      return unless image.present?

      image_url_helper(image)
    end
  end
end
