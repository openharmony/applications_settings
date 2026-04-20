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

export const APP_INFO_TABLE = 'APP_INFO_TABLE';

export const SQL_CREATE_APP_INFO_TABLE = `
  CREATE TABLE IF NOT EXISTS ${APP_INFO_TABLE} (
    iD INTEGER PRIMARY KEY AUTOINCREMENT,
    bundleName TEXT NOT NULL,
    appInfoName TEXT,
    codePath TEXT,
    uid INTEGER,
    bundleType INTEGER,
    systemApp INTEGER,
    enabled INTEGER,
    dataUnclearable INTEGER,
    multiAppModeMaxCount INTEGER,
    removable INTEGER,
    userDataClearable INTEGER,
    label TEXT,
    labelId INTEGER,
    icon TEXT,
    iconId INTEGER,
    appSize TEXT,
    cacheSize TEXT,
    dataSize TEXT,
    totalSize TEXT,
    versionName TEXT,
    updateTime INTEGER,
    locale TEXT,
    currentActivatedId INTEGER DEFAULT 100,
    moduleName TEXT,
    appIndex INTEGER,
    installSource TEXT
    );`;

export const SQL_DELETE_ITEM_INFO_TABLE = `
  DELETE FROM ${APP_INFO_TABLE};
`;

export const SQL_INSERT_INSTALL_SOURCE = `
  ALTER TABLE APP_INFO_TABLE ADD COLUMN installSource TEXT
`;

export interface AppInfoModel {
  bundleName: string,
  appInfoName?: string,
  codePath?: string,
  uid?: number,
  bundleType?: number,
  systemApp?: boolean,
  enabled?: boolean,
  dataUnclearable?: boolean,
  multiAppModeMaxCount?: number,
  removable?: boolean,
  userDataClearable?: boolean,
  label?: string,
  labelId?: number,
  icon?: string,
  iconId?: number,
  appSize?: string,
  cacheSize?: string,
  dataSize?: string,
  totalSize?: string,
  versionName: string,
  updateTime: number,
  locale?: string,
  currentActivatedId?: number,
  moduleName?: string,
  appIndex?: number,
  installSource?: string
}