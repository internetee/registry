class AddMissingData < ActiveRecord::Migration
  def change
    return if Rails.env == 'development'
    return if Rails.env == 'test'
    puts 'GENERATING ACCOUNTS'
    Registrar.all.each do |x|
      Account.create(
        registrar_id: x.id,
        account_type: Account::CASH,
        balance: 0.0,
        currency: 'EUR'
      )
    end

    puts 'GENERATING REFERENCE NUMBERS'

    Registrar.all.each do |x|

      no = nil

      loop do
        base = nil
        loop do
          base = SecureRandom.random_number.to_s.last(8)
          break if base.to_i != 0 && base.length == 8
        end

        control_base = (base + '2715' + '00').to_i
        reminder = control_base % 97
        check_digits = 98 - reminder

        check_digits = check_digits < 10 ? "0#{check_digits}" : check_digits.to_s

        no = "RF#{check_digits}#{base}"
        break unless Registrar.exists?(reference_no: no)
      end

      x.update_columns(reference_no: no)
    end

    puts 'SAVING LEGAL DOCUMENTS'

    LegalDocument.all.each do |x|
      path = nil
      i = 0
      loop do
        puts "LOOPING #{i}"
        i += 1
        rand = SecureRandom.random_number.to_s.last(4)
        next if rand.to_i == 0 || rand.length < 4
        path = "#{ENV['legal_documents_dir']}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{x.document_type}"
        break unless File.file?(path)
      end

      puts "SAVING LEGAL DOCUMENT #{x.id}"
      body = x.read_attribute('body')
      File.open(path, 'wb') { |f| f.write(Base64.decode64(body)) }
      x.update_column('path', path)
    end

    puts 'REMOVING COLUMN'
    remove_column :legal_documents, :body, :text
  end
end
