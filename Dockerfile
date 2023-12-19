FROM amazoncorretto:8u362-alpine3.17-jre

LABEL author="yangxj96"
LABEL email="yangxj96@126.com"

# 设置环境变量
ENV MODE="standalone" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    JAVA_HOME="/usr/lib/jvm/java-8-amazon-corretto" \
    NACOS_USER="nacos" \
    JAVA="/usr/lib/jvm/java-8-amazon-corretto/bin/java" \
    JVM_XMS="512m" \
    JVM_XMX="512m" \
    JVM_XMN="256m" \
    JVM_MS="64m" \
    JVM_MMS="160m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false" \
    TIME_ZONE="Asia/Shanghai"

ARG NACOS_VERSION=2.3.0
ARG HOT_FIX_FLAG=""

WORKDIR $BASE_DIR

# 添加必备环境变量
RUN apk add --no-cache openssl ncurses-libs libstdc++ curl

# 添加nacos文件,
# 必须使用ADD 是用COPY后在删除.tar.gz文件,镜像大小不会被删除,无缘无故多了.tar.gz同等大小的的镜像空间,暂不了解为什么
# 但是使用ADD会自动解压文件.不会造成多出的.tar.gz同样大小的空间
# 下载nacos的位置 https://github.com/alibaba/nacos/releases
RUN curl -L https://github.com/alibaba/nacos/releases/download/"$NACOS_VERSION"/nacos-server-"$NACOS_VERSION".tar.gz -o /home/nacos-server-2.2.3.tar.gz \
    && tar -C /home -xzvf /home/nacos-server-2.2.3.tar.gz \
    && rm -rf /home/nacos-server-2.2.3.tar.gz /home/nacos/bin/* /home/nacos/conf/*.properties /home/nacos/conf/*.example /home/nacos/conf/*.sql \
    && ln -snf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime && echo "$TIME_ZONE" > /etc/timezone

# 设置时间同步
# RUN ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

# 复制插件
COPY plugins/nacos-postgresql.jar /home/nacos/plugins/nacos-postgresql.jar

# 添加运行脚本和默认配置脚本
ADD bin/docker-startup.sh bin/docker-startup.sh
ADD conf/application.properties conf/application.properties

RUN mkdir -p logs \
	&& cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout start.out \
	&& ln -sf /dev/stderr start.out

EXPOSE 8848 9848 9849

WORKDIR $BASE_DIR/bin

RUN chmod +x docker-startup.sh

ENTRYPOINT ["/bin/ash","docker-startup.sh"]

