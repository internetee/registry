class Admin::DelayedJobsController < AdminController
  authorize_resource class: false

  def index
    @jobs = Delayed::Job.all
  end
end
