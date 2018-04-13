require 'rails_helper'

describe Invoice do
  context 'with invalid attribute' do
    before :all do
      @invoice = Invoice.new
    end

    it 'should not be valid' do
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([
        "Buyer name is missing",
        "Currency is missing",
        "Due date is missing",
        "Invoice items is missing",
        "Seller iban is missing",
        "Seller name is missing",
      ])
    end

    it 'should not have any versions' do
      @invoice.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @invoice = create(:invoice)
    end

    it 'should be valid' do
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @invoice = create(:invoice)
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @invoice = create(:invoice)
      @invoice.valid?
      @invoice.errors.full_messages.should match_array([])
    end

    it 'should return correct addresses' do
      @invoice = create(:invoice)
      @invoice.seller_address.should == 'Paldiski mnt. 123, Tallinn'
    end

    it 'should cancel overdue invoices' do
      create(:invoice, created_at: Time.zone.now - 35.days, due_date: Time.zone.now - 30.days)
      Invoice.cancel_overdue_invoices
      Invoice.where(cancelled_at: nil).count.should == 1
    end

    it 'should have one version' do
      with_versioning do
        @invoice.versions.should == []
        @invoice.buyer_name = 'New name'
        @invoice.save
        @invoice.errors.full_messages.should match_array([])
        @invoice.versions.size.should == 1
      end
    end
  end
end
