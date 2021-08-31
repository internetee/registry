if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter '/app/models/version/'
    add_filter '/lib/action_controller/'
    add_filter '/lib/core_monkey_patches/'
    add_filter '/lib/daemons/'
    add_filter '/lib/gem_monkey_patches/'
    add_filter '/lib/tasks/'
  end
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/assertions/epp_assertions'
require 'sidekiq/testing'
require 'spy/integration'

Sidekiq::Testing.fake!

# `bin/rails test` is not the same as `bin/rake test`.
# All tasks will be loaded (and executed) twice when using the former without `Rake::Task.clear`.
# https://github.com/rails/rails/issues/28786
require 'rake'
Rake::Task.clear
Rails.application.load_tasks

ActiveJob::Base.queue_adapter = :test

class CompanyRegisterClientStub
  Company = Struct.new(:registration_number, :company_name)

  def representation_rights(citizen_personal_code:, citizen_country_code:)
    [Company.new('1234567', 'ACME Ltd')]
  end
end

CompanyRegister::Client = CompanyRegisterClientStub

EInvoice.provider = EInvoice::Providers::TestProvider.new

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  fixtures :all
  set_fixture_class log_domains: Version::DomainVersion

  teardown do
    travel_back
  end
end

class ApplicationIntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include AbstractController::Translation
  include Devise::Test::IntegrationHelpers

  teardown do
    WebMock.reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class EppTestCase < ActionDispatch::IntegrationTest
  include Assertions::EppAssertions

  def assert_schema_is_bigger(response_xml, prefix, version)
    schema_version = prefix_schema_tag(prefix, response_xml)

    assert schema_version >= version
  end

  def assert_correct_against_schema(response_xml, message = nil)
    schema = EPP_ALL_SCHEMA

    schema_validation_errors = schema.validate(response_xml)
    assert_equal 0, schema_validation_errors.size, message
  end

  private

  def prefix_schema_tag(prefix, response_xml)
    if Xsd::Schema::PREFIXES.include? prefix
      version_regex = /-\d+\S\d+/
      domain_schema_tag = response_xml.to_s.scan(%r{https://epp.tld.ee/schema/#{prefix}\S+})
      version = domain_schema_tag.to_s.match(version_regex)[0]

      -version.to_f
    else
      raise Exception.new('Wrong prefix')
    end
  end

  #  The prefix and version of the response are returned are these variants - res[:prefix] res[:version]
  def parsing_schemas_prefix_and_version(response)
    xml = response.gsub!(/(?<=>)(.*?)(?=<)/, &:strip)
    xml.to_s.match(/xmlns:domain=\"https:\/\/epp.tld.ee\/schema\/(?<prefix>\w+-\w+)-(?<version>\w.\w).xsd/)
  end
end
