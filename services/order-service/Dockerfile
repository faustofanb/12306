# 使用一个基础镜像，通常是一个包含JDK的轻量级Linux镜像
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /app

# 复制应用的JAR文件到容器中
COPY target/index12306-order-service-0.0.1-SNAPSHOT.jar /app/app.jar

# 暴露应用运行的端口
EXPOSE 9003

# 指定容器启动时运行的命令
ENTRYPOINT ["java", "-jar","-Dspring.profiles.active=prod","/app/app.jar"]
