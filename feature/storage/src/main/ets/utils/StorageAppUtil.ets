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

import { bundleManager } from '@kit.AbilityKit';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StorageUtil } from './StorageUtil';

@Concurrent
export async function getLockedAppsAsync(): Promise<Map<number, string[]>> {
  return await StorageUtil.getLockedApps();
}

@Concurrent
export async function getUsedAppInMonthMapAsync(): Promise<Map<number, string[]>> {
  return await StorageUtil.getUsedAppInMonthMap();
}

@Concurrent
export async function getAllBundleInfoAsync(): Promise<bundleManager.BundleInfo[]> {
  return await StorageUtil.getAllBundleInfo();
}

@Concurrent
export async function getLauncherBundleListAsync(): Promise<AppEntry[]> {
  return await StorageUtil.getLauncherBundleList();
}

@Concurrent
export async function removeBackupBundleDataAsync(bundleName: string, userId: number,
  appIndex: number): Promise<boolean> {
  try {
    await bundleManager.removeBackupBundleData(bundleName, userId, appIndex);
    return true;
  } catch (err) {
    LogUtil.error(`removeBackupBundleData error occured code:${err?.code}, message:${err?.message}`);
  }
  return false;
}

@Concurrent
export async function recoverBackupBundleDataAsync(bundleName: string, userId: number,
  appIndex: number): Promise<boolean> {
  try {
    await bundleManager.recoverBackupBundleData(bundleName, userId, appIndex);
    return true;
  } catch (err) {
    LogUtil.error(`recoverBackupBundleData error occured code:${err?.code}, message:${err?.message}`);
  }
  return false;
}