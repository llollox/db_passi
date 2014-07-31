class CreateLocalities < ActiveRecord::Migration
  def change
    create_table :localities do |t|
      t.belongs_to :pass
      t.belongs_to :municipality
      t.belongs_to :fraction

      t.timestamps
    end
  end
end
