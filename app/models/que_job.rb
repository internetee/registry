# To be able to remove existing jobs
class QueJob < ActiveRecord::Base
  self.primary_key = 'job_id'
end
