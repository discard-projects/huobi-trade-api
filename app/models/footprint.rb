class Footprint < ApplicationLogsRecord
  serialize :before, JSON
  serialize :after, JSON

  belongs_to :trackable, polymorphic: true
  belongs_to :actorable, polymorphic: true, optional: true
end
