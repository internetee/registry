module Concerns::Domain::Deletable
  extend ActiveSupport::Concern

  private

  def delete_later
    run_at = rand(((24 * 60) - (DateTime.now.hour * 60 + DateTime.now.minute))).minutes.from_now
    DomainDeleteJob.enqueue(id, run_at: run_at)
  end

  def do_not_delete_later
    QueJob.find_by!("args->>0 = '#{id}'", job_class: DomainDeleteJob.name).delete
  end
end
