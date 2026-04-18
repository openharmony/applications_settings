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

import { inputMethod } from '@kit.IMEKit';
import bundle from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysCloneAppEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { AppCloneData } from '../model/CloneAppsData';

const TAG: string = 'CloneAppUtil : ';

export class CloneAppUtil {
  /**
   * get the list of all clone apps of the specific bundle name.
   *
   * @param bundleName bundle name
   * @returns List of all clone apps info of the specific bundle name.
   */
  static async getCloneAppDetail(bundleName: string): Promise<Array<bundle.BundleInfo>> {
    let allCloneApps: bundle.BundleInfo[] = [];
    try {
      allCloneApps = await bundle.getAllBundleInfo(bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      allCloneApps = allCloneApps.filter((bundleInfo) => {
        return bundleInfo.name === bundleName;
      });
    } catch (e) {
      LogUtil.error(`${TAG} getCloneAppDetail failed`);
    }
    return allCloneApps;
  }

  static reportCloneAppStatisticEvent() {
    CloneAppUtil.getAllCloneApps().then((allCloneApps: Map<string, AppCloneData>) => {
      for (let cloneApp of allCloneApps.values()) {
        let params: Record<string, Object> = {};
        params.CLONE_APP_NAME = cloneApp.bundleName;
        params.CLONE_APP_NUM = cloneApp.cloneAppNum;
        params.CLONE_APP_MAX_COUNT = cloneApp.maxCloneAppNum;
        HiSysEventUtil.reportStatisticEventByUE(HiSysCloneAppEventGroup.CLONE_APP_STATISTIC, params);
      }
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} reportCloneAppStatisticEvent failed, ${err.name}`);
    });
  }
  /**
   * get boolean value of MDM disable clone
   *
   * @returns Boolean value of MDM disable clone.
   */
  static getMDMDisableClone(): boolean {
    let isMDMDisableClone = SystemParamUtils.getSystemParam('persist.edm.app_clone_disable', 'false');
    if (isMDMDisableClone !== 'true' && isMDMDisableClone !== 'false'){
      LogUtil.error(`${TAG} app_clone_disable is ${isMDMDisableClone}, error`);
    }
    return isMDMDisableClone === 'true';
  }

  /**
   * get the map of all apps that support clone app.
   *
   * @returns a map of all apps that support clone app.
   */
  static async getAllCloneApps(): Promise<Map<string, AppCloneData>> {
    let allSupportCloneApps = new Map<string, AppCloneData>();
    let allBundleResourceList: bundle.BundleInfo[] = [];
    try {
      allBundleResourceList = await bundle.getAllBundleInfo(bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      allSupportCloneApps = await CloneAppUtil.filterCloneApps(allBundleResourceList);
    } catch (e) {
      LogUtil.error(`${TAG} getAllCloneApps failed`);
    }
    return allSupportCloneApps;
  }

  private static getAllInputMethods() : Set<string> {
    let inputMethods: Set<string> = new Set();
    try {
      let arr = inputMethod.getSetting().getAllInputMethodsSync() || [];
      arr.forEach((input) => {
        inputMethods.add(input.name);
      });
    } catch (err) {
      LogUtil.error(`${TAG} getAllInputMethodsSync failed code: ${err?.code} message: ${err?.message}`);
    }
    return inputMethods;
  }

  private static async filterCloneApps(allBundleResourceList: Array<bundle.BundleInfo>)
    : Promise<Map<string, AppCloneData>> {
    let allSupportCloneApps = new Map<string, AppCloneData>();
    let inputMethods = CloneAppUtil.getAllInputMethods();
    for (let bundleInfo of allBundleResourceList) {
      if (bundleInfo?.appInfo?.multiAppMode?.multiAppModeType === bundle.MultiAppModeType.APP_CLONE) {
        if (inputMethods.has(bundleInfo.name)) {
          LogUtil.info(`${TAG} filter ${bundleInfo.name} cause inputMethod.`);
          continue;
        }
        if (allSupportCloneApps.get(bundleInfo.name) !== undefined) {
          allSupportCloneApps.get(bundleInfo.name)!.cloneAppNum++;
          continue;
        }
        let cloneAppData = await CloneAppUtil.getHandleBundleInfo(bundleInfo);
        allSupportCloneApps.set(bundleInfo.name, cloneAppData);
        LogUtil.info(`${TAG} bundleName = ${bundleInfo.name}, label = ${cloneAppData.label}`);
      }
    }
    return allSupportCloneApps;
  }

  static async getHandleBundleInfo(bundleInfo: bundle.BundleInfo) : Promise<AppCloneData> {
    let cloneAppData = new AppCloneData();
    cloneAppData.init(bundleInfo);
    await cloneAppData.loadLabelAndIcon();
    return cloneAppData;
  }

  static enableCreateButton(enabled: boolean): void {
    let buttonId: string = 'Setting.CloneAppDetail.create_clone_app_group.create_clone_app_button';
    notifyCompStateChange(buttonId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED,
        { state: enabled } as SettingCompState]]
      ));
  }
}