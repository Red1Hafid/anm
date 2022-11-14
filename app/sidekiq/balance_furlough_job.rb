require 'sidekiq-scheduler'
require "rake"
Rails.application.load_tasks
class BalanceFurloughJob
  include Sidekiq::Worker

  def perform(*args)
   # Rake::Task["calcule_balance_furlough"].execute
   Rake::Task["feed_balance_furlough"].execute
  end
end
