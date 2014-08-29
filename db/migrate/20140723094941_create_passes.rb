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
  end
end
