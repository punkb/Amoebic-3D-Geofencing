json.array!(@events) do |event|
  json.extract! event, :id, :name, :address, :coordinates
  json.url event_url(event, format: :json)
end
