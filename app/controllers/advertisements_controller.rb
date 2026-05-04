# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_entry, only: %i[show edit update destroy]

  def index
    scope = Advertisement.on_top.includes(entry: [ :user, :entry_reads, { rich_text_content: { embeds_attachments: :blob } } ])
    set_page_and_extract_portion_from scope

    render Views::Advertisements::Index.new(
      page: @page,
      records: @page.records.to_a # Это должно быть здесь для всех страниц
    )
  end


  def show
    render Views::Advertisements::Show.new(entry: @entry)
  end

  def new
    @entry = Current.user.entries.new(entryable: Advertisement.new)
    render Views::Advertisements::Form.new(entry: @entry)
  end

  def edit
    authorize! :update, @entry
    render Views::Advertisements::Form.new(entry: @entry)
  end

  def create
    @entry = Current.user.entries.new(entry_params)

    if @entry.save
      redirect_to advertisement_path(@entry), notice: "Реклама опубликована"
    else
      render Views::Advertisements::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @entry

    if @entry.update(entry_params)
      redirect_to advertisements_path, notice: "Реклама обновлена"
    else
      render Views::Advertisements::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @entry
    @entry.destroy!

    redirect_to advertisements_path, notice: "Реклама удалена"
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.expect(entry: [
        :content, :entryable_type, entryable_attributes: [
          :id, :theme
        ]
      ])
    end
end
