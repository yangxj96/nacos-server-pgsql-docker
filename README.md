# Nacos V2.2.2版本的PostgreSQL版本

---
[原版链接](https://hub.docker.com/r/nacos/nacos-server)

具体的变量内容查看原版即可,只是我这边新增了几个变量,用于适配PostgreSQL数据库

> 构建脚本是从[Nacos Docker](https://github.com/nacos-group/nacos-docker)克隆后
> 在build文件夹下的构建脚本构建的.进行过一些修改

[构建脚本仓库链接](https://github.com/yangxj96/nacos-server-pgsql-docker)

---
# 一 新增的环境变量

| 变量名            |    说明    | 示例                                                       |
|:---------------|:--------:|----------------------------------------------------------|
| PGSQL_URL      | JDBC URL | jdbc:postgresql://localhost:5432/db?currentSchema=schema |
| PGSQL_USERNAME |  数据库用户名  | postgres                                                 |
| PGSQL_PASSWORD |  数据库密码   | postgres                                                 |


# 二 docker-compose运行示例

## docker-compose 文件


```yaml
version: "3"
services:
  yangxj96-nacos2:
    image: yangxj96/nacos-service-pgsql:v2.2.2
    container_name: nacos-pgsql
    privileged: true
    env_file:
      - "/Nacos/env/pgsql.env"
    network_mode: host
    volumes:
      - "/Nacos/logs/:/home/nacos/logs"
```
## 环境变量文件


```yaml
PREFER_HOST_MODE=ip
SPRING_DATASOURCE_PLATFORM=postgresql
PGSQL_URL=jdbc:postgresql://localhost:5432/db?currentSchema=schema
PGSQL_USERNAME=postgres
PGSQL_PASSWORD=postgres
```

# 三 构建脚本

### 1.docker-compose.yml

```dockerfile
FROM centos:7.9.2009
MAINTAINER yangxj96 "yangxj96@126.com"

# set environment
ENV MODE="standalone" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk" \
    NACOS_USER="nacos" \
    JAVA="/usr/lib/jvm/java-1.8.0-openjdk/bin/java" \
    JVM_XMS="1g" \
    JVM_XMX="1g" \
    JVM_XMN="512m" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false" \
    TIME_ZONE="Asia/Shanghai"

ARG NACOS_VERSION=2.2.2
ARG HOT_FIX_FLAG=""

WORKDIR $BASE_DIR


RUN set -x \
    # 网络好可以更新下
    #  && yum update -y \
    && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget iputils nc vim libcurl

# copy nacos-server.tar.gz
COPY app/nacos-server-${NACOS_VERSION}.tar.gz /home
# 网络好的话可替换成从github下载
# RUN wget --no-check-certificate https://github.com/alibaba/nacos/releases/download/${NACOS_VERSION}${HOT_FIX_FLAG}/nacos-server-${NACOS_VERSION}.tar.gz -P /home

# Unzip the file and delete unnecessary files
RUN tar -xzvf /home/nacos-server-${NACOS_VERSION}.tar.gz -C /home \
    && rm -rf /home/nacos-server-${NACOS_VERSION}.tar.gz /home/nacos/conf/*.properties /home/nacos/conf/*.example /home/nacos/conf/nacos-mysql.sql

# Synchronization time
RUN yum autoremove -y wget \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && yum clean all

# copy pgsql plugin
# 插件下载位置: https://github.com/nacos-group/nacos-plugin.git
# 下载后在最外层进行编译,
# nacos-plugin\nacos-datasource-plugin-ext\nacos-postgresql-datasource-plugin-ext\target\nacos-postgresql-datasource-plugin-ext-1.0.0-SNAPSHOT.jar
# 名字太长了,被我重命名为nacos-postgresql.jar了
COPY plugins/nacos-postgresql.jar /home/nacos/plugins/nacos-postgresql.jar

ADD bin/docker-startup.sh bin/docker-startup.sh
ADD conf/application.properties conf/application.properties

# set startup log dir
RUN mkdir -p logs \
	&& cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout start.out \
	&& ln -sf /dev/stderr start.out


RUN chmod +x bin/docker-startup.sh

EXPOSE 8848
ENTRYPOINT ["bin/docker-startup.sh"]

```

### 2.application.properties

```properties
# spring
server.servlet.contextPath=${SERVER_SERVLET_CONTEXTPATH:/nacos}
server.contextPath=/nacos
server.port=${NACOS_APPLICATION_PORT:8848}
server.tomcat.accesslog.max-days=30
server.tomcat.accesslog.pattern=%h %l %u %t "%r" %s %b %D %{User-Agent}i %{Request-Source}i
server.tomcat.accesslog.enabled=${TOMCAT_ACCESSLOG_ENABLED:false}
# default current work dir
server.tomcat.basedir=file:.
#*************** Config Module Related Configurations ***************#
### Deprecated configuration property, it is recommended to use `spring.sql.init.platform` replaced.

nacos.cmdb.dumpTaskInterval=3600
nacos.cmdb.eventTaskInterval=10
nacos.cmdb.labelTaskInterval=300
nacos.cmdb.loadDataAtStart=false
# database config
spring.sql.init.platform=${SPRING_DATASOURCE_PLATFORM:postgresql}
db.num=${MYSQL_DATABASE_NUM:1}
db.url.0=${PGSQL_URL}
db.user.0=${PGSQL_USERNAME}
db.password.0=${PGSQL_PASSWORD}
db.pool.config.driverClassName=org.postgresql.Driver

### The auth system to use, currently only 'nacos' and 'ldap' is supported:
nacos.core.auth.system.type=${NACOS_AUTH_SYSTEM_TYPE:nacos}
### worked when nacos.core.auth.system.type=nacos
### The token expiration in seconds:
nacos.core.auth.plugin.nacos.token.expire.seconds=${NACOS_AUTH_TOKEN_EXPIRE_SECONDS:18000}
### The default token:
nacos.core.auth.plugin.nacos.token.secret.key=${NACOS_AUTH_TOKEN}
### Turn on/off caching of auth information. By turning on this switch, the update of auth information would have a 15 seconds delay.
nacos.core.auth.caching.enabled=${NACOS_AUTH_CACHE_ENABLE:false}
nacos.core.auth.enable.userAgentAuthWhite=${NACOS_AUTH_USER_AGENT_AUTH_WHITE_ENABLE:false}
nacos.core.auth.server.identity.key=${NACOS_AUTH_IDENTITY_KEY}
nacos.core.auth.server.identity.value=${NACOS_AUTH_IDENTITY_VALUE}
## spring security config
### turn off security
nacos.security.ignore.urls=${NACOS_SECURITY_IGNORE_URLS:/,/error,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/v1/auth/**,/v1/console/health/**,/actuator/**,/v1/console/server/**}
# metrics for elastic search
management.metrics.export.elastic.enabled=false
management.metrics.export.influx.enabled=false
nacos.naming.distro.taskDispatchThreadCount=10
nacos.naming.distro.taskDispatchPeriod=200
nacos.naming.distro.batchSyncKeyCount=1000
nacos.naming.distro.initDataRatio=0.9
nacos.naming.distro.syncRetryDelay=5000
nacos.naming.data.warmup=true
```

### 3.docker-startup.sh

```shell
#!/bin/bash
# Copyright 1999-2018 Alibaba Group Holding Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -x
export CUSTOM_SEARCH_NAMES="application"
export CUSTOM_SEARCH_LOCATIONS=file:${BASE_DIR}/conf/
export MEMBER_LIST=""
PLUGINS_DIR="/home/nacos/plugins"
function print_servers() {
   if [[ ! -d "${PLUGINS_DIR}" ]]; then
    echo "" >"$CLUSTER_CONF"
    for server in ${NACOS_SERVERS}; do
      echo "$server" >>"$CLUSTER_CONF"
    done
  else
    bash $PLUGINS_DIR/plugin.sh
    sleep 30
  fi
}
#===========================================================================================
# JVM Configuration
#===========================================================================================
if [[ "${MODE}" == "standalone" ]]; then

  JAVA_OPT="${JAVA_OPT} -Xms${JVM_XMS} -Xmx${JVM_XMX} -Xmn${JVM_XMN}"
  JAVA_OPT="${JAVA_OPT} -Dnacos.standalone=true"
else
  if [[ "${EMBEDDED_STORAGE}" == "embedded" ]]; then
    JAVA_OPT="${JAVA_OPT} -DembeddedStorage=true"
  fi
  JAVA_OPT="${JAVA_OPT} -server -Xms${JVM_XMS} -Xmx${JVM_XMX} -Xmn${JVM_XMN} -XX:MetaspaceSize=${JVM_MS} -XX:MaxMetaspaceSize=${JVM_MMS}"
  if [[ "${NACOS_DEBUG}" == "y" ]]; then
    JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"
  fi
  JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${BASE_DIR}/logs/java_heapdump.hprof"
  JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages"
  print_servers
fi

#===========================================================================================
# Setting system properties
#===========================================================================================
# set  mode that Nacos Server function of split
if [[ "${FUNCTION_MODE}" == "config" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=config"
elif [[ "${FUNCTION_MODE}" == "naming" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.functionMode=naming"
fi
# set nacos server ip
if [[ ! -z "${NACOS_SERVER_IP}" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.server.ip=${NACOS_SERVER_IP}"
fi

if [[ ! -z "${USE_ONLY_SITE_INTERFACES}" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.use-only-site-local-interfaces=${USE_ONLY_SITE_INTERFACES}"
fi

if [[ ! -z "${PREFERRED_NETWORKS}" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.preferred-networks=${PREFERRED_NETWORKS}"
fi

if [[ ! -z "${IGNORED_INTERFACES}" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.inetutils.ignored-interfaces=${IGNORED_INTERFACES}"
fi

### If turn on auth system:
if [[ ! -z "${NACOS_AUTH_ENABLE}" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.core.auth.enabled=${NACOS_AUTH_ENABLE}"
fi

if [[ "${PREFER_HOST_MODE}" == "hostname" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dnacos.preferHostnameOverIp=true"
fi
JAVA_OPT="${JAVA_OPT} -Dnacos.member.list=${MEMBER_LIST}"

JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
if [[ "$JAVA_MAJOR_VERSION" -ge "9" ]]; then
  JAVA_OPT="${JAVA_OPT} -cp .:${BASE_DIR}/plugins/cmdb/*.jar:${BASE_DIR}/plugins/mysql/*.jar"
  JAVA_OPT="${JAVA_OPT} -Xlog:gc*:file=${BASE_DIR}/logs/nacos_gc.log:time,tags:filecount=10,filesize=102400"
else
  JAVA_OPT="${JAVA_OPT} -Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext:${BASE_DIR}/plugins/health:${BASE_DIR}/plugins/cmdb:${BASE_DIR}/plugins/mysql"
  JAVA_OPT="${JAVA_OPT} -Xloggc:${BASE_DIR}/logs/nacos_gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M"
fi

# 主要是加了这一行,用于加载插件目录下的插件
JAVA_OPT="${JAVA_OPT} -Dloader.path=${BASE_DIR}/plugins,${BASE_DIR}/plugins/health,${BASE_DIR}/plugins/cmdb,${BASE_DIR}/plugins/selector"
JAVA_OPT="${JAVA_OPT} -Dnacos.home=${BASE_DIR}"
JAVA_OPT="${JAVA_OPT} -jar ${BASE_DIR}/target/nacos-server.jar"
JAVA_OPT="${JAVA_OPT} ${JAVA_OPT_EXT}"
JAVA_OPT="${JAVA_OPT} --spring.config.additional-location=${CUSTOM_SEARCH_LOCATIONS}"
JAVA_OPT="${JAVA_OPT} --spring.config.name=${CUSTOM_SEARCH_NAMES}"
JAVA_OPT="${JAVA_OPT} --logging.config=${BASE_DIR}/conf/nacos-logback.xml"
JAVA_OPT="${JAVA_OPT} --server.max-http-header-size=524288"


echo "Nacos is starting, you can docker logs your container"
exec $JAVA ${JAVA_OPT}

```

# 四 更新日志

## v2.2.2

> 初始版本

## v2.2.2-1

- 修复docker 23.0.3 版本下无法运行
- 添加 ```NACOS_AUTH_TOKEN,NACOS_AUTH_IDENTITY_KEY,NACOS_AUTH_IDENTITY_VALUE```的默认值(和官方默认值一样)

#### 以上均为自己理解的内容,也许会是误打误撞搞出来的. 如有哪里不正确,请见谅