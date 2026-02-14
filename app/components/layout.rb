# frozen_string_literal: true

class Components::Layout < Components::Base
  include Phlex::Rails::Layout

  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    doctype
    html(lang: "ru") do
      head do
        title { @page_info.title }
        meta(name: "viewport", content: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0, interactive-widget=resizes-content")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "application-name", content: "Sk14")
        meta(name: "mobile-web-app-capable", content: "yes")
        meta(name: "view-transition", content: "same-origin")
        csrf_meta_tags
        csp_meta_tag
        tag.link rel: "manifest", href: pwa_manifest_path(format: :json)
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag :app, "data-turbo-track": "reload"
        stylesheet_link_tag "lexxy"
        javascript_importmap_tags
        meta(name: :turbo_refresh_method, content: :morph)
        meta(name: :turbo_refresh_scroll, content: :preserve)
      end
      body(data: { current_user_id: current_user_id }) { yield }
    end
  end
end
