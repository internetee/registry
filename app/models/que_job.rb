# To be able to remove existing jobs
class QueJob < ApplicationRecord
  self.primary_key = 'job_id'
end
