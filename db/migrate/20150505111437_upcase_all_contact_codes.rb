class UpcaseAllContactCodes < ActiveRecord::Migration
  def change
    puts 'Update contact code to upcase...'
    @i = 0
    puts @i
    Contact.find_in_batches(batch_size: 10000) do |batch|
      batch.each do |c|
        c.update_column(:code, c.code.upcase)
      end
      GC.start
      puts @i += 10000
    end
  end
end
