require 'test_helper'

class CountriesLearningTest < ActiveSupport::TestCase
  def test_returns_all_countries
    assert_respond_to Country.all, :sort_by
  end

  def test_returns_country_name
    assert_equal 'United States of America', Country.new('US').name
  end

  def test_returns_country_alpha2_code
    assert_equal 'US', Country.new('US').alpha2
  end

  def test_returns_country_alpha3_code
    assert_equal 'USA', Country.new('US').alpha3
  end

  def test_validates_code_when_creating_an_instance_of_country
    assert_not Country.new('invalid')
  end
end