require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Migration.verbose = false

DatabaseCleaner[:active_record].strategy = :transaction

ActiveRecord::Schema.define do
  create_table :activity_feed_items, :force => true do |t|
    t.string :user_id
    t.string :nickname
    t.string :type
    t.string :title
    t.text :body

    t.timestamps
  end
end

module ActivityFeed
  module ActiveRecord
    class Item < ::ActiveRecord::Base
      self.table_name = 'activity_feed_items'
      self.inheritance_column = nil

      after_save :update_activity_feed

      private

      def update_activity_feed
        ActivityFeed.update_item(self.user_id, self.id, self.created_at.to_i)
      end
    end
  end
end