ActiveRecord::Schema.define(version: 0) do
  create_table :pages, force: true do |t|
    t.integer :parent_id
    t.string  :title, null: false
    t.string  :url_slug, null: false
  end
end