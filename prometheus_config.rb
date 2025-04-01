require "prometheus/middleware/collector"

class PrometheusCollector < Prometheus::Middleware::Collector
  def generate_path(env)
    env["sinatra.route"].partition(" ").last
  end
end
