
```text
realtime-data-platform/
├── README.md
├── docker/                       # 所有 Dockerfile 构建镜像的目录
│   ├── spark/
│   ├── minio/
│   ├── springboot-api/
│   └── ...
├── k8s/                         # Kubernetes 所有 YAML 配置文件
│   ├── base/                    # 核心组件部署（手动写的）
│   │   ├── zookeeper.yaml
│   │   ├── kafka-statefulset.yaml
│   │   ├── spark-driver.yaml
│   │   ├── spark-executor.yaml
│   │   ├── minio-statefulset.yaml
│   │   ├── elasticsearch.yaml
│   │   ├── kibana.yaml
│   │   └── prometheus-grafana.yaml
│   ├── config/                  # ConfigMap, Secret, Volume 配置
│   │   ├── spark-configmap.yaml
│   │   ├── log4j-configmap.yaml
│   │   ├── minio-configmap.yaml
│   │   └── prometheus-configmap.yaml
│   ├── services/                # 各组件的 Service 定义
│   │   ├── kafka-service.yaml
│   │   ├── spark-service.yaml
│   │   ├── minio-service.yaml
│   │   ├── es-service.yaml
│   │   └── grafana-service.yaml
│   └── jobs/                    # Spark Job 任务提交清单
│       └── spark-submit-job.yaml
├── helm/                         # 可选：Helm Charts 存放目录（如 Spark Operator）
├── manifests/                    # 组合部署清单（汇总 apply 顺序）
│   ├── dev-cluster-all.yaml     # 所有配置一键部署（开发用）
│   └── monitoring-stack.yaml
└── scripts/                      # 一键启动 / 部署脚本
    ├── build-all.sh
    ├── deploy-all.sh
    └── spark-submit-job.sh

```

```text
[Kind Host Machine]
└── Kubernetes Single Node Cluster（Kind）
    ├── spark-driver Pod (also executor)
    ├── spark-executor-1 Pod
    └── spark-executor-2 Pod
```
