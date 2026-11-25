# rake disclose_phone_numbers:disclose

namespace :disclose_phone_numbers do
  desc 'Disclose phone numbers'
  task disclose: :environment do
    reg_numbers = %w[
      10597973
      10890199
      10096260
      10784403
      10641728
      10762679
      10557933
      12659649
      12176224
      90010019
      10960801
      16406158
      10510593
      70000740
      10838419
      11099473
      451394720
      10647754
      10176042
      14127885
      11163283
      11685113
      14281238
      10098106
      10577829
      10234957
      12345678
      11072764
      11100236
    ]

    reg_numbers.each do |reg_no|
      registrar = Registrar.find_by(reg_no: reg_no)
      registrar.update!(accept_pdf_invoices: false)

      Rails.logger.info("For registrar with name #{registrar.name} and reg no #{registrar.reg_no} set accept_pdf_invoices to false")
    end
  end
end
