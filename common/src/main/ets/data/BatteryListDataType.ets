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

export const BATTERYLIST_TABLE = 'SQL_BATTERY_APP_POWER_LIST';

// 如果旧表存在 删除旧表
export const SQL_DELET_OLD_BATTERYLIST_TABLE = `DROP TABLE IF EXISTS SQL_BATTERYHISTORY;`;

// 注意: 如果修改表结构，要改个新表名，把用户旧表删除了
export const SQL_CREATE_BATTERY_LIST_TABLE = `
  CREATE TABLE IF NOT EXISTS ${BATTERYLIST_TABLE} (
    iD INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER ,
    percentage DOUBLE ,
    totalPower DOUBLE ,
    bundleName TEXT ,
    foregroundTime INTEGER ,
    foregroundPower DOUBLE ,
    backgroundTime INTEGER ,
    backgroundPower DOUBLE ,
    appType INTEGER
    );`;

export interface BatteryListData {
  timestamp: number,
  percentage: number,
  bundleName: string,
  foregroundTime: number,
  totalPower: number,
  foregroundPower: number,
  backgroundTime: number,
  backgroundPower: number,
  appType: number,
}