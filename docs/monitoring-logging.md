# Monitoring

Monitoring is implemented using Prometheus + Grafana.

Go to http://localhost:3000/ to see the dashboard.

Config is stored in yaml and json files, under the folder ./grafana.

Currently configured metrics:

- HTTP response count by status codes
- HTTP error response count
- Latency percentiles
- Average latency
- Total registered users

Currently configured alerts:

- Email alerting when 5XX (server-side) error count exceeds the threshold, on the "HTTP error response count" panel

## How to modify dashboard/metrics:

1. Go to the dashboard on the monitoring interface, make changes. You can add, remove or change panels.
2. You cannot save changes from the UI. Export the whole dashboard as json, and overwrite [this](./grafana/predefined-dashboards/minitwit_dashboard.json) file.
3. Restart the grafana docker container.

## How to add new alert rules:

1. Go to the dashboard, select the panel you want to add alerts to.
2. Create and save alert.
3. Export as json (only way to make it permanent). Copy only the relevant alert group under section "groups". 
4. Save it under [this](./grafana/alerting/alert_rules.yaml) file (append it to section "groups").
5. Restart the grafana docker container.

## How to modify alert rules:

1. Go to the dashboard, select the panel, then the existing alert rule.
2. Select "Export with modifications".
3. Make changes, then export as json.
4. Save it under the relevant file, as discussed before.
5. Restart the grafana docker container.

# Logging

Logging is implemented using the ELFK stack (Elasticsearch, Logstash, Filebeat, Kibana).

Go to http://localhost:5601/ to see the kibana UI.

First time startup:
1. Run ```docker compose -f docker-compose.dev.yml up elasticsearch-setup```. This configures the necessary users and roles for Elasticsearch and the stack.
2. Run the stack normally.
3. On the Kibana UI, click on Analytics/Discover to create the initial data view.

The following fields are the most relevant for filtering logs:
- service: the name of the docker service, as defined in the docker compose file.
- level: the logging level (DEBUG, INFO etc.) if applicable. If a log could not be parsed by Logstash, this field is omitted.
- @timestamp

Config files are stored under ./elk.

Logstash filtering logic can be changed in [this](./elk/logstash/pipeline/logstash.conf) file.
