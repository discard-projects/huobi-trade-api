class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include BaseResource

  def toggle_switch
    field = params[:field]
    br_show do |model|
      case model.class.columns_hash[field].type
      when :datetime
        model[field] = model[field].present? ? nil : Time.now
        model.save
      when :boolean # [true, false].include? model[field]
        model.toggle!(field)
      else
        render json: {msg: 'invalid! can not switch'}, status: 422 and return
      end
      render json: {value: model[field], msg: 'successfully'}, status: 200 and return
    end
  end
end
