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

import storage from '@ohos.file.storageStatistics';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DEFAULT_DATA_SIZE } from '../constant/StorageConstant';
import { SearchStatisticsDataUtils } from './SearchStatisticsDataUtils';
import { StorageUtil } from './StorageUtil';

@Concurrent
export async function getUserStorageStatsAsync(): Promise<storage.StorageStats> {
  let defaultRes: storage.StorageStats = {
    total: DEFAULT_DATA_SIZE,
    audio: DEFAULT_DATA_SIZE,
    video: DEFAULT_DATA_SIZE,
    image: DEFAULT_DATA_SIZE,
    file: DEFAULT_DATA_SIZE,
    app: DEFAULT_DATA_SIZE
  };
  try {
    let start = new Date().getTime();
    let res = await storage.getUserStorageStats();
    let end = new Date().getTime();
    LogUtil.info(`StorageStatisticsUtil getUserStorageStatsAsync cost time ${end - start}`);
    return res;
  } catch (err) {
    LogUtil.error(`StorageStatisticsUtil getUserStorageStatsAsync error, code: ${err?.code}, msg: ${err?.message}`);
  }
  return defaultRes;
}

@Concurrent
export async function getFreeSizeAsync(): Promise<number> {
  try {
    let start = new Date().getTime();
    let res = await storage.getFreeSize();
    let end = new Date().getTime();
    LogUtil.info(`StorageStatisticsUtil getFreeSizeAsync cost time ${end - start}`);
    return res;
  } catch (err) {
    LogUtil.error(`StorageStatisticsUtil getFreeSizeAsync error, code: ${err?.code}, msg: ${err?.message}`);
  }
  return DEFAULT_DATA_SIZE;
}

@Concurrent
export async function getSystemSizeAsync(): Promise<number> {
  try {
    let start = new Date().getTime();
    let res = await storage.getSystemSize();
    let end = new Date().getTime();
    LogUtil.info(`StorageStatisticsUtil getSystemSizeAsync cost time ${end - start}`);
    return res;
  } catch (err) {
    LogUtil.error(`StorageStatisticsUtil getSystemSizeAsync error, code: ${err?.code}, msg: ${err?.message}`);
  }
  return DEFAULT_DATA_SIZE;
}

@Concurrent
export async function getMigrationDataSizeAsync(): Promise<number> {
  try {
    let start = new Date().getTime();
    let res = await StorageUtil.getMigrationDataSize();
    let end = new Date().getTime();
    LogUtil.info(`StorageStatisticsUtil getMigrationDataSizeAsync cost time ${end - start}`);
    return res;
  } catch (err) {
    LogUtil.error(`StorageStatisticsUtil getMigrationDataSizeAsync error, code: ${err?.code}, msg: ${err?.message}`);
  }
  return DEFAULT_DATA_SIZE;
}

@Concurrent
export async function getAudioStatisticsDataAsync(): Promise<number> {
  return await SearchStatisticsDataUtils.getAudioStatisticsData();
}
