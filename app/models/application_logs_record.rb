class ApplicationLogsRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :logs

  def method_missing(method_name, *args, &block)
    case method_name
    when /_time$/
      self.send("#{method_name}".gsub(/_time$/, '_at')).to_s
    else
      super
    end
  end
end