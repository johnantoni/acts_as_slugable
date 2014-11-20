module Slugable
  module ActsAsSlugable
    extend ActiveSupport::Concern

    included do
      after_validation :create_slug
    end

    module ClassMethods
      def acts_as_slugable(options = {})
        configuration = {source_column: 'name', slug_column: 'url_slug', scope: nil}
        configuration.update(options) if options.is_a?(Hash)

        configuration[:scope] = "#{configuration[:scope]}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~/_id$/

        if configuration[:scope].is_a?(Symbol)
          scope_condition_method = %(
            def slug_scope_condition
              if #{configuration[:scope].to_s}.nil?
                "#{configuration[:scope].to_s} IS NULL"
              else
                "#{configuration[:scope].to_s} = \#{#{configuration[:scope].to_s}}"
              end
            end
          )
        elsif configuration[:scope].nil?
          scope_condition_method = "def slug_scope_condition() \"1 = 1\" end"
        else
          scope_condition_method = "def slug_scope_condition() \"#{configuration[:scope]}\" end"
        end

        class_eval <<-EOV
          include Slugable::ActsAsSlugable::LocalInstanceMethods

          def acts_as_slugable_class
            ::#{self.name}
          end

          def source_column
            "#{configuration[:source_column]}"
          end

          def slug_column
            "#{configuration[:slug_column]}"
          end

          #{scope_condition_method}
        EOV

        include Slugable::ActsAsSlugable::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      private

      def create_slug
        return if self.errors.count > 0

        if self[slug_column].to_s.empty?
          test_string = self[source_column]

          proposed_slug = test_string.strip.downcase.gsub(/[\'\"\#\$\,\.\!\?\%\@\(\)]+/, '')
          proposed_slug = proposed_slug.gsub(/&/, 'and')
          proposed_slug = proposed_slug.gsub(/[\W^-_]+/, '-')
          proposed_slug = proposed_slug.gsub(/\-{2}/, '-')

          suffix = ''
          existing = true

          acts_as_slugable_class.transaction do
            while existing != nil
              #existing = acts_as_slugable_class.find(:first, conditions: ["#{slug_column} = ? and #{slug_scope_condition}", proposed_slug + suffix])
              existing = acts_as_slugable_class.where(["#{slug_column} = ? and #{slug_scope_condition}", proposed_slug + suffix]).first
              if existing
                if suffix.empty?
                  suffix = "-0"
                else
                  suffix.succ!
                end
              end
            end
          end

          self[slug_column] = proposed_slug + suffix
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Slugable::ActsAsSlugable)
