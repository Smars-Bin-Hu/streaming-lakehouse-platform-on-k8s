# 创建集群
kind delete cluster --name data-pipeline && kind create cluster --name data-pipeline --config ./infra/kind-config.yaml

# 确认节点标签 / taint
kubectl get nodes --show-labels
kubectl describe node kafka-1 | grep Taints

# 查看namespace下的pods和资源实例
kubectl get pods -n spark
kubectl get all -n spark # (pods + services + )

kubectl get configmap -n spark
kubectl get secret -n spark
kubectl get serviceaccount -n spark
kubectl get pvc -n spark
kubectl get statefulset -n spark

# 登录Pod
kubectl exec -it spark-driver -n spark -- /bin/bash

############################################### Spark on K8s ##################################################
# 创建 namespace / Spark services
kubectl apply -f infra/k8s/base/spark/namespace.yaml
kubectl apply -f infra/k8s/services/spark/spark-service.yaml

# 动态创建 ConfigMap
kubectl delete configmap spark-config -n spark && kubectl create configmap spark-config \
--from-file=spark-defaults.conf=./infra/k8s/config/spark/spark-defaults.conf \
--from-file=log4j2.properties=./infra/k8s/config/spark/log4j2.properties \
--from-file=spark-env.sh=./infra/k8s/config/spark/spark-env.sh \
-n spark

# 删除旧的pod && 创建新的 Spark Driver Pod
kubectl delete pods --all -n spark && kubectl apply -f infra/k8s/base/spark/spark-driver-pod.yaml

# 观察调度结果
kubectl get pods -n spark -o wide            # Driver 是否在 Compute
kubectl get pods -l spark-role=executor -n spark -o wide   # Executor 是否在 compute-X
kubectl describe pod spark-driver -n spark    # 查看pod信息

# 查看Spark运行日志
kubectl logs spark-driver -n spark
kubectl logs spark-hello-355ba696bd5cb34e-driver -n spark -c spark-kubernetes-executor
kubectl logs spark-pi-d1fded96bd4a60a8-exec-2 -n spark -c spark-kubernetes-executor
############################################### Spark on K8s ##################################################


############################################### Kafka on K8s ##################################################
# 动态扩容kafka
kubectl -n kafka scale statefulset kafka --replicas=4
############################################### Kafka on K8s ##################################################