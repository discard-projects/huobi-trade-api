class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # 前期检测全局数据变化
  include Footprintable
  # has_footprints

  def method_missing(method_name, *args, &block)
    case method_name
    when /_time$/
      self.send("#{method_name}".gsub(/_time$/, '_at')).to_s
    else
      super
    end
  end
end
