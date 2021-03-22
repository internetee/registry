require 'test_helper'

class FormHelperTest < ActionView::TestCase
  def test_legal_document_field
    meth = MiniTest::Mock.new
    returned_legal_document_field = ApplicationController.helpers.legal_document_field('Hello', meth)

    assert returned_legal_document_field.include? 'data-legal-document="true"'
    assert returned_legal_document_field.include? 'accept=".pdf,.asice,.asics,.sce,.scs,.adoc,.edoc,.bdoc,.zip,.rar,.gz,.tar,.7z,.odt,.doc,.docx"'
  end
end