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

import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { taskpool, util } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { intl } from '@kit.LocalizationKit';
import { AppInfoModel } from '@ohos/settings.common/src/main/ets/data/AppInfoDataType';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AppEntry, AppType, BasicAppEntry } from '../AppModel';
import { processAppOneByOne } from '../AppListLoaderManagerTaskPool';

const TAG: string = 'AppEntryUtil';
const DEFAULT_ACTIVATED_ID: number = 100;
const CONCURRENCY_THRESHOLD: number = 30;
const TASK_NUMBER: number = 10;

/**
 * App model处理工具类
 */
export class AppEntryUtil {
  static async processAppItemsAsync(appList: AppInfoModel[], appType: string = ''): Promise<AppEntry[]> {
    let resultInfo: AppEntry[] = [];
    if (!appList) {
      LogUtil.info(`${TAG} processAppItemsAsync invalid appList`);
      return resultInfo;
    }
    let statTime: number = systemDateTime.getTime(false);
    LogUtil.info(`${TAG} processAppItemsAsync start`);
    if (appList.length > CONCURRENCY_THRESHOLD) {
      LogUtil.info(`${TAG} processAppItemsAsync use taskpool`);
      const appCountPerTask = appList.length / TASK_NUMBER;
      let tasks: taskpool.TaskGroup = new taskpool.TaskGroup('process_db_cache');
      for (let index = 0; index < TASK_NUMBER; index++) {
        tasks.addTask(new taskpool.Task(processAppOneByOne, index < TASK_NUMBER - 1
          ? appList.slice(index * appCountPerTask, (index + 1) * appCountPerTask)
          : appList.slice(index * appCountPerTask)));
      }
      await taskpool.execute(tasks).then((res: Object[]) => {
        for (let index = 0; index < res.length; index++) {
          resultInfo.push(...(res[index] as AppEntry[]));
        }
      }).catch((error: Error) => {
        LogUtil.error(`${TAG} processAppItemsAsync taskpool errName:${error?.name}, errMsg:${error?.message}`);
      })
    } else {
      LogUtil.info(`${TAG} processAppItemsAsync use one task`);
      let task: taskpool.Task = new taskpool.Task(processAppOneByOne, appList);
      try {
        resultInfo = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
      } catch (error) {
        LogUtil.error(`${TAG} catch exception when iconsOneOffProc, errcode: ${error?.code}, errmsg: ${error?.message}`);
      }
    }
    let endTime: number = systemDateTime.getTime(false);
    LogUtil.info(`${TAG} processAppItemsAsync processAppItemsAsync for app type:${appType},
     cost : ${endTime - statTime}, app count is ${appList.length}`);
    return resultInfo;
  }

  public static buildFromAppInfoEntry(appInfoEntry: AppInfoModel): AppEntry {
    let appEntry: AppEntry = new AppEntry();
    let basicInfo: BasicAppEntry = new BasicAppEntry();
    basicInfo.name = appInfoEntry.appInfoName ?? '';
    basicInfo.codePath = appInfoEntry.codePath ?? '';
    basicInfo.uid = appInfoEntry.uid ?? 0;
    basicInfo.bundleType = appInfoEntry.bundleType ?? 0;
    basicInfo.systemApp = appInfoEntry.systemApp ?? false;
    basicInfo.enabled = appInfoEntry.enabled ?? false;
    basicInfo.dataUnclearable = appInfoEntry.dataUnclearable ?? false;
    basicInfo.multiAppModeMaxCount = appInfoEntry.multiAppModeMaxCount ?? 0;
    appEntry.appInfo = basicInfo;
    appEntry.name = appInfoEntry.bundleName;
    appEntry.removable = appInfoEntry.removable ?? false;
    appEntry.userDataClearable = appInfoEntry.userDataClearable ?? false;
    appEntry.label = appInfoEntry.label;
    appEntry.labelId = appInfoEntry.labelId ?? 0;
    appEntry.iconId = appInfoEntry.iconId ?? 0;
    appEntry.appSize = appInfoEntry.appSize ?? '';
    appEntry.cacheSize = appInfoEntry.cacheSize ?? '';
    appEntry.dataSize = appInfoEntry.dataSize ?? '';
    appEntry.totalSize = appInfoEntry.totalSize ?? '';
    appEntry.versionName = appInfoEntry.versionName;
    appEntry.updateTime = appInfoEntry.updateTime;
    appEntry.locale = appInfoEntry.locale ?? '';
    appEntry.currentActivatedId = appInfoEntry.currentActivatedId ?? DEFAULT_ACTIVATED_ID;
    appEntry.moduleName = appInfoEntry.moduleName;
    appEntry.appIndex = appInfoEntry.appIndex ?? 0;
    appEntry.installSource = appInfoEntry.installSource ?? '';
    return appEntry;
  }

  static async transferSingleEntryToInfo(entry: AppEntry): Promise<AppInfoModel> {
    let resStr: PixelMap = entry.icon as PixelMap;
    let imageStr: string = await AppEntryUtil.pixelMap2base64(resStr);
    let info: AppInfoModel = {
      bundleName: entry.name,
      appInfoName: entry.appInfo?.name,
      codePath: entry.appInfo?.codePath,
      uid: entry.appInfo?.uid,
      bundleType: entry.appInfo?.bundleType,
      systemApp: entry.appInfo?.systemApp,
      enabled: entry.appInfo?.enabled,
      dataUnclearable: entry.appInfo?.dataUnclearable,
      multiAppModeMaxCount: entry.appInfo?.multiAppModeMaxCount,
      removable: entry.removable,
      userDataClearable: entry.userDataClearable,
      label: entry.label,
      labelId: entry.labelId,
      icon: imageStr,
      iconId: entry.iconId,
      appSize: entry.appSize,
      cacheSize: entry.cacheSize,
      dataSize: entry.dataSize,
      totalSize: entry.totalSize,
      versionName: entry.versionName,
      updateTime: entry.updateTime,
      locale: entry.locale,
      currentActivatedId: entry.currentActivatedId,
      moduleName: entry.moduleName,
      appIndex: entry.appIndex,
      installSource: entry.installSource
    };
    return info;
  }

  static async transferEntryListToInfo(appList: AppEntry[]): Promise<AppInfoModel[]> {
    let infoList: AppInfoModel[] = [];
    if (!appList) {
      LogUtil.info(`${TAG} transferEntryListToInfo invalid appList`);
      return infoList;
    }
    for (let entry of appList) {
      let info: AppInfoModel = await AppEntryUtil.transferSingleEntryToInfo(entry);
      infoList.push(info);
    }
    LogUtil.showInfo(TAG, `transferEntryListToInfo size is ${infoList.length}`)
    return infoList;
  }

  private static async pixelMap2base64(pixelMap: PixelMap): Promise<string> {
    const imagePackerApi: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
    let base64Str: string = '';
    await imagePackerApi.packing(pixelMap, packOpts)
      .then(async (data: ArrayBuffer) => {
        let bufferArr = new Uint8Array(data);
        let help = new util.Base64Helper();
        base64Str = await help.encodeToString(bufferArr);
      }).catch((error: BusinessError) => {
        LogUtil.showError(TAG, `packing failed. code:${error?.code}, messag: ${error?.message}}`);
      });
    return base64Str;
  }

  static getEntryAppType(appEntry: AppInfoModel): AppType {
    const appInfo = appEntry;
    if (appInfo?.bundleType === 0) {
      const isTrue = appInfo?.codePath?.includes('/');
      if (isTrue) {
        return appInfo?.systemApp ? AppType.SYSTEM_APP : AppType.UN_SYSTEM_APP;
      }
      return AppType.CONTAINER_APP;
    }
    if (appInfo?.bundleType === 1) {
      return AppType.SERVICE_APP;
    }
    return AppType.UNKNOWN_TYPE;
  }

  /**
   * 判断是否是分身应用
   *
   * @param appInfo AppEntry
   * @returns 分身应用返回true
   */
  public static isAppCloneBadge(appInfo: AppEntry): boolean {
    if (CheckEmptyUtils.isEmpty(appInfo)) {
      LogUtil.showWarn(TAG, 'appInfo is null');
      return false;
    }
    const appIndex: number = appInfo?.appIndex || 0;
    return appIndex > 0 && appIndex <= 5;
  }
}

@Concurrent
export function sortEntryByName(data: AppInfoModel[]): AppInfoModel[] {
  let compare = (firstEntry: AppInfoModel, secondEntry: AppInfoModel): number => {
    let collator = new intl.Collator();
    return collator.compare(firstEntry.label?.toString(), secondEntry.label?.toString());
  }
  data.sort((firstItem, secondItem) => {
    return compare(firstItem, secondItem);
  });
  return data;
}

