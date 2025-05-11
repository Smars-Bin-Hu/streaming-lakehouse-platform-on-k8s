#!/bin/bash
# Java Environment
export JAVA_HOME=/opt/bitnami/java
export PATH=$JAVA_HOME/bin:$PATH

# resource
export SPARK_MASTER_HOST="" # (Spark on Yarn)
export SPARK_LOCAL_IP=$(hostname -i)  # Spark bound to container IP
export SPARK_WORKER_CORES=1
export SPARK_EXECUTOR_MEMORY=2g
export SPARK_DRIVER_MEMORY=1g

# enable Spark log history, for Spark History Server reading
#export SPARK_HISTORY_OPTS=""

# enable Spark log directory
export SPARK_LOG_DIR=/opt/bitnami/spark/logs
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.defaultCores=2"

# enable dynamic allocation
export SPARK_DYNAMIC_ALLOCATION_ENABLED=true
