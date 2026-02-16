class Tags::SearchController < ApplicationController
  allow_unauthenticated_access only: :index
  def index
    @query = params[:query]
    categories = ListingsDictionary::ACTIONS.keys
    counts_hash = Tag.where(name: categories)
                 .joins(:entries)
                 .merge(Entry.active.where(entryable_type: "Post"))
                 .group(:name)
                 .count

    sorted_counts = counts_hash.sort_by { |_name, count| -count }.reject { |_name, count| count.zero? }

    @visible_cateories = sorted_counts.map(&:first)

    @counts = counts_hash

    render Views::Tags::Search.new(
      categories: @visible_cateories,
      counts: @counts,
      query: @query
    ), layout: false
  end
end
