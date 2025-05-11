## Spark‑on‑Kubernetes Troubleshooting Notes

*(Bitnami Spark 3.3 on kind, May 2025)*

---

### 1  Executors exit immediately – **KerberosAuthException / Null input: name**

| Item           | Detail                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Symptom**    | • Executor Pods enter `Error / StartError` in < 1 s.<br>• Logs end with:<br>`org.apache.hadoop.security.KerberosAuthException: failure to login … LoginException: java.lang.NullPointerException: invalid null input: name`                                                                                                                                                                                                                  |
| **Root cause** | Bitnami images run as **UID 1001** but `/etc/passwd` has **no entry for 1001**. Hadoop UGI calls `System.getProperty("user.name")`; it returns `null` → Kerberos login fails.                                                                                                                                                                                                                                                                |
| **Fixes**      | **A (once‑for‑all)** add a passwd entry:<br>`USER 0` → `RUN echo "spark:x:1001:0:spark user:/opt/bitnami:/bin/bash" >> /etc/passwd` → `USER 1001` → rebuild image.<br><br>**B (no‑rebuild)** force Spark to advertise a user name:<br>`--conf spark.driver.extraJavaOptions=-Duser.name=spark`<br>`--conf spark.executor.extraJavaOptions=-Duser.name=spark`<br>(or disable Kerberos: `spark.hadoop.hadoop.security.authentication=Simple`). |

---

### 2  Executors cannot connect to Driver – **UnknownHostException spark‑driver**

| Item                                                                                                                                                                                                                                                                                                                                     | Detail                                                                                                                                                                              |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Symptom**                                                                                                                                                                                                                                                                                                                              | Executor logs:<br>`java.io.IOException: Failed to connect to spark-driver/<unresolved>`<br>`java.net.UnknownHostException: spark-driver`                                            |
| **Root cause**                                                                                                                                                                                                                                                                                                                           | In *client* deploy‑mode Spark encodes the driver URL as<br>`spark://...@spark-driver:<port>`.<br>No DNS record exists for bare host `spark-driver`, so executors cannot resolve it. |
| **Fixes**                                                                                                                                                                                                                                                                                                                                | **Option A (keep client mode)** – create a **headless Service**:  \`\`\`yaml                                                                                                        |
| apiVersion: v1                                                                                                                                                                                                                                                                                                                           |                                                                                                                                                                                     |
| kind: Service                                                                                                                                                                                                                                                                                                                            |                                                                                                                                                                                     |
| metadata: {name: spark-driver, namespace: spark}                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                     |
| spec: {clusterIP: None, selector: {app: spark, role: driver}}                                                                                                                                                                                                                                                                            |                                                                                                                                                                                     |
| \`\`\`<br>Executors resolve `spark-driver.spark.svc` automatically.<br><br>**Option B** – configure driver host/port explicitly:<br>`--conf spark.driver.host=spark-driver.spark.svc.cluster.local`<br>`--conf spark.driver.port=4040`.<br><br>**Option C** – switch to `--deploy-mode cluster`; Spark creates a driver Service for you. |                                                                                                                                                                                     |

---

### 3  Best‑practice checklist for Bitnami Spark on K8s

1. **Keep driver & executor images identical** (`spark.kubernetes.container.image=…`).
2. Make sure the image contains a valid passwd entry for the running UID *or* run as root.
3. Mount a writable Ivy cache: `--conf spark.jars.ivy=/opt/bitnami/.ivy2`.
4. If using *client* mode, expose driver via a headless Service.
5. During debugging add
   `--conf spark.kubernetes.{driver,executor}.deleteOnTermination=false`
   so failed Pods stay around for log inspection.

With these tweaks the sample SparkPi job (`spark‑examples_2.12‑3.3.4.jar`) runs to completion and prints:

```
Pi is roughly 3.14159
```
