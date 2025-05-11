### 为什么 **Driver 最好也落在 compute 节点池**？

| 角度                  | 把 Driver 放 control‑plane 节点                                                                              | 把 Driver 放 compute 节点（推荐）                   |
| ------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| **1. 控制平面稳定性**      | Driver 会长时间占 CPU / 内存；若 Spark 作业多，可能挤占 `kube‑apiserver`、`etcd`、`controller‑manager` 的资源→ **调度卡顿、集群反应变慢** | compute 节点只跑业务 Pod，对控制面无任何干扰                |
| **2. Taint / 容忍配置** | 默认 `control-plane:NoSchedule`，每个 Spark 应用都要加 `tolerations`，配置繁琐                                          | compute 无 taint，Selector 简单；集群升级也少改动        |
| **3. 横向扩展与弹性**      | control‑plane 通常 1\~3 台，资源固定 > driver 一多就“顶天”                                                            | compute 可按需扩容；Driver 与 Executor 同池，资源配给逻辑清晰 |
| **4. 网络拓扑与数据本地性**   | Driver ↔ Executor ↔ Shuffle Service 跨池通信，**Hop 多 1 层**                                                   | 同池内部通信，延迟更低；跨节点带宽更可控                        |
| **5. O\&M 隔离**      | 控制面故障=业务全挂；日志混杂                                                                                          | 业务面故障只影响 Spark；控制面仍可运维排障                    |
| **6. 安全**           | 给 control‑plane 开 `exec` / `attach` 权限较敏感                                                                | compute 节点本就运行普通工作负载，安全域划分更清晰               |

> **一句话**：把 Driver 当成普通业务 Pod 处理，才能让控制平面保持“轻、稳、少变”。

---

#### 什么时候可以“临时”让 Driver 落 control‑plane？

| 场景                         | 合理性                          |
| -------------------------- | ---------------------------- |
| **本机 Kind / Minikube 单节点** | 只能跑在同一台，问题不大                 |
| **演示环境，集群 ≤ 3 台**          | 少量轻量级示例，可加 `tolerations` 临时跑 |
| **CI‑Pipeline** 的一次性作业     | 控制面负载可控，跑完即删                 |

一旦进入 **PoC 压测 / 生产**，就应把 control‑plane 保持纯粹，所有 Spark Driver、Flink JobManager 等都调度到 **专用工作节点池**。

---

#### 典型生产划分

```
            ┌─────────────────────────┐
            │   control‑plane pool    │   ✨ 只运行 kube‑system 组件
            └─────────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         │                           │
 ┌───────────────┐          ┌─────────────────┐
 │  compute pool │          │  storage / I/O  │
 │ (Spark, Flink)│          │ (Kafka, MinIO)  │
 └───────────────┘          └─────────────────┘
```

* **Driver + Executor** → `compute`
* **Kafka / HDFS / MinIO / ClickHouse** → 各自带 taint & label 的专用池
* **监控 sidecar** → 无 taint 池，或随应用混布

这样既能保证控制面和关键存储面安全稳定，又方便按业务线水平扩容。
