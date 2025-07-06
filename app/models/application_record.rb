class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  EMAIL_FORMAT= URI::MailTo::EMAIL_REGEXP
  STATUSES = %i[preparing asigned retired to_withdraw in_route delivered returned rejected nothing no_retired]
  NAME_PROFILES_TYPES = %i[estandar premium express]
  
  def self.localized_name
    "activerecord.attributes.#{table_name}"
  end

end
