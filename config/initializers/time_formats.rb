# Time::DATE_FORMATS.merge!({ :default => '%Y-%m-%d %H:%M:%S' })
# Date::DATE_FORMATS.merge!({ :default => '%Y-%m-%d' })
Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M:%S'
Date::DATE_FORMATS[:default] = '%Y-%m-%d'
Time::DATE_FORMATS[:time] = '%H:%M:%S'
Time::DATE_FORMATS[:time_short] = '%H:%M'

Time::DATE_FORMATS[:humane] = lambda do |date|
  now = Time.now
  if now.strftime("%Y-%m-%d") == date.strftime("%Y-%m-%d")
    "今天 #{date.to_s(:time_short)}"
  elsif now.yesterday.strftime("%Y-%m-%d") == date.strftime("%Y-%m-%d")
    "昨天 #{date.to_s(:time_short)}"
  else
    date.strftime("%m-%d %H:%M")
  end
end
