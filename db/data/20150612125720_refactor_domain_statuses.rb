class RefactorDomainStatuses < ActiveRecord::Migration
  def self.up
    Domain.all.each do |x|
      x.statuses = []
      x.domain_statuses.each do |ds|
        x.statuses << ds.value
      end
      x.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
