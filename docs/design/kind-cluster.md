## 思路
> **Kafka、Spark、MinIO 三者都部署在 *同一个 Kind Kubernetes 集群* 中，用 Pod+Service 隔离功能、使用 StatefulSet/Deployment 实现分布式、用 PVC 实现存储。**

它们通过 **K8s 的容器化机制完成逻辑解耦、资源隔离，但实质运行在一个 K8s 集群里（比如你的本地 Kind 集群）**。

---

##  理想架构图：一个 Kind 集群内的模块

```text
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

---

## 为什么只要一个 K8s 集群？

| 环节    | 是否分布式？                         | 是否独立容器？ | 是否需要单独 K8s？ | 原因                       |
| ----- | ------------------------------ | ------- | ----------- | ------------------------ |
| Kafka | ✅（用 StatefulSet 扩容）            | ✅       | ❌           | K8s 内分布式部署足矣             |
| Spark | ✅（Pod 调度 driver + executor）    | ✅       | ❌           | Spark on K8s 原生支持分布式     |
| MinIO | ✅（Standalone 或 Distributed 模式） | ✅       | ❌           | MinIO 可 StatefulSet 方式部署 |

---

##  存储与计算解耦靠什么实现？

| 类型    | 解耦方式                                       |
| ----- | ------------------------------------------ |
| Kafka | 存储在 Kafka 的 topic log（磁盘），消费由 Spark Pod 完成 |
| Spark | 不做存储，处理完的数据写入 MinIO                        |
| MinIO | 类似对象存储，持久化落盘，用 PVC（volume）挂载硬盘             |

---


## ✅ 最终你实现的能力是：

* Kafka 横向扩容 ✔
* Spark 横向扩容 ✔
* MinIO 分布式存储 ✔
* 三者运行在独立 Pod，K8s 控制资源 ✔
* 存储和计算解耦 ✔
* 本地开发可提交作业到 K8s ✔

