class LmChannelsController < ApplicationController
  before_action :set_lm_channel, only: %i[ show update destroy ]
  skip_before_action :verify_authenticity_token

  def index
    @lm_channels_tp2 = LmChannel.where(prefix: "tp2", active: true).order(number: :desc)
    @lm_channels_tp3 = LmChannel.where(prefix: "tp3", active: true).order(number: :desc)
    @lm_channels_tp4 = LmChannel.where(prefix: "tp4", active: true).order(number: :desc)
    @lm_channels_tp5 = LmChannel.where(prefix: "tp5", active: true).order(number: :desc)
    @lm_channels_tp6 = LmChannel.where(prefix: "tp6", active: true).order(number: :desc)
    @lm_channels_tp7 = LmChannel.where(prefix: "tp7", active: true).order(number: :desc)
    @lm_channels_tku = LmChannel.where(prefix: "ktU", active: true).order(number: :desc)
    @lm_channels_kt6 = LmChannel.where(prefix: "tk6", active: true).order(number: :desc)
    @lm_channels_kt4 = LmChannel.where(prefix: "kt4", active: true).order(number: :desc)
  end

  def show
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
