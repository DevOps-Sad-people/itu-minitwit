require 'prometheus/middleware/collector'

class MyCollector < Prometheus::Middleware::Collector
  def generate_path(env)
    env['sinatra.route'].partition(' ').last
  end
end