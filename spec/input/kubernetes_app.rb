application "metrics-agents" do

  helm "logstash" do
    chart "stable/logstash"
    version "2.1.0"
    values "templates/logstash.yaml.erb"
  end

  helm "kube-state-metrics" do
    chart "stable/kube-state-metrics"
    version "1.6.0"
  end

  helm "filebeat" do
    chart "stable/filebeat"
    version "2.0.0"
    values "templates/filebeat.yaml"
  end

  helm "metricbeat" do
    chart "stable/metricbeat"
    version "1.7.0"
    values "templates/metricbeat.yaml"
  end

end

