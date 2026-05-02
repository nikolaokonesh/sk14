# frozen_string_literal: true

class AdvertisementsController < ApplicationController
  allow_unauthenticated_access only: :index
  before_action :require_authentication, except: :index
  before_action :set_advertisement, only: %i[update destroy]

  def index
    @top_advertisements = Advertisement.on_top.limit(6).includes(:user)
    @advertisement = authenticated? ? Current.user.advertisements.new : nil

    render Views::Advertisements::Index.new(top_advertisements: @top_advertisements, advertisement: @advertisement)
  end

  def create
    @advertisement = Current.user.advertisements.new(advertisement_params)

    if @advertisement.save
      redirect_to advertisements_path, notice: "Реклама опубликована и поднята в топ"
    else
      @top_advertisements = Advertisement.on_top.limit(6).includes(:user)
      render Views::Advertisements::Index.new(top_advertisements: @top_advertisements, advertisement: @advertisement), status: :unprocessable_entity
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
    params.expect(advertisement: %i[title description cta_text cta_url theme])
  end

  def moderation_params
    params.expect(advertisement: %i[active top_placement paid_until])
  end
end
