class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :hid, limit: 8, unique: true
      t.string :htype
      t.string :hsubtype
      t.string :hstate

      t.timestamps
    end
  end
end
