class CreatePasses < ActiveRecord::Migration
  def change
    create_table :passes do |t|
      t.string :name
      t.string :locality
      t.integer :altitude
      t.float :latitude
      t.float :longitude
      t.string :name_encoded

      t.timestamps
    end
    add_index :passes, :name_encoded
  end
end
