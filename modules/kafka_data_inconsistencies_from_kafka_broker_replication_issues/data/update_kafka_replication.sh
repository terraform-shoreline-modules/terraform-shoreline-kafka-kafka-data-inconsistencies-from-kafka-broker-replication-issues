bash

#!/bin/bash



# Set the desired replication factor and the location of the Kafka configuration file

REPLICATION_FACTOR=${DESIRED_REPLICATION_FACTOR}

KAFKA_CONFIG=${KAFKA_CONFIG_FILE}



# Update the replication factor in the Kafka configuration file

sed -i "s/replication.factor=.*/replication.factor=$REPLICATION_FACTOR/g" $KAFKA_CONFIG



# Restart the Kafka brokers to apply the updated configuration

sudo systemctl restart kafka