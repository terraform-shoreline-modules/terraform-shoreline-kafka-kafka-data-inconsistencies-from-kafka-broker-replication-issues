

#!/bin/bash



# Set variables

KAFKA_HOME=${PATH_TO_KAFKA_HOME_DIRECTORY}

REPLICATION_FACTOR=${DESIRED_REPLICATION_FACTOR}

BROKER=${BROKER_ID}



# Check current replication factor

CURRENT_REPLICATION_FACTOR=$($KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic ${TOPIC_NAME} | awk -F': ' '/^Replication Factor:/ {print $2}')

if [ "$CURRENT_REPLICATION_FACTOR" -lt "$REPLICATION_FACTOR" ]; then

  echo "Replication factor is currently set to $CURRENT_REPLICATION_FACTOR, which is less than desired replication factor of $REPLICATION_FACTOR."

  echo "Please increase the replication factor to at least $REPLICATION_FACTOR to avoid data inconsistencies when a broker goes down."

  exit 1

fi



# Check if broker is down

BROKER_STATUS=$($KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic ${TOPIC_NAME} | grep -w isr | grep -w $BROKER | awk '{print $2}')

if [ "$BROKER_STATUS" == "false" ]; then

  echo "Broker $BROKER is currently down. Please bring it back up to avoid data inconsistencies."

  exit 1

fi



echo "System is healthy. No issues detected."

exit 0