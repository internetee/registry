require 'test_helper'

class RegenerateRegistrarReferenceNumbersTaskTest < ActiveSupport::TestCase
  def test_regenerates_registrar_reference_numbers_to_estonian_format
    registrar = registrars(:bestnames)
    registrar.update_column(:reference_no, 'RF1111')

    capture_io { run_task }
    registrar.reload

    assert_not registrar.reference_no.start_with?('RF')
  end

  def test_does_not_regenerate_when_the_task_is_run_again
    registrar = registrars(:bestnames)
    registrar.update!(reference_no: '1111')

    capture_io { run_task }
    registrar.reload

    assert_equal '1111', registrar.reference_no
  end

  def test_keeps_iso_reference_number_on_the_invoice_unchanged
    registrar = registrars(:bestnames)
    registrar.update_column(:reference_no, 'RF1111')
    invoice = registrar.invoices.first
    invoice.update!(reference_no: 'RF2222')

    capture_io { run_task }
    invoice.reload

    assert_equal 'RF2222', invoice.reference_no
  end

  def test_output
    registrar = registrars(:bestnames)
    registrar.update_column(:reference_no, 'RF1111')

    assert_output "Registrars processed: 1\n" do
      run_task
    end
  end

  private

  def run_task
    Rake::Task['data_migrations:regenerate_registrar_reference_numbers'].execute
  end
end
