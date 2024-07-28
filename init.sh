#!/bin/bash

# 检查当前的默认JDK版本
JAVA_VERSION=$(java -version 2>&1 | awk -F[\"_] '/version/ {print $2}')
EXPECTED_VERSION="17"

# 函数：下载并安装JDK 17
install_jdk17() {
    JDK_URL="https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz"
    JDK_INSTALL_DIR="/usr/lib/jvm/jdk-17"

    echo "Downloading JDK 17..."
    curl -L $JDK_URL -o /tmp/jdk-17.tar.gz
    echo "Extracting JDK 17..."
    sudo mkdir -p $JDK_INSTALL_DIR
    sudo tar -xzf /tmp/jdk-17.tar.gz -C $JDK_INSTALL_DIR --strip-components=1

    # 设置JAVA_HOME
    export JAVA_HOME=$JDK_INSTALL_DIR
    echo "Setting JAVA_HOME to $JAVA_HOME"

    # 更新 alternatives 系统以设置默认JDK
    sudo update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
    sudo update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1
    sudo update-alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 1

    # 设置默认JDK
    sudo update-alternatives --set java $JAVA_HOME/bin/java
    sudo update-alternatives --set javac $JAVA_HOME/bin/javac
    sudo update-alternatives --set jar $JAVA_HOME/bin/jar

    # 更新PATH以确保使用新的JDK
    export PATH=$JAVA_HOME/bin:$PATH

    # 设置 Maven 的 JAVA_HOME 和 MAVEN_OPTS
    echo "Setting MAVEN_OPTS to use JDK 17"
    export MAVEN_OPTS="-Dmaven.compiler.source=17 -Dmaven.compiler.target=17 -Dmaven.compiler.release=17"

    # 验证安装
    java -version
    echo "Maven using JAVA_HOME: $JAVA_HOME"
    mvn -v
}

# 函数：删除当前默认JDK
remove_current_jdk() {
    echo "Removing current JDK..."
    sudo update-alternatives --remove-all java
    sudo update-alternatives --remove-all javac
    sudo update-alternatives --remove-all jar
}

# 检查当前JDK版本并采取相应行动
if [[ "$JAVA_VERSION" == "$EXPECTED_VERSION" ]]; then
    echo "Java is already version 17."
    java -version
else
    echo "Java version is not 17."
    remove_current_jdk
    install_jdk17
fi

# 在项目根目录执行一次 maven install
mvn clean install -DskipTests
