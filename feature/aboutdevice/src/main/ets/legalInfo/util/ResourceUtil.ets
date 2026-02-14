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

import bundleManager from '@ohos.bundle.bundleManager';
import resmgr from '@ohos.resourceManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { values } from '@ohos/settings.common/src/main/ets/utils/ObjectConstructorUtils';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { StringUtil } from './StringUtil';
import { AppInfo } from '../model/AppInfo';

const TAG: string = 'ResourceUtil';
const LINK_STRING_FLAG: string = '$string:';
const LICENSE_FILE_PATH: string = 'license_file_path';
const ATOMIC_SERVICE: number = 1;

/**
 * 资源工具类
 */
export class ResourceUtil {
  /**
   * 获取所有应用的信息
   */
  public static async getAllAppList(): Promise<Array<AppInfo>> {
    let appInfoList: bundleManager.ApplicationInfo[];
    let appInfoListResult: AppInfo[] = [];
    try {
      appInfoList =
        await bundleManager.getAllApplicationInfo(bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_METADATA);
      for (const appInfo of appInfoList) {
        if (appInfo.bundleType === ATOMIC_SERVICE) {
          continue;
        }
        let appInfoNew: AppInfo = await ResourceUtil.getAppInfo(appInfo);
        if (appInfoNew.label !== '' &&
          ResourceUtil.getResourceLicenseFile().some((item => appInfoNew.licenseFilePath.includes(item)))) {
          appInfoListResult.push(appInfoNew);
        }
      }
      return appInfoListResult;
    } catch (error) {
      LogUtil.error(`${TAG} catch getAllAppList error : ${error?.message}`);
      return appInfoListResult;
    }
  }

  /**
   * 获取appInfo对象
   * @param appInfo
   * @returns
   */
  public static async getAppInfo(appInfo: bundleManager.ApplicationInfo): Promise<AppInfo> {
    let label = ResourceManagerUtil.getBundleResourceInfo(appInfo.name,
        bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL)?.label as string;
    let licenseFilePath: string = '';
    let metadataObj = appInfo.metadata;
    LogUtil.debug(`${TAG} metaDataList`);
    for (let index = 0; index < values(metadataObj).length; index++) {
      let metaDataList: bundleManager.Metadata[] = values(metadataObj)[index] as Array<bundleManager.Metadata>;
      try {
        if (!metaDataList) {
          continue;
        }
        for (let metaData of metaDataList) {
          if (metaData.name === LICENSE_FILE_PATH) {
            licenseFilePath = metaData.value;
            if (!licenseFilePath || licenseFilePath.includes('..')) {
              continue;
            }
            let appInfoNew: AppInfo = new AppInfo(appInfo.name, label, licenseFilePath);
            return appInfoNew;
          }
        }
      } catch (error) {
        LogUtil.error(`${TAG} getAppInfo error: ${error?.code} ${error?.message}}`);
      }
    }
    const appInfoNew = new AppInfo(appInfo.name, label, licenseFilePath);
    return appInfoNew;
  }

  private static isResourceIdValid(id: number): boolean {
    return !Number.isNaN(id) && id > 0;
  }

  /**
   * 获取指定应用的指定模块下的metadata数据
   * @param bundleName 应用包名
   * @param moduleName 模块名
   * @param metaDataName metadata名称
   */
  public static getMetadata(bundleName: string, moduleName: string, metaDataName: string):
  bundleManager.Metadata | null {
    try {
      let applicationInfo = bundleManager.getApplicationInfoSync(bundleName,
        bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_METADATA);
      if (applicationInfo === null || applicationInfo.metadata === null) {
        LogUtil.error(
          `${TAG} applicationInfo or metadata is null. getMetadata failed.
          bundleName: ${bundleName} ${(applicationInfo === null)}`);
        return null;
      }
      let metadataObj = applicationInfo.metadata;
      if (metadataObj[moduleName]) {
        for (let metaData of metadataObj[moduleName] as Array<bundleManager.Metadata>) {
          if (metaData.name !== metaDataName) {
            continue;
          } else {
            return metaData;
          }
        }
      }
      return null;
    } catch (err) {
      LogUtil.error(`${TAG} getMetadata error: ${err?.message}`);
      return null;
    }
  }

  /**
   * 获取指定资源管理器下的字串值
   * 例1： "value": "Param value" --返回原始值“Param value”
   * 例2： "value": "$string:param_value" --返回param_value对应的国际化字串值
   * @param resourceManager 资源管理器
   * @param stringName 字符串名称
   */
  public static getResourceString(resourceManager: resmgr.ResourceManager, stringName: string): string {
    LogUtil.info(`${TAG} getResourceString stringName: ${stringName}`);
    if (StringUtil.isEmpty(stringName)) {
      LogUtil.error(`${TAG} getResourceString failed. stringName is null`);
      return '';
    }
    if (stringName.startsWith(LINK_STRING_FLAG)) {
      // value: $string:param_value 返回param_value对应的国际化字串值
      if (resourceManager === null) {
        LogUtil.error(`${TAG} getResourceString failed. resourceManager is null.`);
        return '';
      }
      return resourceManager.getStringByNameSync(ResourceUtil.getFormatStringName(stringName));
    }
    // value: Param value 返回原始值 Param value
    return stringName;
  }

  /**
   * 标准化字串名称
   * @param name 名称
   */
  public static getFormatStringName(name: string): string {
    return name.replace(LINK_STRING_FLAG, '');
  }

  public static getResourceLicenseFile(): string[] {
    return [`/system/etc`, `/vendor/etc`, `/cust/etc`, `/sys_prod/etc`, `/version/etc`];
  }
}