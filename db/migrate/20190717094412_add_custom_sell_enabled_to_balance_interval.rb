class AddCustomSellEnabledToBalanceInterval < ActiveRecord::Migration[6.0]
  def change
    add_column :balance_intervals, :custom_sell_enabled, :boolean, default: false, comment: '是否手动卖出'
  end
end
