# use OpenJDK 11 as the base image
FROM openjdk:11-jre-slim

# setup enviroment variables
ENV SPARK_VERSION=3.3.0
ENV HADOOP_VERSION=3.3.1
ENV SPARK_HOME=/opt/spark

# install basic tools
RUN apt-get update && \
    apt-get install -y curl vim net-tools procps iputils-ping wget htop dnsutils telnet openssh-client tree && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download Spark
RUN curl -L https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz | tar -xz -C /opt && \
    ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} ${SPARK_HOME}

# config Spark variables
ENV PATH=${SPARK_HOME}/bin:${PATH}

# expose Spark Web UI port
EXPOSE 4040

# config working directory
WORKDIR ${SPARK_HOME}

# default command after container start
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]