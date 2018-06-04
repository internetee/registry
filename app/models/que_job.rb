class QueJob < ActiveRecord::Base # To be able to remove existing jobs
  self.primary_key = 'job_id'
end
