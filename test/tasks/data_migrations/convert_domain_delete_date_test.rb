require 'test_helper'

class ConvertDomainDeleteDateTaskTest < ActiveSupport::TestCase
  setup do
    @domain = domains(:shop)
  end

  def test_moves_domain_delete_date_one_day_ahead
    @domain.update!(delete_date: '2010-07-05')

    capture_io do
      run_task
    end
    @domain.reload

    assert_equal Date.parse('2010-07-06'), @domain.delete_date
  end

  def test_processes_invalid_domains
    @domain = domains(:invalid)
    @domain.update_columns(delete_date: '2010-07-05')

    capture_io do
      run_task
    end
    @domain.reload

    assert_equal Date.parse('2010-07-06'), @domain.delete_date
  end

  def test_skips_non_expired_domains
    @domain.update!(delete_date: nil)

    assert_nothing_raised do
      capture_io do
        run_task
      end
    end
  end

  def test_output
    eliminate_effect_of_all_domains_except(@domain)
    @domain.update!(delete_date: '2010-07-05')

    assert_output "Domains processed: 1\n" do
      run_task
    end
  end

  private

  def eliminate_effect_of_all_domains_except(domain)
    Domain.connection.disable_referential_integrity do
      Domain.where("id != #{domain.id}").delete_all
    end
  end

  def run_task
    Rake::Task['data_migrations:convert_domain_delete_date'].execute
  end
end