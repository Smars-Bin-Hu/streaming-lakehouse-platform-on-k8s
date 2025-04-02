package com.smars.streamingdataplatform

import org.apache.spark.sql.{SparkSession, DataFrame}

object Main {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder()
      .appName("MyScalaSparkHelloWorld")
      .getOrCreate()

    import spark.implicits._

    val df: DataFrame = Seq(
      (1, "Alice"), (2, "Bob"), (3, "Cathy")
    ).toDF("id", "name")

    df.show()

    spark.stop()
  }
}

"""
  spark-submit \
   --class com.smars.streamingdataplatform.Main \
   --master yarn \
   --deploy-mode client \
   /opt/project2/scala_project/target/scala-2.12/big-data-engineering-project2_2.12-0.1.0-SNAPSHOT.jar
"""