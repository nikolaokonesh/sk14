# frozen_string_literal: true

class Components::ActiveStorage::Blob < Phlex::HTML
  include Phlex::Rails::Helpers::URLFor
  include Phlex::Rails::Helpers::NumberToHumanSize

  def initialize(blob:, in_gallery:)
    @blob = blob
    @in_gallery = in_gallery
  end

  def view_template
    figure(class: "attachment attachment--#{ @blob.representable? ? "preview" : "file" } attachment--#{ @blob.filename.extension }") do
      if @blob.representable?
        image_present?
      end

      figcaption(class: "attachment__caption") do
        if caption = @blob.try(:caption)
          if @blob.image?
            div(class: "attachment__name dark:text-slate-400") { caption }
          else
            caption_link_download(caption)
          end
        else
          unless @blob.image?
            caption_link_download(@blob.filename.to_s)
          end
        end
      end
    end
  end

  private

  def image_present?
    return if @blob.filename.extension == "aac"
    img(src: url_for(@blob.representation(resize_to_limit: @in_gallery ? [ 600, 400 ] : [ 900, 600 ])), class: "rounded-md", loader: "lazy")
  end

  def caption_link_download(text)
    if !@blob.image?
      a(href: url_for(@blob), class: "hover:opacity-70") do
        caption_text(text)
      end
    else
      caption_text(text)
    end
  end

  def caption_text(text)
    div(class: "flex items-center text-left") do
      span(class: "mr-1 font-bold uppercase border border-t-4 px-2 py-3") do
        @blob.filename.extension
      end
      div(class: "font-bold") do
        div(class: "text-slate-600") { text }
        div(class: "opacity-50") { number_to_human_size @blob.byte_size }
      end
    end
  end
end
