# Use the official grafana
FROM grafana/grafana:11.5.2

# Copy the config to the container
COPY ./alerting /etc/grafana/provisioning/alerting
COPY ./dashboards /etc/grafana/provisioning/dashboards
COPY ./datasources /etc/grafana/provisioning/datasources
COPY ./predefined-dashboards /predefined-dashboards