json.extract! lm_channel, :id, :name, :number, :description, :active, :created_at, :updated_at
json.url lm_channel_url(lm_channel, format: :json)
