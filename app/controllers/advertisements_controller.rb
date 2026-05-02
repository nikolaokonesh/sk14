# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :require_authentication, except: %i[index show]
  before_action :set_advertisement, only: %i[show update destroy]

  def index
    scope = Advertisement.on_top.includes(:user, :rich_text_content)
    set_page_and_extract_portion_from scope

    @advertisement = authenticated? ? Current.user.advertisements.new : nil

    render Views::Advertisements::Index.new(page: @page, advertisement: @advertisement)
  end

  def show
    render Views::Advertisements::Show.new(advertisement: @advertisement)
  end

  def create
    @advertisement = Current.user.advertisements.new(advertisement_params)

    if @advertisement.save
      redirect_to advertisement_path(@advertisement), notice: "Реклама опубликована"
    else
      set_page_and_extract_portion_from Advertisement.on_top.includes(:user, :rich_text_content)
      render Views::Advertisements::Index.new(page: @page, advertisement: @advertisement), status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @advertisement

    if @advertisement.update(moderation_params)
      redirect_to advertisements_path, notice: "Реклама обновлена"
    else
      redirect_to advertisements_path, alert: @advertisement.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize! :destroy, @advertisement
    @advertisement.destroy!

    redirect_to advertisements_path, notice: "Реклама удалена"
  end

  private

  def set_advertisement
    @advertisement = Advertisement.find(params.expect(:id))
  end

  def advertisement_params
    params.expect(advertisement: %i[content theme])
  end

  def moderation_params
    params.expect(advertisement: %i[active top_placement paid_until])
  end
end
