class EmailJob < ApplicationJob
  attr_accessor :email

  retry_on StandardError, wait: :exponentially_longer, attempts: 3 do |job, error|
    save_error_data(job, error)
  end

  def self.save_error_data(job, error)
    BouncedMailAddress.create(enqueued_at: job.enqueued_at.to_datetime,
                              email: job.email,
                              job_name: job.class.name,
                              error_description: error.to_s)
  end
end
