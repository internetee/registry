require 'test_helper'
require 'deserializers/xml/auto_renew'
require 'deserializers/xml/domain_create'
require 'deserializers/xml/domain_update'

class DeserializersXmlAutoRenewTest < ActiveSupport::TestCase
  URI = Deserializers::Xml::AutoRenew::URI

  def test_omitted_and_foreign_namespace_are_ignored
    assert_nil parse('')
    assert_nil parse('<other:update xmlns:other="urn:other"><other:enabled>true</other:enabled></other:update>')
  end

  def test_boolean_lexical_values_and_alternate_prefix
    { 'true' => true, '1' => true, 'false' => false, '0' => false }.each do |value, expected|
      assert_equal({ enabled: expected }, parse(block("<ar:enabled>#{value}</ar:enabled>")))
    end
  end

  def test_invalid_boolean
    %w[yes TRUE False 2].each do |value|
      assert_error('2005', block("<ar:enabled>#{value}</ar:enabled>"))
    end
    assert_error('2005', block('<ar:enabled/>'))
  end

  def test_duplicate_blocks_and_conflicting_children
    enabled = block('<ar:enabled>true</ar:enabled>')
    assert_error('2001', enabled + enabled)
    assert_error('2001', block('<ar:enabled>false</ar:enabled><ar:reverse cycleId="cycle"/>'))
    assert_error('2001', block('<ar:enabled>true</ar:enabled><ar:enabled>false</ar:enabled>'))
  end

  def test_missing_unknown_and_nested_children
    assert_error('2003', block(''))
    assert_error('2001', block('<ar:unknown/>'))
    assert_error('2001', block('<ar:enabled><ar:value>true</ar:value></ar:enabled>'))
    assert_error('2001', block('<enabled>true</enabled>'))
    assert_error('2003', block('<ar:reverse/>'))
  end

  def test_wrong_command_and_placement
    assert_error('2001', '<ar:create xmlns:ar="' + URI + '"><ar:enabled>true</ar:enabled></ar:create>')
    frame = document('').to_xml.sub('<extension/>', block('<ar:enabled>true</ar:enabled>'))
    error = assert_raises(Deserializers::Xml::AutoRenew::Error) do
      Deserializers::Xml::AutoRenew.new(frame, command: :update).call
    end
    assert_equal '2001', error.code
  end

  def test_reverse_and_create_reversal_rejection
    assert_equal({ reverse_cycle_id: 'cycle' }, parse(block('<ar:reverse cycleId="cycle"/>')))
    error = assert_raises(Deserializers::Xml::AutoRenew::Error) do
      Deserializers::Xml::AutoRenew.new(
        document('<ar:create xmlns:ar="' + URI + '"><ar:reverse cycleId="cycle"/></ar:create>', :create),
        command: :create
      ).call
    end
    assert_equal '2306', error.code
  end

  def test_false_survives_domain_deserializers_blank_filter
    %i[create update].each do |command|
      raw = document("<ar:#{command} xmlns:ar=\"#{URI}\"><ar:enabled>false</ar:enabled></ar:#{command}>", command)
      klass = command == :create ? Deserializers::Xml::DomainCreate : Deserializers::Xml::DomainUpdate
      result = klass.new(raw.dup.remove_namespaces!, registrars(:bestnames).id, nokogiri_frame: raw).call
      assert_equal({ enabled: false }, result[:auto_renew])
    end
  end

  private

  def block(children)
    "<ar:update xmlns:ar=\"#{URI}\">#{children}</ar:update>"
  end

  def document(extension, command = :update)
    Nokogiri::XML(<<~XML)
      <epp xmlns="https://epp.tld.ee/schema/epp-ee-1.0.xsd">
        <command>
          <#{command}>
            <domain:#{command} xmlns:domain="https://epp.tld.ee/schema/domain-ee-1.2.xsd">
              <domain:name>shop.test</domain:name>
            </domain:#{command}>
          </#{command}>
          <extension>#{extension}</extension>
        </command>
      </epp>
    XML
  end

  def parse(extension)
    Deserializers::Xml::AutoRenew.new(document(extension), command: :update).call
  end

  def assert_error(code, extension)
    error = assert_raises(Deserializers::Xml::AutoRenew::Error) { parse(extension) }
    assert_equal code, error.code
  end
end
