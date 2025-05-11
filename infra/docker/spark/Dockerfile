FROM bitnami/spark:3.3

# 为 1001 添用户名，JDK 就能正常解析
USER 0
RUN echo "spark:x:1001:0:spark user:/opt/bitnami:/bin/bash" >> /etc/passwd
USER 1001