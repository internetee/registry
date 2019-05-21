require 'test_helper'

class Post < ActiveRecord::Base
  has_paper_trail
end

class PaperTrailLearningTest < ActiveSupport::TestCase
  setup do
    ActiveRecord::Base.connection.create_table :posts do |t|
      t.string :title

      # Otherwise `touch_with_version` fails silently
      t.datetime :updated_at
    end
  end

  def test_returns_version_list
    @record = Post.create!(title: 'any')

    assert_equal 1, @record.versions.count
    assert_respond_to @record.versions.first, :item_id
  end

  def test_creates_new_version_upon_update
    @record = Post.create!(title: 'old title')
    original_record = @record.clone

    assert_difference -> { @record.versions.size } do
      @record.update!(title: 'new title')
    end
    version = @record.versions.last
    assert_equal @record.id, version.item_id
    assert_equal @record.class.name, version.item_type
    assert_equal version.reify, original_record
    assert_equal ['old title', 'new title'], version.object_changes['title']
    assert_equal 'update', version.event
  end

  def test_touch_with_version
    @record = Post.create!(title: 'any')
    
    assert_difference -> { @record.versions.size } do
      @record.touch_with_version
    end
  end
end