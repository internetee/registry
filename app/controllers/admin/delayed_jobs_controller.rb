module Admin
  class DelayedJobsController < BaseController
    authorize_resource class: false

    def index
      @jobs = Delayed::Job.all
    end
  end
end
