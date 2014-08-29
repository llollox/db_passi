module ConnectToDbComuni
  extend ActiveSupport::Concern

  included do
    establish_connection "#{Rails.env}_db_comuni".to_sym
  end

end
