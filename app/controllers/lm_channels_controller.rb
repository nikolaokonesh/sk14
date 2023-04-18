class LmChannelsController < ApplicationController
  before_action :set_lm_channel, only: %i[ show update destroy ]
  skip_before_action :verify_authenticity_token

  # GET /lm_channels
  # GET /lm_channels.json
  def index
    @lm_channels = LmChannel.all
  end

  # GET /lm_channels/1
  # GET /lm_channels/1.json
  def show
  end

  # POST /lm_channels
  # POST /lm_channels.json
  def create
    if LmChannel.find_by(name: params[:name]).present?
      @lm_channel = LmChannel.find_by(name: params[:name])
      update
    else
      @lm_channel = LmChannel.new(lm_channel_params)
      if @lm_channel.save
        @lm_channel.lm_channel_values.create(value: @lm_channel.value, quality: @lm_channel.quality, dt: @lm_channel.dt)
        puts "сохранено"
      else
        render json: @lm_channel.errors, status: :unprocessable_entity
        puts "не сохранено"
      end
    end
  end

  # PATCH/PUT /lm_channels/1
  # PATCH/PUT /lm_channels/1.json
  def update
    if @lm_channel.update(lm_channel_params)
      @lm_channel.lm_channel_values.create(value: @lm_channel.value, quality: @lm_channel.quality, dt: @lm_channel.dt)
      puts "сохранено в обновлении"
    else
      puts "отправлено на создание"
    end
  end

  # DELETE /lm_channels/1
  # DELETE /lm_channels/1.json
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
      params.require(:lm_channel).permit(:name, :number, :description, :active, :value, :quality, :dt)
    end
end
