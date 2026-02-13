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

import taskpool from '@ohos.taskpool';
import bundleManager from '@ohos.bundle.bundleManager';
import bundleResourceManager from '@ohos.bundle.bundleResourceManager';
import launcherBundleManager from '@ohos.bundle.launcherBundleManager';
import { LayeredDrawableDescriptor } from '@ohos.arkui.drawableDescriptor';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppInfoModel } from '@ohos/settings.common/src/main/ets/data/AppInfoDataType';
import { CommonFailedEventUtils } from '@ohos/settings.common/src/main/ets/utils/CommonFailedEventUtils';
import { HiSysApplicationException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { AppEntry } from './AppModel';
import { ThemeManager } from './util/ThemeManager';
import { HdsDrawableTools } from './AppIconProcessing';
import { AppEntryUtil } from './util/AppEntryUtil';
import { AppListLoader } from './AppListLoader';

const TAG: string = 'AppListLoaderTaskPool : ';
const TASK_NUMBER: number = 10;
const CONCURRENCY_THRESHOLD: number = 40;

@Concurrent
async function mergeAppList(launcherAbilityInfoList: launcherBundleManager.LauncherAbilityInfo[],
                            allBundleResourceList: bundleManager.BundleInfo[],
                            infoList: bundleResourceManager.BundleResourceInfo[],
                            isHdsHandle: boolean): Promise<AppEntry[]> {
  let appList: AppEntry[] = [];
  let defaultIcon: ResourceStr | PixelMap = AppEntry.getDefaultIcon();
  let launcherObjMap: Map<string, launcherBundleManager.LauncherAbilityInfo> = new Map();
  launcherAbilityInfoList.forEach(launcherObj => {
    let applicationInfo = launcherObj.applicationInfo;
    launcherObjMap.set(`${applicationInfo.name},${applicationInfo.appIndex}`, launcherObj);
  })
  let bundleObjMap: Map<string, bundleManager.BundleInfo> = new Map();
  allBundleResourceList.forEach(bundleObj => {
    let appInfo = bundleObj.appInfo;
    bundleObjMap.set(`${appInfo.name},${appInfo.appIndex}`, bundleObj);
  })
  infoList.forEach(entryObj => {
    const launcherObj: launcherBundleManager.LauncherAbilityInfo | undefined = launcherObjMap.get(
      `${entryObj.bundleName},${entryObj.appIndex}`);
    const bundleObj: bundleManager.BundleInfo | undefined = bundleObjMap.get(
      `${entryObj.bundleName},${entryObj.appIndex}`);

    if (launcherObj) {
      const appEntry = new AppEntry({
        name: entryObj?.bundleName,
        versionName: bundleObj?.versionName,
        updateTime: bundleObj?.updateTime,
        appInfo: {
          name: entryObj?.bundleName,
          bundleType: launcherObj?.applicationInfo.bundleType,
          codePath: launcherObj?.applicationInfo.codePath,
          systemApp: launcherObj?.applicationInfo.systemApp,
          labelId: launcherObj?.applicationInfo.labelId,
          iconId: launcherObj?.applicationInfo.iconId,
          removable: bundleObj?.appInfo.removable,
          appIndex: bundleObj?.appInfo?.appIndex,
          installSource: bundleObj?.appInfo?.installSource,
          uid: bundleObj?.appInfo?.uid,
        }
      } as bundleManager.BundleInfo);
      appEntry.moduleName = launcherObj?.applicationInfo.labelResource.moduleName;
      appEntry.label = entryObj?.label;
      appEntry.appIndex = entryObj?.appIndex;
      appEntry.icon = isHdsHandle ? defaultIcon : entryObj?.icon;
      appList.push(appEntry);
    }

    if (bundleObj?.appInfo.bundleType === 1) {
      const appEntry = new AppEntry({
        name: entryObj?.bundleName,
        versionName: bundleObj.versionName,
        updateTime: bundleObj?.updateTime,
        appInfo: {
          name: entryObj?.bundleName,
          bundleType: bundleObj?.appInfo.bundleType,
          codePath: bundleObj?.appInfo.codePath,
          systemApp: bundleObj?.appInfo.systemApp,
          labelId: bundleObj?.appInfo.labelId,
          iconId: bundleObj?.appInfo.iconId,
          removable: bundleObj?.appInfo.removable,
          appIndex: bundleObj?.appInfo?.appIndex,
          uid: bundleObj?.appInfo?.uid,
        }
      } as bundleManager.BundleInfo);
      appEntry.label = entryObj?.label;
      appEntry.appIndex = entryObj?.appIndex;
      appEntry.icon = isHdsHandle ? defaultIcon : entryObj?.icon;
      appList.push(appEntry);
    }
  });
  return appList;
}

@Concurrent
function iconsOneByOneProc(appList: AppEntry[], hasBorder: boolean): AppEntry[] {
  LogUtil.info(`AppListLoaderTaskPool : iconsOneByOneProc proc appList len: ${appList.length}`);
  let bundleFlags: number = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR;
  let defaultIcon: ResourceStr | PixelMap = AppEntry.getDefaultIcon();
  let mask :PixelMap = HdsDrawableTools.getInstance().getMask();
  let localMask :PixelMap = HdsDrawableTools.getInstance().clonePixelMap(mask);
  mask.release();
  for (let index: number = 0; index < appList.length; index++) {
    let appEntry: AppEntry = appList[index];
    try {
      LogUtil.info(`AppListLoaderTaskPool : iconsOneByOneProc getBundleResourceInfo start ${appEntry.name}, index ${index}`);
      let bundleResourceInfo =
        bundleResourceManager.getBundleResourceInfo(appEntry.name, bundleFlags, appEntry.appIndex);
      // 元服务
      if (appEntry.appInfo === undefined || appEntry.appInfo.bundleType === 1) {
        LogUtil.info(`AppListLoaderTaskPool : iconsOneByOneProc service app ${appEntry.name}, index ${index}`);
        appEntry.icon = bundleResourceInfo.drawableDescriptor.getPixelMap();
        continue;
      }
      // 单双层图标识别和处理
      appEntry.icon = HdsDrawableTools.getInstance().getCustomHdsIcon(appEntry,
        bundleResourceInfo.drawableDescriptor, HdsDrawableTools.defaultSize, localMask, hasBorder) ?? defaultIcon;
    } catch (error) {
      LogUtil.error(`AppListLoaderTaskPool : iconsOneByOneProc getBundleResourceInfo code: ${error?.code} errmsg: ${error?.message}`);
    }
  }
  localMask.release();
  LogUtil.info(`AppListLoaderTaskPool : iconsOneByOneProc proc finished appList len: ${appList.length}`);
  return appList;
}

@Concurrent
async function iconsOneOffProc(appList: AppEntry[], hasBorder: boolean): Promise<AppEntry[]> {
  let bundleFlags: number = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR;
  let handleIcons: ESObject = {pixelMapIcons: [], layeredIcons: []};
  for (let index: number = 0; index < appList.length; index++) {
    let appEntry: AppEntry = appList[index];
    let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined;
    try {
      LogUtil.info(`AppListLoaderTaskPool : iconsOneOffProc getBundleResourceInfo app ${appEntry.name}`);
      bundleResourceInfo = bundleResourceManager.getBundleResourceInfo(appEntry.name, bundleFlags, appEntry.appIndex);
    } catch (error) {
      LogUtil.error(`AppListLoaderTaskPool : iconsOneOffProc getBundleResourceInfo errmsg: ${error?.message}`);
      continue;
    }
    // 元服务
    if (appEntry.appInfo === undefined || appEntry.appInfo.bundleType === 1) {
      appEntry.icon = bundleResourceInfo.drawableDescriptor.getPixelMap();
      continue;
    }
    // 双层图标
    if (bundleResourceInfo.drawableDescriptor instanceof LayeredDrawableDescriptor) {
      handleIcons.layeredIcons.push({
        bundleName: HdsDrawableTools.getInstance().getFixAppBundleName(appEntry),
        layeredDrawableDescriptor: bundleResourceInfo.drawableDescriptor
      });
      continue;
    }
    // 单层图标
    handleIcons.pixelMapIcons.push({
      bundleName: HdsDrawableTools.getInstance().getFixAppBundleName(appEntry),
      pixelMap: bundleResourceInfo.drawableDescriptor.getPixelMap()
    })
  }
  // 传入的pixelMapIcons会在HdsDrawableTools中释放
  await HdsDrawableTools.getInstance().getCustomHdsIcons(appList, handleIcons,
    { hasBorder: hasBorder, size: HdsDrawableTools.defaultSize, parallelNumber: 10 });
  LogUtil.info(`AppListLoaderTaskPool : iconsOneOffProc procs appList len: ${appList.length}`);
  return appList;
}

@Concurrent
export async function getSpecAppListFromTaskPool(bundleInfos: bundleManager.BundleInfo[],
                                          hasBorder: boolean): Promise<AppEntry[]> {
  const tag: string = 'AppListLoaderManagerTaskPool: ';
  let handleIcons: ESObject = {pixelMapIcons: [], layeredIcons: []};
  let availableAppList: AppEntry[] = [];
  for (let info of bundleInfos) {
    let entry: AppEntry = new AppEntry(info);
    let bundleFlags: number = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL |
      bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_DRAWABLE_DESCRIPTOR;
    let bundleResourceInfo: bundleResourceManager.BundleResourceInfo | undefined =
      entry.getBundleResourceInfo(entry.name, bundleFlags, entry.appIndex);
    if (bundleResourceInfo) {
      if (bundleResourceInfo.drawableDescriptor == null || bundleResourceInfo.drawableDescriptor == undefined) {
        LogUtil.showWarn(tag, `bundleResourceInfo.drawableDescriptor is null, name: ${entry.name}`);
        CommonFailedEventUtils.reportFailureEvent(HiSysApplicationException.LOAD_BMS_ICON_NULL,
          `${entry.name} bundleResource drawableDescriptor is null`);
      }
      entry.label = bundleResourceInfo.label;
      entry.appIndex = bundleResourceInfo.appIndex;
      availableAppList.push(entry);
      bundleResourceInfo.drawableDescriptor instanceof LayeredDrawableDescriptor ?
        handleIcons.layeredIcons.push({
          bundleName: HdsDrawableTools.getInstance().getFixAppBundleName(entry),
          layeredDrawableDescriptor: bundleResourceInfo.drawableDescriptor
        }) :
        handleIcons.pixelMapIcons.push({
          bundleName: HdsDrawableTools.getInstance().getFixAppBundleName(entry),
          pixelMap: bundleResourceInfo.drawableDescriptor?.getPixelMap()
        });
    } else {
      LogUtil.showError(tag, `bundleResourceInfo is null, name: ${entry.name}`);
    }
  }
  await HdsDrawableTools.getInstance().getCustomHdsIcons(availableAppList, handleIcons,
    { hasBorder: hasBorder, size: HdsDrawableTools.defaultSize, parallelNumber: 10 });
  return availableAppList;
}

@Concurrent
export async function processAppOneByOne(appInfoModelList: AppInfoModel[]): Promise<AppEntry[]> {
  let resultList:AppEntry[] = [];
  let base64Helper: util.Base64Helper = new util.Base64Helper();
  for (let index: number = 0; index < appInfoModelList.length; index++) {
    let appInfoModel: AppInfoModel = appInfoModelList[index];
    if (appInfoModel && appInfoModel.icon) {
      try {
        let appItem: AppEntry = AppEntryUtil.buildFromAppInfoEntry(appInfoModel)
        appItem.icon = await AppEntry.createPixelMap(base64Helper, appInfoModel.icon, appInfoModel.bundleName);
        resultList.push(appItem);
      } catch (err) {
        LogUtil.error(`AppListLoaderTaskPool processOneAppItem failed, code ${(err as BusinessError)?.code}
      , message ${(err as BusinessError)?.message}`)
      }
    }
  }
  return resultList;
}

@Concurrent
export async function createAndCacheApp(bundleName: string, appIndex?: number): Promise<AppEntry | null> {
  if (!bundleName) {
    LogUtil.error(`AppListLoaderPool createAppEntryByName bundleName invalid`);
  }
  return await AppListLoader.getInstance().createAppEntryByName(bundleName, appIndex);
}

export class AppListLoaderManager {
  private static getAppListIsDone: boolean = true;
  private static getSpecAppListIsDone: boolean = true;

  static async getAppList(launcherAbilityInfoList: Array<launcherBundleManager.LauncherAbilityInfo>,
                          isHdsHandle: boolean): Promise<AppEntry[]> {
    let appList: AppEntry[] = [];
    let flag: bundleResourceManager.ResourceFlag = bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL;
    if (!isHdsHandle) {
      flag = flag | bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_ICON;
    }
    if (!AppListLoaderManager.getAppListIsDone) {
      LogUtil.warn(`${TAG} getAppList is working`);
      return [];
    }
    AppListLoaderManager.getAppListIsDone = false;
    await Promise.all([
      bundleManager.getAllBundleInfo(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION),
      bundleResourceManager.getAllBundleResourceInfo(flag)
    ]).then(async res => {
      let allBundleResourceList: bundleManager.BundleInfo[] = res[0];
      let allResourceInfo: bundleResourceManager.BundleResourceInfo[] = res[1];
      LogUtil.info(`${TAG} allBundleResourceList: ${allBundleResourceList.length} && allResourceInfo len: ${allResourceInfo.length}`);
      let task: taskpool.Task = new taskpool.Task(mergeAppList, launcherAbilityInfoList, allBundleResourceList,
        allResourceInfo, isHdsHandle);
      try {
        AppListLoaderManager.getAppListIsDone = false;
        appList = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
      } catch (error) {
        LogUtil.error(`${TAG} catch exception when mergeAppList, errmsg: ${error?.message}`);
      }
    }).catch((error: Error) => {
      LogUtil.error(`${TAG} promise all ${error?.message}`);
    })
    AppListLoaderManager.getAppListIsDone = true;
    return appList;
  }

  static async hdsIconsHandle(appList: AppEntry[], isNeedSplit: boolean): Promise<AppEntry[]> {
    //遍历应用，根据应用数量决策是否并发遍历处理图标
    let result: AppEntry[] = [];
    let hasBorder: boolean = !ThemeManager.getInstance().checkIsOnlineIcon();
    if (isNeedSplit && appList.length > CONCURRENCY_THRESHOLD) {
      const appCountPerTask = appList.length / TASK_NUMBER;
      let tasks: taskpool.TaskGroup = new taskpool.TaskGroup();
      for (let index = 0; index < TASK_NUMBER; index++) {
        tasks.addTask(new taskpool.Task(iconsOneByOneProc, index < TASK_NUMBER - 1
          ? appList.slice(index * appCountPerTask, (index + 1) * appCountPerTask)
          : appList.slice(index * appCountPerTask), hasBorder));
      }
      await taskpool.execute(tasks).then((res: Object[]) => {
        for (let index = 0; index < res.length; index++) {
          result.push(...(res[index] as AppEntry[]));
        }
      }).catch((error: Error) => {
        LogUtil.error(`${TAG} taskpool errName:${error?.name}, errMsg:${error?.message}`);
      })
    } else {
      let task: taskpool.Task = new taskpool.Task(iconsOneOffProc, appList, hasBorder);
      try {
        result = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
      } catch (error) {
        LogUtil.error(`${TAG} catch exception when iconsOneOffProc, errcode: ${error?.code}, errmsg: ${error?.message}`);
      }
    }
    return result;
  }

  static async getSpecAppList(bundleInfos: bundleManager.BundleInfo[]): Promise<AppEntry[]> {
    if (bundleInfos.length === 0) {
      return [];
    }
    let appList: AppEntry[] = [];
    let hasBorder: boolean = !ThemeManager.getInstance().checkIsOnlineIcon();
    let task: taskpool.Task = new taskpool.Task(getSpecAppListFromTaskPool, bundleInfos, hasBorder);
    if (AppListLoaderManager.getSpecAppListIsDone) {
      try {
        AppListLoaderManager.getSpecAppListIsDone = false;
        appList = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
      } catch (error) {
        AppListLoaderManager.getSpecAppListIsDone = task.isDone();
        LogUtil.error(`${TAG} catch exception when getSpecAppListFromTaskPool, errcode: ${error?.code}, errmsg: ${error?.message}`);
      }
      AppListLoaderManager.getSpecAppListIsDone = task.isDone();
    }
    AppListLoaderManager.getSpecAppListIsDone = task.isDone();
    return appList;
  }
}