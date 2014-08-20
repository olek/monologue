# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-webkit'

require "factory_girl_rails"
require 'database_cleaner'
require 'shoulda'

require 'coveralls'
Coveralls.wear!


ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

module EvaluatorWithSession
  def association(factory_name, *traits_and_overrides)
    traits_and_overrides.last[:session] = session if respond_to?(:session)
    super(factory_name, *traits_and_overrides)
  end
end

module FactoryGirl
  class Evaluator
    prepend EvaluatorWithSession
  end
end

FactoryGirl.define do
  to_create { |instance|
    if instance.respond_to?(:session)
      # ignore, do not persist
    else
      instance.save!
    end
  }

  initialize_with do
    if !respond_to?(:session)
      new.tap { |o|
        attributes.each do |k, v|
          o.send("#{k}=", v)
        end
      }
    else
      rejections = [:session, :repo]
      entity_attrs_and_assocs = attributes.reject { |k, v| rejections.include?(k) }

      session_repo = session.repo(repo)

      assocs, entity_attrs = entity_attrs_and_assocs
        .partition { |k, v|
            session.association_definitions.detect { |o|
              o.type == :foreign_key &&
              o.from == session_repo.entity_class &&
              o.as == k
            }
          }
        .map { |o| Hash[o] }

      session.repo(repo).create(entity_attrs).tap { |entity|
        assocs.each do |association_name, association_value|
          entity.session.association(entity, association_name).set(association_value)
        end
      }
    end
  end
end

Rails.backtrace_cleaner.remove_silencers!

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do
    DatabaseCleaner.start
    ActionController::Base.perform_caching = false
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.backtrace_exclusion_patterns = []
end
