#!/bin/bash

# 脚本开始时间
START_TIME=$(date +%s)

# 项目的根目录
PROJECT_DIR=$(pwd)

# 要打包的模块
PARENT_MODULE="services"

# 子模块的路径
PARENT_MODULE_DIR="$PROJECT_DIR/$PARENT_MODULE"

# 确保父模块目录存在
if [ ! -d "$PARENT_MODULE_DIR" ]; then
    echo "Parent module directory $PARENT_MODULE_DIR does not exist. Exiting..."
    exit 1
fi

# 进入父模块目录
cd "$PARENT_MODULE_DIR" || { echo "Failed to change directory to $PARENT_MODULE_DIR. Exiting..."; exit 1; }

# 获取所有子模块目录
SUBMODULES=$(find . -mindepth 1 -maxdepth 1 -type d -not -name 'target')

# 遍历并打包每个子模块
for SUBMODULE in $SUBMODULES; do
    echo "Building module $(basename "$SUBMODULE")..."
    cd "$SUBMODULE" || { echo "Failed to change directory to $SUBMODULE. Exiting..."; exit 1; }

    # 清理子模块
    mvn clean

    # 打包子模块
    mvn package -DskipTests

    # 检查构建是否成功
    if [ $? -ne 0 ]; then
        echo "Build failed for module $(basename "$SUBMODULE"). Exiting..."
        exit 1
    fi

    # 打印构建信息
    echo "Build completed successfully for module $(basename "$SUBMODULE")."

    # 列出打包的 JAR 文件
    echo "Listing built JAR files for module $(basename "$SUBMODULE"):"
    find target -name "*.jar"

    # 返回到父模块目录
    cd "$PARENT_MODULE_DIR" || { echo "Failed to change directory back to $PARENT_MODULE_DIR. Exiting..."; exit 1; }
done

# 计算并打印构建时间
END_TIME=$(date +%s)
BUILD_EXECUTION_TIME=$(($END_TIME - $START_TIME))
echo "Build script executed in ${BUILD_EXECUTION_TIME} seconds."

# 启动 Docker Compose
echo "Starting Docker Compose..."
docker compose -f "$PROJECT_DIR/docker/docker-compose-prod.yaml" up -d

# 计算并打印 Docker Compose 启动时间
DOCKER_END_TIME=$(date +%s)
DOCKER_EXECUTION_TIME=$(($DOCKER_END_TIME - $END_TIME))
echo "Docker Compose executed in ${DOCKER_EXECUTION_TIME} seconds."



