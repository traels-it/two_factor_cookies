# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"
require 'mocha/minitest'
require 'minitest-spec-rails'

# Filter out the backtrace from minitest while preserving the one from other libraries.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new


# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

module LogContentAssertions
  def assert_log_changes new_text
    # Ensure log file exists
    FileUtils.touch Rails.root.join('log', 'test.log')

    old_log_content = File.read(Rails.root.join('log', 'test.log'))
    yield
    new_log_content = File.read(Rails.root.join('log', 'test.log'))
    new_log_content.slice!(old_log_content)

    assert_includes new_log_content, new_text
  end
end

[ActionDispatch::IntegrationTest].each do |test_constant|
  test_constant.include(LogContentAssertions)
end

def login(user)
  post login_path, params: { username: user.username, password: user.password }
end
