require 'test_helper'
require 'fixtures/page'

class ActsAsSlugableTest < ActiveSupport::TestCase
  # Initialize the TestSuit and run all steps required to configure
  # the environment properly.
  setup do
    @allowable_characters = Regexp.new('^[A-Za-z0-9_-]+$')
  end

  # after_validation callback hooks should exist.
  test 'hooks_presence' do
    assert Page._validation_callbacks.select{ |cb| cb.kind.eql?(:after)}.collect(&:filter).include?(:create_slug)
    assert Page._validation_callbacks.select{ |cb| cb.kind.eql?(:after)}.collect(&:filter).include?(:create_slug)
  end

  # Test whether the creation of the slug columns functions
  test 'create' do
    pg = Page.create(title: 'New Page')
    assert pg.valid?
    assert_equal 'new-page', pg.url_slug


    pg = Page.create(title: 'Test override', parent_id: nil, url_slug: 'something-different')
    assert pg.valid?
    assert_equal 'something-different', pg.url_slug
  end

  # Test whether the model still runs validations
  test 'model_still_runs_validations' do
    pg = Page.create(title: nil)
    assert !pg.valid?
    assert pg.errors.get(:title)

    pg = Page.create(title: '')
    assert !pg.valid?
    assert pg.errors.get(:title)
  end

  # Test the update method
  test 'update' do
    pg = Page.create(title: 'Original Page')
    assert pg.valid?
    assert_equal 'original-page', pg.url_slug

    # update, with title
    pg.update_attribute(:title, 'Updated title only')
    assert_equal 'original-page', pg.url_slug

    # update, with title and nil slug
    pg.update_attributes(title: 'Updated title and slug to nil', url_slug: nil)
    assert_equal 'updated-title-and-slug-to-nil', pg.url_slug

    # update, with empty slug
    pg.update_attributes(title: 'Updated title and slug to empty', url_slug: '')
    assert_equal 'updated-title-and-slug-to-empty', pg.url_slug
  end

  # Test the uniqueness
  test 'uniqueness' do
    puts "--- uniqueness test ---"

    t = 'Unique title'

    puts "--- creating first page ---"
    pg1 = Page.create(title: t, parent_id: 1)
    assert pg1.valid?

    puts "--- creating second page ---"
    pg2 = Page.create(title: t, parent_id: 1)
    assert pg2.valid?

    assert_not_equal pg1.url_slug, pg2.url_slug
  end

  # Test the Scope
  test 'scope' do
    t = 'Unique scoped title'

    pg1 = Page.create(title: t, parent_id: 1)
    assert pg1.valid?

    pg2 = Page.create(title: t, parent_id: 1)
    assert pg2.valid?

    assert_equal pg1.url_slug, pg2.url_slug
  end

  # Test Character replacement
  test 'characters' do
    check_for_allowable_characters 'Title'
    check_for_allowable_characters 'Title and some spaces'
    check_for_allowable_characters 'Title-with-dashes'
    check_for_allowable_characters "Title-with'-$#)(*%symbols"
    check_for_allowable_characters '/urltitle/'
    check_for_allowable_characters 'calculé en française'
  end

  private
  def check_for_allowable_characters(title)
    pg = Page.create(title: title)
    assert pg.valid?
    assert_match @allowable_characters, pg.url_slug
  end
end
