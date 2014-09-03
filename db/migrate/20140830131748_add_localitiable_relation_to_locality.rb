class AddLocalitiableRelationToLocality < ActiveRecord::Migration
  def change
    add_column :localities, :localitiable_id, :integer
    add_column :localities, :localitiable_type, :string
    add_index :localities, [:localitiable_id, :localitiable_type]
  end
end
