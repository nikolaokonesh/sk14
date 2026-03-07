class AutoServicesController < ApplicationController
  allow_unauthenticated_access only: %i[index]
  before_action :set_entry, only: %i[edit update destroy set_activity]

  def index
    @mode = params[:mode].presence_in(%w[passenger services]) || "passenger"

    @entries = if @mode == "services" && authenticated?
      Current.user.entries
             .preload(:entryable, user: { avatar: { avatar_attachment: :blob } })
             .where(entryable_type: Entry::AUTO_SERVICE_TYPE)
             .reorder(updated_at: :desc)
    else
      Entry.active
           .preload(:entryable, user: { avatar: { avatar_attachment: :blob } })
           .joins("INNER JOIN auto_services ON auto_services.id = entries.entryable_id")
           .where(entryable_type: Entry::AUTO_SERVICE_TYPE)
           .where.not(auto_services: { activity_state: AutoService::STATE_OFF })
           .reorder(updated_at: :desc)
    end

    if @mode == "passenger"
      @entries = @entries.select { |entry| entry.entryable.available_now? } if @mode == "passenger"

      @pagy, @entries = pagy_array(@entries)
    else
      @pagy, @entries = pagy_countless(@entries)
    end

    render Views::AutoServices::Index.new(
      entries: @entries,
      pagy: @pagy,
      params: params[:page],
      mode: @mode
    )
  end

  def new
    @entry = Current.user.entries.new(entryable: AutoService.new(activity_state: AutoService::STATE_OFF))
    render Views::AutoServices::Form.new(entry: @entry)
  end

  def create
    @entry = Current.user.entries.new(entry_params)
    @entry.entryable_type = Entry::AUTO_SERVICE_TYPE

    if @entry.save
      flash[:success] = "Услуга добавлена"
      redirect_to auto_services_path(mode: "services")
    else
      render Views::AutoServices::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def edit
    authorize! :edit, @entry
    render Views::AutoServices::Form.new(entry: @entry)
  end

  def update
    authorize! :update, @entry

    if @entry.update(entry_params)
      flash[:success] = "Услуга обновлена"
      redirect_to auto_services_path(mode: "services")
    else
      render Views::AutoServices::Form.new(entry: @entry), status: :unprocessable_entity
    end
  end

  def set_activity
    authorize! :update, @entry

    state = params[:activity_state].to_s
    @entry.entryable.set_activity!(state)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.refresh }
      format.html do
        flash[:success] = "Режим активности обновлён"
        redirect_to auto_services_path(mode: "services")
      end
    end
  end

  def destroy
    authorize! :destroy, @entry

    if @entry.update(trash: true, trash_data: Time.current)
      Entries::Streams::DestroyJob.perform_later(@entry.id)

      respond_to do |format|
        format.html do
          flash[:alert] = "Услуга перемещена в удалённые"
          redirect_to auto_services_path(mode: "services"), status: :see_other
        end
        format.turbo_stream { render turbo_stream: turbo_stream.refresh }
      end
    else
      redirect_to auto_services_path(mode: "services"), alert: @entry.errors.full_messages.to_sentence
    end
  end

  private

  def set_entry
    @entry = Entry.includes(:entryable).find(params.expect(:id))
    raise ActiveRecord::RecordNotFound unless @entry.entryable_type == Entry::AUTO_SERVICE_TYPE
  end

  def entry_params
    params.expect(
      entry: [
        :entryable_type,
        entryable_attributes: [
          :id,
          :car_brand,
          :plate_number,
          :phone,
          :city_trip_price,
          :schedule_mode,
          :activity_state,
          :work_from,
          :work_to,
          :notes,
          { service_kinds: [], work_days_array: [] }
        ]
      ]
    )
  end
end
