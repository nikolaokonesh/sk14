# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_entry, only: %i[show edit update destroy]

  def index
    # 1. Получаем ID рекламы для текущей страницы
    @ads_scope = Advertisement.on_top
    set_page_and_extract_portion_from @ads_scope

    # 2. Загружаем Entry, но во вьюху отдаем их entryable (Advertisement)
    # Метод load_for_list подтянет User и PreviewBlob и "прошьет" связи
    entries = Entry.load_for_list(
      Entry.where(entryable_type: "Advertisement", entryable_id: @page.records.pluck(:id)),
      current_user
    )

    # Превращаем Entry обратно в массив Advertisement, но уже "заряженных" данными
    @records = entries.map(&:entryable).compact

    render Views::Advertisements::Index.new(
      page: @page,
      records: @records
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
      @entry = Entry.includes(
        :user,
        :entryable,
        rich_text_content: { embeds_attachments: :blob } # Исправленное имя
      ).find(params[:id])
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
