class SaveLegalDocsToDisk < ActiveRecord::Migration
  def change
    add_column :legal_documents, :path, :string
    LegalDocument.all.each do |x|
      path = nil
      loop do
        rand = SecureRandom.random_number.to_s.last(4)
        next if rand.to_i == 0 || rand.length < 4
        path = "#{ENV['legal_documents_dir']}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{x.document_type}"
        break unless File.file?(path)
      end

      body = x.read_attribute('body')
      File.open(path, 'wb') { |f| f.write(Base64.decode64(body)) }
      x.update_column('path', path)
    end

    remove_column :legal_documents, :body, :text
  end
end
