
require 'redis'

class RateLimiter
  def initialize(app, options = {})
    @app = app
    @limit = options[:limit] || 100
    @period = options[:period] || 60
    @redis = Redis.new
  end

  def call(env)
    key = "#{env['REMOTE_ADDR']}:#{Time.now.to_i / @period}"
    count = @redis.incr(key)
    @redis.expire(key, @period) if count == 1

    if count > @limit
      [429, { 'Content-Type' => 'text/plain'}, ['Rate limit exceeded']]
    else
      @app.call(env)
    end
  end
end