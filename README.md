# Nacos 的PostgreSQL版本

---
[原版链接](https://hub.docker.com/r/nacos/nacos-server)

具体的变量内容查看原版即可,只是我这边新增了几个变量 

用于适配PostgreSQL数据库

构建脚本是从[Nacos Docker](https://github.com/nacos-group/nacos-docker)克隆后

在build文件夹下的构建脚本构建的.进行过一些修改

[当前镜像构建脚本仓库链接](https://github.com/yangxj96/nacos-server-pgsql-docker)

---

## 一 新增的环境变量

| 变量名            | 说明       | 示例                                                       |
|:---------------|:---------|:---------------------------------------------------------|
| PGSQL_URL      | JDBC URL | jdbc:postgresql://localhost:5432/db?currentSchema=schema |
| PGSQL_USERNAME | 数据库用户名   | postgres                                                 |
| PGSQL_PASSWORD | 数据库密码    | postgres                                                 |

## 二 docker-compose运行示例

#### docker-compose 文件

```yaml
version: "3"
services:
  nacos:
    image: yangxj96/nacos-service-pgsql:v2.2.2-2
    container_name: nacos-pgsql
    privileged: true
    env_file:
      - "/Nacos/env/pgsql.env"
    network_mode: host
    volumes:
      - "/Nacos/logs/:/home/nacos/logs"
```

#### pgsql.env

```yaml
PREFER_HOST_MODE=ip
SPRING_DATASOURCE_PLATFORM=postgresql
PGSQL_URL=jdbc:postgresql://localhost:5432/db?currentSchema=schema
PGSQL_USERNAME=postgres
PGSQL_PASSWORD=postgres
```



## 三 常见问题

- caused: Incorrect result size: expected 1, actual 2;

> 目前发现这个问题应该是2.2.3版本的数据库有过改动,可以在[当前镜像构建脚本仓库链接](https://github.com/yangxj96/nacos-server-pgsql-docker)的schema文件夹下获取到pgsql的导入脚本,
> 具体步骤为: 
> 1. 在现有的nacos中把配置文件等内容导出,
> 2. 清空nacos连接的数据库,
> 3. 使用schema文件夹下的脚本进行初始化
> 4. 导入配置文件等内容

## 四 更新日志

### v2.3.0

- 更新nacos包到2.3.0版本

### v2.2.3-dragonwell

- 添加了以龙威11为java jdk的2.2.3版本
- 下载命令 ```docker pull yangxj96/nacos-server-pgsql:v2.2.3-dragonwell```

### v2.2.2-2

> 之前下载后使用大概1.1GB左右,本次更新主要为缩小镜像大小

- 切换基础镜像到```amazoncorretto:8u362-alpine3.17-jre```,大小只有150M左右
- 优化一些操作,缩小包内容
- 整体镜像缩减到278.7MB

### v2.2.2-1

- 修复docker 23.0.3 版本下无法运行
- 添加 ```NACOS_AUTH_TOKEN,NACOS_AUTH_IDENTITY_KEY,NACOS_AUTH_IDENTITY_VALUE```的默认值(和官方默认值一样)


### v2.2.2

> 初始版本
