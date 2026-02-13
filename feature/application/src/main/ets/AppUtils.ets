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

import Bundle from '@ohos.bundle';
import appManager from '@ohos.application.appManager';
import osAccount from '@ohos.account.osAccount';
import bundleManager from '@ohos.bundle.bundleManager';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import resourceManager from '@ohos.resourceManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AppEntry, AppType } from './AppModel';
import { AppListLoader } from './AppListLoader';

const TAG: string = 'AppUtils : ';

/**
 * 应用工具类
 *
 * @since 2022-05-26
 */
export class AppUtils {
  private constructor() {
  }

  /**
   * 存储大小格式化字符串
   *
   * @param size 存储大小值
   */
  static formatSize(size: number): string {
    let result = size;
    let suffix = 'B';
    if (result > 900) {
      suffix = 'KB';
      result = result / 1024;
    }
    if (result > 900) {
      suffix = 'MB';
      result = result / 1024;
    }
    if (result > 900) {
      suffix = 'GB';
      result = result / 1024;
    }

    return result.toFixed((result >= 100 || result == 0) ? 0 : 2) + suffix;
  }

  /**
   * 清理应用数据
   *
   * @param bundleName 应用包名
   */
  static clearUpApplicationData(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} clearUpApplicationData invalid name`);
      return;
    }
    appManager.clearUpApplicationData(bundleName);
  }

  /**
   * 清理应用缓存
   *
   * @param bundleName 应用包名
   */
  static cleanBundleCacheFiles(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} cleanBundleCacheFiles invalid name`);
      return;
    }
    Bundle.cleanBundleCacheFiles(bundleName);
  }

  /**
   * 强制停止应用
   *
   * @param bundleName 应用包名
   */
  static killProcessesByBundleName(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} killProcessesByBundleName invalid name`);
      return;
    }
    appManager.killProcessesByBundleName(bundleName);
  }

  /**
   * 应用进程是否启动
   *
   * @param bundleName 应用包名
   */
  static async isProcessesRunning(bundleName: string): Promise<boolean> {
    if (!bundleName) {
      LogUtil.error(`${TAG} isProcessesRunning invalid name`);
      return false;
    }

    let processRunningInfos = await appManager.getProcessRunningInfos();
    if (!processRunningInfos) {
      LogUtil.error(`${TAG} getProcessRunningInfos invalid processRunningInfos`);
      return false;
    }

    for (let runningInfos of processRunningInfos) {
      if (!runningInfos || !runningInfos.processName) {
        LogUtil.error(`${TAG} getProcessRunningInfos invalid runningInfos`);
        continue;
      }
      if (runningInfos.processName == bundleName) {
        return true;
      }
    }

    return false;
  }

  /**
   * 获取当前用户ID
   *
   * @returns number 用户ID
   */
  static async getActivatedAccountLocalId(): Promise<number> {
    let accountId: number = 100;
    try {
      let osAccountManager = osAccount.getAccountManager();
      const accountIds: number[] = await osAccountManager.getActivatedOsAccountLocalIds();
      if (accountIds.length > 0) {
        accountId = accountIds[0];
      }
    } catch (error) {
      LogUtil.error(`${TAG} getActivatedOsAccountLocalIds failed`);
    }
    return accountId;
  }

  /**
   * 应用id：包名和应用分身索引拼接
   *
   * @param name 应用包名
   * @param index 应用分身索引
   * @returns 应用id
   */
  static getAppKey(name?: string, index?: number): string {
    return `${name},${index ?? 0}`;
  }

  /**
   * 参数转换
   *
   * @param appKey key值
   * @returns 路由参数
   */
  static parsePushParamFromAppKey(appKey: string): PushParam {
    let pushParam: PushParam = new PushParam();
    if (CheckEmptyUtils.isEmpty(appKey)) {
      return pushParam;
    }
    let paramArray: string[] = appKey.split(',');
    if (!paramArray || paramArray.length < 1) {
      LogUtil.info(`${TAG} param ia invalid`);
      return pushParam;
    } else {
      pushParam.config = paramArray[0];
      let index = Number(paramArray[1]);
      pushParam.appIndex = (Number.isNaN(index) || index < 0) ? 0 : index;
      return pushParam;
    }
  }

  /**
   *
   * 判断是否是分身应用
   * @param appIndex 应用分身索引
   * @returns true: 是分身应用
   */
  static isCloneBundle(appIndex?: number) : boolean {
    return !CheckEmptyUtils.isEmpty(appIndex) && (appIndex as number) > 0;
  }

  /**
   * 获取分身应用的bundleResourceManager
   *
   * @param bundleName 包名
   * @param appIndex 分身索引
   * @returns 获取分身应用的bundleResourceManager
   */
  static getCloneBundleResourceInfo(bundleName: string, appIndex: number):
    bundleResourceManager.BundleResourceInfo | undefined {
    try {
      return bundleResourceManager.getBundleResourceInfo(
        bundleName, bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL, appIndex);
    } catch (error) {
      LogUtil.error(`${TAG} getCloneBundleResourceInfo error, errcode: ${error?.code}, errmsg: ${error?.message}`);
      return undefined;
    }
  }

  /**
   * 判断应用是否已被卸载或者分身应用是否已被删除
   *
   * @param bundleName 包名
   * @param appIndex 分身索引
   * @returns false: 应用已被卸载或删除
   */
  static isBundleExist(bundleName?: string, appIndex?: number): boolean {
    let bundleFlags: number = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE;
    try {
      if (AppUtils.isCloneBundle(appIndex)) {
        bundleManager.getAppCloneBundleInfo(bundleName, appIndex, bundleFlags);
      } else {
        bundleManager.getBundleInfoSync(bundleName, bundleFlags);
      }
      return true;
    } catch (err) {
      LogUtil.error(`isBundleExist err, errcode:${err?.code}, errmessage:${err?.message}`);
      return false;
    }
  }

  /**
   * 判断应用图标是否支持显示角标
   *
   * @param app 应用信息
   * @returns true: 支持显示角标； false: 不支持显示角标
   */
  static isSupportShowIconBadge(app: AppEntry): boolean {
    if (!app) {
      return false;
    }
    if (AppUtils.isCloneBundle(app.appIndex)) {
      return true;
    }
    if (AppListLoader.getInstance().getAppType(app) === AppType.CONTAINER_APP) {
      return true;
    }
    return false;
  }
}