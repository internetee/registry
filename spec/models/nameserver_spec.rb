require 'rails_helper'

describe Nameserver do
  it { should belong_to(:domain) }

  context 'with invalid attribute' do
    before :all do
      @nameserver = Nameserver.new
    end

    it 'should not be valid' do
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([
        "Hostname Hostname is invalid"
      ])
    end

    it 'should not have any versions' do
      @nameserver.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @nameserver = Fabricate(:nameserver)
    end

    it 'should be valid' do
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @nameserver = Fabricate(:nameserver)
      @nameserver.valid?
      @nameserver.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @nameserver.versions.should == []
        @nameserver.hostname = 'hostname.ee'
        @nameserver.save
        @nameserver.errors.full_messages.should match_array([])
        @nameserver.versions.size.should == 1
      end
    end
  end
end
