class TagsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  def index
    @tags = Tag.joins(:entry_keywords)
               .merge(EntryKeyword.joins(:entry).where(entries: { trash: false }))
               .select("tags.*, COUNT(entry_keywords.id) as usage_count")
               .group("tags.id")
               .order("usage_count DESC")
    render Views::Tags::Index.new(
      tags: @tags
    )
  end

  def show
    @tag = Tag.find_by_id(params[:id])
    @entries = Entry.active.joins(:entry_keywords)
                 .where(entry_keywords: { tag_id: @tag.id })
                 .where(trash: false)
                 .distinct
                 .order(created_at: :desc)

    @pagy, @entries = pagy_countless(@entries)
    render Views::Tags::Show.new(
      entries: @entries,
      tag: @tag,
      pagy: @pagy,
      params: params[:page]
    )
  end
end
