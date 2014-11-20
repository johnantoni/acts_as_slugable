class Page < ActiveRecord::Base
  validates :title, presence: true, length: { minimum: 2}
  acts_as_slugable source_column: :title, slug_column: :url_slug, scope: :parent
end