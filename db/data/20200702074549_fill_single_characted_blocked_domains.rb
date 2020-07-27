class FillSingleCharactedBlockedDomains < ActiveRecord::Migration[6.0]

  DOMAIN_NAMES = %w[a.ee b.ee c.ee d.ee e.ee f.ee g.ee h.ee i.ee j.ee k.ee l.ee m.ee n.ee o.ee
                    p.ee q.ee r.ee s.ee š.ee z.ee ž.ee t.ee u.ee v.ee w.ee õ.ee ä.ee ö.ee ü.ee
                    x.ee y.ee 0.ee 1.ee 2.ee 3.ee 4.ee 5.ee 6.ee 7.ee 8.ee 9.ee].freeze

  def up
    BlockedDomain.transaction do
      DOMAIN_NAMES.each do |name|
        BlockedDomain.find_or_create_by(name: name)
      end
    end
  end

  def down
    BlockedDomain.transaction do
      BlockedDomain.by_domain(DOMAIN_NAMES).delete_all
    end
  end
end
