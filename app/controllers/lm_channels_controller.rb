class LmChannelsController < ApplicationController
  before_action :set_lm_channel, only: %i[ show update destroy ]
  skip_before_action :verify_authenticity_token

  def index
    @lm_blocks = LmChannel.select(:prefix).distinct.order(prefix: :asc)
    @lm_channel = LmChannel.order(number: :desc)
    @last_updated_channel = LmChannel.order(:updated_at).last.updated_at if @lm_channel.present?
  end

  def show
    @lm_channel_values = @lm_channel.lm_channel_values.order(created_at: :desc).where("created_at >= ?", 3.days.ago)
    @lm_channels = LmChannel.where(prefix: @lm_channel.prefix, active: true).order(number: :desc)
  end

  def create
    if LmChannel.find_by(name: params[:name]).present?
      @lm_channel = LmChannel.find_by(name: params[:name])
      update
    else
      @lm_channel = LmChannel.new(lm_channel_params)
      if @lm_channel.save
        @lm_channel.lm_channel_values.create(value: @lm_channel.value, quality: @lm_channel.quality, dt: @lm_channel.dt)
      else
        render json: @lm_channel.errors, status: :unprocessable_entity
        puts "отказано в создании"
      end
    end
  end

  def update
    if @lm_channel.update(lm_channel_params)
      @lm_channel.lm_channel_values.create(value: @lm_channel.value, quality: @lm_channel.quality, dt: @lm_channel.dt)
    else
      puts "отказано в обновлении"
    end
  end

  def destroy
    @lm_channel.destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_lm_channel
      @lm_channel = LmChannel.friendly.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lm_channel_params
      params.require(:lm_channel).permit(:name, :number, :prefix, :description, :active, :value, :quality, :dt)
    end
end
