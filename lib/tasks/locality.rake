namespace :localities do
  task :set_localitiable => :environment do
    Locality.all.each_with_index do |locality,index|
      if locality.fraction_id.blank?
        locality.localitiable_id = locality.municipality_id
        locality.localitiable_type = "Municipality"
      else
        locality.localitiable_id = locality.fraction_id
        locality.localitiable_type = "Fraction"
      end
      locality.save
    end
  end
end