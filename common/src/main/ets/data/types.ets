/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Key for first enter app
export const IS_FIRST_ENTER = 'IS_FIRST_ENTER';

// Key for ignore fingerprint dialog
export const IS_IGNORE_FINGERPRINT_DIALOG = 'IS_IGNORE_FINGERPRINT_DIALOG';

export const INNER_SCREEN_FINGER: string = '1';

export const EXTERNAL_SCREEN_FINGER: string = '2';

// 指纹信息类型定义
export interface FingerprintInfo {
  id?: string,
  userid: string, // 用户ID
  name: string, // 指纹名称
  credential: string, // 指纹凭据
  fingerprintType?: string //指纹类型
}

// 指纹数据库表名
export const FINGERPRINT_DATA_TABLE = 'FINGERPRINT_TABLE';

// 指纹数据库的建表 SQL
export const SQL_CREATE_FINGERPRINT_TABLE = `
  CREATE TABLE IF NOT EXISTS ${FINGERPRINT_DATA_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    USER_ID TEXT,
    NAME TEXT NOT NULL,
    CREDENTIAL TEXT NOT NULL
  );
`;

// 指纹数据库的建表 SQL
export const SQL_CREATE_FINGERPRINT_TABLE_WITH_FINGER_TYPE = `
  CREATE TABLE IF NOT EXISTS ${FINGERPRINT_DATA_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    USER_ID TEXT,
    NAME TEXT NOT NULL,
    CREDENTIAL TEXT NOT NULL,
    FINGERPRINT_TYPE TEXT DEFAULT '1'
  );
`;

// 增加指纹类型字段
export const ADD_COLUMN_FINGERPRINT_TYPE: string =
  `ALTER TABLE ${FINGERPRINT_DATA_TABLE} ADD COLUMN FINGERPRINT_TYPE TEXT DEFAULT '1'`;

// 指纹信息类型定义
export interface SecurityInfo {
  id?: string,
  token: string,
  challenge: string,
  password: string,
}

export const SECURITY_DATA_TABLE = 'SECURITY_TABLE';

export const SQL_CREATE_SECURITY_TABLE = `
  CREATE TABLE IF NOT EXISTS ${SECURITY_DATA_TABLE} (
    ID INTEGER PRIMARY KEY,
    TOKEN TEXT,
    CHALLENGE TEXT,
    PASSWORD TEXT
  );
`;

export const ITEMINFO_TABLE = 'ITEMINFO_TABLE';
export const OPERATION_TABLE = 'OPERATION_TABLE';

// ENABLED 字段在数据库中代表 true 和 false 的值
export const ENABLED_TRUE = 1;

export const ENABLED_FALSE = 0;

export const SQL_CREATE_ITEMINFO_TABLE = `
  CREATE TABLE IF NOT EXISTS ${ITEMINFO_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    locale TEXT NOT NULL ,
    itemName TEXT NOT NULL,
    itemTitle TEXT NOT NULL ,
    itemDescription TEXT,
    entryKey TEXT NOT NULL,
    pageTitle TEXT NOT NULL,
    params TEXT,
    enable INTEGER NOT NULL,
    icon BLOB,
    alias TEXT,
    path TEXT,
    childItems TEXT,
    bundleName TEXT,
    checkType TEXT,
    checkKey TEXT,
    checkValue TEXT
  );
`;

export const SQL_CREATE_OPERATION_TABLE = `
  CREATE TABLE IF NOT EXISTS ${OPERATION_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    locale TEXT NOT NULL ,
    itemName TEXT NOT NULL,
    itemTitle TEXT NOT NULL ,
    itemDescription TEXT,
    entryKey TEXT NOT NULL,
    pageTitle TEXT NOT NULL,
    params TEXT,
    enable INTEGER NOT NULL,
    icon BLOB,
    alias TEXT,
    path TEXT,
    childItems TEXT,
    bundleName TEXT,
    checkType TEXT,
    checkKey TEXT,
    checkValue TEXT,
    content INTEGER NOT NULL,
    status TEXT,
    timestamp INTEGER NOT NULL,
    businessId TEXT,
    optBundleName TEXT
  );
`;

export const SQL_UPDATE_ITEM_INFO = `
 UPDATE ${ITEMINFO_TABLE} SET itemDescription='wlan' WHERE itemName='wlan';
`;

export const SQL_DELETE_ITEM_INFO_TABLE = `
  DELETE FROM ${ITEMINFO_TABLE};
`;

export interface ItemInfo {
  locale: string,
  itemName: string,
  itemTitle: string,
  itemDescription: string,
  entryKey: string,
  pageTitle: string,
  params: string,
  enable: boolean,
  icon: string,
  alias: string,
  childItems: string,
  path: string,
  bundleName: string,
  checkType: string,
  checkKey: string,
  checkValue: string
};

export const PAGEINFO_TABLE = 'PAGEINFO_TABLE';

export const SQL_DELETE_PAGEINFO_TABLE = `
  DELETE FROM ${PAGEINFO_TABLE};
`;

// isVisible 字段在数据库中代表 true 和 false 的值
export const ISVISIBLE_TRUE = 1;

export const ISVISIBLE_FALSE = 0;

export const SQL_CREATE_PAGEINFO_TABLE = `
  CREATE TABLE IF NOT EXISTS ${PAGEINFO_TABLE} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    entryKey TEXT NOT NULL ,
    parentKey TEXT,
    isVisible INTEGER NOT NULL ,
    permission TEXT
  );
`;

export interface PageInfo {
  entryKey: string,
  parentKey: string,
  isVisible: boolean,
  permission: string,
};

export enum DisplayArrayIndex {
  INDEX_0 = 0,
  INDEX_1 = 1,
  INDEX_2 = 2,
  INDEX_3 = 3,
  INDEX_4 = 4,
  INDEX_5 = 5,
  INDEX_6 = 6,
}

export enum PageStartReason {
  DEFAULT = 'default',
  FROM_SEARCH = 'from_search',
  FROM_EXTERNAL = 'from_external',
  FROM_INTENT = 'from_intent',
  FROM_SUGGESTION = 'from_suggestion',
}

/**
 * 定义历史操作表的内容
 */
export interface SearchItemOperation extends ItemInfo {
  content: string,
  status: string,
  timestamp: number,
  // 业务方id
  businessId: string,
  optBundleName: string,
}

/**
 * 操作类型
 */
export enum OperationStatus {
  UPDATE = 'update',
  DELETE = 'delete',
  ADD = 'add',
  QUERY = 'query',
}

/**
 * sim card label information.
 */
export interface SimLabel {
  simType: number;
  index: number;
}