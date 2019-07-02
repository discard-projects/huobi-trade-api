json.partial! 'partial/paginate_meta', object: @footprints
json.items @footprints do |footprint|
  json.(footprint, :id, :before, :after, :action, :created_time, :updated_time)
  json.actor do
    json.email footprint.actorable.try(:email)
  end
end