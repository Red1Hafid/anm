require 'sidekiq-scheduler'
require "rake"
Rails.application.load_tasks
class TestPeriodJob
  include Sidekiq::Worker

  def perform(*args)
   Rake::Task["test_period_task"].execute
  end
end
