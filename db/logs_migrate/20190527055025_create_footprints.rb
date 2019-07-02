class CreateFootprints < ActiveRecord::Migration[6.0]
  def change
    create_table :footprints do |t|
      t.text :before
      t.text :after
      t.string :action
      t.references :trackable, polymorphic: true, null: false
      t.references :actorable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
