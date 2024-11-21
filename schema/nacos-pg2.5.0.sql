DROP TABLE IF EXISTS config_info;
CREATE TABLE IF NOT EXISTS config_info
(
    id                 BIGSERIAL PRIMARY KEY,
    data_id            VARCHAR(255)  NOT NULL,
    group_id           VARCHAR(128)           DEFAULT NULL,
    content            TEXT          NOT NULL,
    md5                VARCHAR(32)            DEFAULT NULL,
    gmt_create         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user           TEXT,
    src_ip             VARCHAR(50)            DEFAULT NULL,
    app_name           VARCHAR(128)           DEFAULT NULL,
    tenant_id          VARCHAR(128)           DEFAULT '',
    c_desc             VARCHAR(256)           DEFAULT NULL,
    c_use              VARCHAR(64)            DEFAULT NULL,
    effect             VARCHAR(64)            DEFAULT NULL,
    type               VARCHAR(64)            DEFAULT NULL,
    c_schema           TEXT,
    encrypted_data_key VARCHAR(1024) NOT NULL DEFAULT ''
);
CREATE UNIQUE INDEX uk_configinfo_datagrouptenant ON config_info (data_id, group_id, tenant_id);

DROP TABLE IF EXISTS config_info_aggr;
CREATE TABLE IF NOT EXISTS config_info_aggr
(
    "id"           BIGSERIAL PRIMARY KEY,
    "data_id"      VARCHAR(255) NOT NULL,
    "group_id"     VARCHAR(255) NOT NULL,
    "datum_id"     VARCHAR(255) NOT NULL,
    "content"      TEXT         NOT NULL,
    "gmt_modified" TIMESTAMP(6) NOT NULL,
    "app_name"     VARCHAR(128),
    "tenant_id"    VARCHAR(128)
);

DROP TABLE IF EXISTS config_info_gray;
CREATE TABLE IF NOT EXISTS config_info_gray
(
    id                 BIGSERIAL PRIMARY KEY,
    data_id            VARCHAR(255) NOT NULL,
    group_id           VARCHAR(128) NOT NULL,
    content            TEXT         NOT NULL,
    md5                VARCHAR(32)           DEFAULT NULL,
    src_user           TEXT,
    src_ip             VARCHAR(100)          DEFAULT NULL,
    gmt_create         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    app_name           VARCHAR(128)          DEFAULT NULL,
    tenant_id          VARCHAR(128)          DEFAULT '',
    gray_name          VARCHAR(128) NOT NULL,
    gray_rule          TEXT         NOT NULL,
    encrypted_data_key VARCHAR(256) NOT NULL DEFAULT ''
);
CREATE UNIQUE INDEX uk_configinfogray_datagrouptenantgray ON config_info_gray (data_id, group_id, tenant_id, gray_name);
CREATE INDEX idx_dataid_gmt_modified ON config_info_gray (data_id, gmt_modified);
CREATE INDEX idx_config_info_gray_gmt_modified ON config_info_gray (gmt_modified);

DROP TABLE IF EXISTS config_info_beta;
CREATE TABLE IF NOT EXISTS config_info_beta
(
    id                 BIGSERIAL PRIMARY KEY,
    data_id            VARCHAR(255)  NOT NULL,
    group_id           VARCHAR(128)  NOT NULL,
    app_name           VARCHAR(128)           DEFAULT NULL,
    content            TEXT          NOT NULL,
    beta_ips           VARCHAR(1024)          DEFAULT NULL,
    md5                VARCHAR(32)            DEFAULT NULL,
    gmt_create         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user           TEXT,
    src_ip             VARCHAR(50)            DEFAULT NULL,
    tenant_id          VARCHAR(128)           DEFAULT '',
    encrypted_data_key VARCHAR(1024) NOT NULL DEFAULT ''
);
CREATE UNIQUE INDEX uk_configinfobeta_datagrouptenant ON config_info_beta (data_id, group_id, tenant_id);


DROP TABLE IF EXISTS config_info_tag;
CREATE TABLE IF NOT EXISTS config_info_tag
(
    id           BIGSERIAL PRIMARY KEY,
    data_id      VARCHAR(255) NOT NULL,
    group_id     VARCHAR(128) NOT NULL,
    tenant_id    VARCHAR(128)          DEFAULT '',
    tag_id       VARCHAR(128) NOT NULL,
    app_name     VARCHAR(128)          DEFAULT NULL,
    content      TEXT         NOT NULL,
    md5          VARCHAR(32)           DEFAULT NULL,
    gmt_create   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user     TEXT,
    src_ip       VARCHAR(50)           DEFAULT NULL
);
CREATE UNIQUE INDEX uk_configinfotag_datagrouptenanttag ON config_info_tag (data_id, group_id, tenant_id, tag_id);


DROP TABLE IF EXISTS config_tags_relation;
CREATE TABLE IF NOT EXISTS config_tags_relation
(
    id        BIGINT       NOT NULL,
    tag_name  VARCHAR(128) NOT NULL,
    tag_type  VARCHAR(64)  DEFAULT NULL,
    data_id   VARCHAR(255) NOT NULL,
    group_id  VARCHAR(128) NOT NULL,
    tenant_id VARCHAR(128) DEFAULT '',
    nid       BIGSERIAL PRIMARY KEY
);
CREATE UNIQUE INDEX uk_configtagrelation_configidtag ON config_tags_relation (id, tag_name, tag_type);
CREATE INDEX idx_config_tags_relation_tenant_id ON config_tags_relation (tenant_id);


DROP TABLE IF EXISTS group_capacity;
CREATE TABLE IF NOT EXISTS group_capacity
(
    id                BIGSERIAL PRIMARY KEY,
    group_id          VARCHAR(128) NOT NULL DEFAULT '',
    quota             INT          NOT NULL DEFAULT 0,
    usage             INT          NOT NULL DEFAULT 0,
    max_size          INT          NOT NULL DEFAULT 0,
    max_aggr_count    INT          NOT NULL DEFAULT 0,
    max_aggr_size     INT          NOT NULL DEFAULT 0,
    max_history_count INT          NOT NULL DEFAULT 0,
    gmt_create        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX uk_group_id ON group_capacity (group_id);


DROP TABLE IF EXISTS his_config_info;
CREATE TABLE IF NOT EXISTS his_config_info
(
    id                 BIGINT        NOT NULL,
    nid                BIGSERIAL PRIMARY KEY,
    data_id            VARCHAR(255)  NOT NULL,
    group_id           VARCHAR(128)  NOT NULL,
    app_name           VARCHAR(128)           DEFAULT NULL,
    content            TEXT          NOT NULL,
    md5                VARCHAR(32)            DEFAULT NULL,
    gmt_create         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    src_user           TEXT,
    src_ip             VARCHAR(50)            DEFAULT NULL,
    op_type            CHAR(10)               DEFAULT NULL,
    tenant_id          VARCHAR(128)           DEFAULT '',
    encrypted_data_key VARCHAR(1024) NOT NULL DEFAULT '',
    publish_type       VARCHAR(50)            DEFAULT 'formal',
    ext_info           TEXT                   DEFAULT NULL
);
CREATE INDEX idx_gmt_create ON his_config_info (gmt_create);
CREATE INDEX idx_his_config_info_gmt_modified ON his_config_info (gmt_modified);
CREATE INDEX idx_did ON his_config_info (data_id);

DROP TABLE IF EXISTS tenant_capacity;
CREATE TABLE IF NOT EXISTS tenant_capacity
(
    id                BIGSERIAL PRIMARY KEY,
    tenant_id         VARCHAR(128) NOT NULL DEFAULT '',
    quota             INT          NOT NULL DEFAULT 0,
    usage             INT          NOT NULL DEFAULT 0,
    max_size          INT          NOT NULL DEFAULT 0,
    max_aggr_count    INT          NOT NULL DEFAULT 0,
    max_aggr_size     INT          NOT NULL DEFAULT 0,
    max_history_count INT          NOT NULL DEFAULT 0,
    gmt_create        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX uk_tenant_id ON tenant_capacity (tenant_id);

DROP TABLE IF EXISTS tenant_info;
CREATE TABLE IF NOT EXISTS tenant_info
(
    id            BIGSERIAL PRIMARY KEY,
    kp            VARCHAR(128) NOT NULL,
    tenant_id     VARCHAR(128) DEFAULT '',
    tenant_name   VARCHAR(128) DEFAULT '',
    tenant_desc   VARCHAR(256) DEFAULT NULL,
    create_source VARCHAR(32)  DEFAULT NULL,
    gmt_create    BIGINT       NOT NULL,
    gmt_modified  BIGINT       NOT NULL
);
CREATE UNIQUE INDEX uk_tenant_info_kptenantid ON tenant_info (kp, tenant_id);
CREATE INDEX idx_tenant_info_tenant_id ON tenant_info (tenant_id);

DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users
(
    username VARCHAR(50)  NOT NULL PRIMARY KEY,
    password VARCHAR(500) NOT NULL,
    enabled  BOOLEAN      NOT NULL
);

DROP TABLE IF EXISTS roles;
CREATE TABLE IF NOT EXISTS roles
(
    username VARCHAR(50) NOT NULL,
    role     VARCHAR(50) NOT NULL
);
CREATE UNIQUE INDEX idx_user_role ON roles (username ASC, role ASC);

DROP TABLE IF EXISTS permissions;
CREATE TABLE IF NOT EXISTS permissions
(
    role     VARCHAR(50)  NOT NULL,
    resource VARCHAR(128) NOT NULL,
    action   VARCHAR(8)   NOT NULL
);
CREATE UNIQUE INDEX uk_role_permission ON permissions (role, resource, action);
