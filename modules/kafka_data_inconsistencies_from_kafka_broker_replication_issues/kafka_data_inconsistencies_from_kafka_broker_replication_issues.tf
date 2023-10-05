resource "shoreline_notebook" "kafka_data_inconsistencies_from_kafka_broker_replication_issues" {
  name       = "kafka_data_inconsistencies_from_kafka_broker_replication_issues"
  data       = file("${path.module}/data/kafka_data_inconsistencies_from_kafka_broker_replication_issues.json")
  depends_on = [shoreline_action.invoke_kafka_replication_check,shoreline_action.invoke_update_kafka_replication]
}

resource "shoreline_file" "kafka_replication_check" {
  name             = "kafka_replication_check"
  input_file       = "${path.module}/data/kafka_replication_check.sh"
  md5              = filemd5("${path.module}/data/kafka_replication_check.sh")
  description      = "The Kafka cluster is not configured with enough replication factor, resulting in data inconsistencies when a broker goes down."
  destination_path = "/agent/scripts/kafka_replication_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_kafka_replication" {
  name             = "update_kafka_replication"
  input_file       = "${path.module}/data/update_kafka_replication.sh"
  md5              = filemd5("${path.module}/data/update_kafka_replication.sh")
  description      = "Check the replication settings and configurations. Ensure that the replication factor is set to a value that can handle the expected load and that the Kafka brokers are properly configured to handle replication."
  destination_path = "/agent/scripts/update_kafka_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_replication_check" {
  name        = "invoke_kafka_replication_check"
  description = "The Kafka cluster is not configured with enough replication factor, resulting in data inconsistencies when a broker goes down."
  command     = "`chmod +x /agent/scripts/kafka_replication_check.sh && /agent/scripts/kafka_replication_check.sh`"
  params      = ["BROKER_ID","PATH_TO_KAFKA_HOME_DIRECTORY","TOPIC_NAME","DESIRED_REPLICATION_FACTOR"]
  file_deps   = ["kafka_replication_check"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_replication_check]
}

resource "shoreline_action" "invoke_update_kafka_replication" {
  name        = "invoke_update_kafka_replication"
  description = "Check the replication settings and configurations. Ensure that the replication factor is set to a value that can handle the expected load and that the Kafka brokers are properly configured to handle replication."
  command     = "`chmod +x /agent/scripts/update_kafka_replication.sh && /agent/scripts/update_kafka_replication.sh`"
  params      = ["KAFKA_CONFIG_FILE","DESIRED_REPLICATION_FACTOR"]
  file_deps   = ["update_kafka_replication"]
  enabled     = true
  depends_on  = [shoreline_file.update_kafka_replication]
}

