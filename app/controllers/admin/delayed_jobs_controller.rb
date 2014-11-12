class Admin::DelayedJobsController < AdminController
  def index
    @jobs = Delayed::Job.all
  end
end
