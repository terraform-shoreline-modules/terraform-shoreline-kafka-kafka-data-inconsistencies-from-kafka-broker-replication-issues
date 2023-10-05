
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka Data Inconsistencies from Kafka Broker Replication Issues.
---

This incident type refers to situations where data inconsistencies arise due to issues with Kafka broker replication. Kafka brokers are responsible for replicating data across multiple nodes, ensuring that data is available even if one node fails. If there are issues with this replication process, it can result in data inconsistencies, where different nodes have different versions of the same data. This can cause a range of issues, including errors, data corruption, and other problems that can impact the functionality and reliability of the software system.

### Parameters
```shell
export TOPIC_NAME="PLACEHOLDER"

export BROKER_LIST="PLACEHOLDER"

export GROUP_NAME="PLACEHOLDER"

export KAFKA_CONFIG_FILE="PLACEHOLDER"

export DESIRED_REPLICATION_FACTOR="PLACEHOLDER"

export BROKER_ID="PLACEHOLDER"

export PATH_TO_KAFKA_HOME_DIRECTORY="PLACEHOLDER"
```

## Debug

### Check if Kafka broker is up and running
```shell
systemctl status kafka
```

### Check the replication status of Kafka brokers
```shell
kafka-topics --describe --bootstrap-server ${BROKER_LIST} --topic ${TOPIC_NAME}
```

### Check the status of the Kafka consumers
```shell
kafka-consumer-groups --bootstrap-server ${BROKER_LIST} --group ${GROUP_NAME} --describe
```

### Check for any errors in the Kafka logs
```shell
tail -f /var/log/kafka/kafka.log
```

### Check the status of the Kafka producers
```shell
kafka-console-producer --broker-list ${BROKER_LIST} --topic ${TOPIC_NAME}
```

### The Kafka cluster is not configured with enough replication factor, resulting in data inconsistencies when a broker goes down.
```shell


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


```

## Repair

### Check the replication settings and configurations. Ensure that the replication factor is set to a value that can handle the expected load and that the Kafka brokers are properly configured to handle replication.
```shell
bash

#!/bin/bash



# Set the desired replication factor and the location of the Kafka configuration file

REPLICATION_FACTOR=${DESIRED_REPLICATION_FACTOR}

KAFKA_CONFIG=${KAFKA_CONFIG_FILE}



# Update the replication factor in the Kafka configuration file

sed -i "s/replication.factor=.*/replication.factor=$REPLICATION_FACTOR/g" $KAFKA_CONFIG



# Restart the Kafka brokers to apply the updated configuration

sudo systemctl restart kafka


```