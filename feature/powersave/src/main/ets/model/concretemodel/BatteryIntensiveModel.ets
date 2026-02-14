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

/* instrument ignore file */
// import deviceStandbyExt from '@hms.resourceschedule.deviceStandbyExt';
import bundleManager from '@ohos.bundle.bundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PowerSaveTaskManager, TaskKey } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'BatteryIntensiveModel';

@Concurrent
async function shutDownApp(context: Context): Promise<boolean> {
  try {
    // await deviceStandbyExt.clearAllPowerOveruseApp();
    LogUtil.info(`BatteryIntensiveModel: clearAllPowerOveruseApp finish`);
    return true;
  } catch (e) {
    LogUtil.error(`BatteryIntensiveModel: clearAllPowerOveruseApp error code: ${e?.code} message: ${e?.message}`);
  }
  return false;
}

async function needShow(): Promise<boolean> {
  // try {
  //   let appList: string[] = await deviceStandbyExt.getAllPowerOveruseAppList();
  //   LogUtil.info(`${TAG} getAllPowerOveruseAppList length: ${appList.length}`);
  //   return appList.length > 0;
  // } catch (e) {
  //   LogUtil.error(`${TAG} getAllPowerOveruseAppList error code: ${e?.code} message: ${e?.message}`);
  // }
  return false;
}

async function getAppNameList(): Promise<string[]> {
  let appList: string[] = [];
  try {
    // appList = await deviceStandbyExt.getAllPowerOveruseAppList();
  } catch (e) {
    LogUtil.error(`${TAG} getAllPowerOveruseAppList error code: ${e?.code} message: ${e?.message}`);
    return [];
  }
  let result: string[] = [];
  let bundleFlags: number =
    bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE;
  appList.forEach((app) => {
    try {
      let info: bundleManager.BundleInfo = bundleManager.getBundleInfoSync(app, bundleFlags);
      LogUtil.info(`${TAG} bundleInfo name: ${info.name}`);
      result.push(info.name ?? app);
    } catch (e) {
      LogUtil.error(`${TAG} getBundleInfoSync error code: ${e?.code} message: ${e?.message}`);
      result.push(app);
    }
  })
  return result;
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  const appList: string[] = await getAppNameList();
  const length: number = appList.length;
  let cardSummary: ResourceStr;
  let subscription: ResourceStr;
  switch (length) {
    case 0:
      cardSummary =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_card_sub_1'), '');
      subscription =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_sub_1'), '');
      break;
    case 1:
      cardSummary =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_card_sub_1'), appList[0]);
      subscription =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_sub_1'), appList[0]);
      break;
    case 2:
      cardSummary =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_card_sub_2'), appList[0],
          appList[1]);
      subscription =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_sub_2'), appList[0],
          appList[1]);
      break;
    case 3:
      cardSummary =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_card_sub_3'), appList[0],
          appList[1], appList[2]);
      subscription =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_sub_3'), appList[0],
          appList[1], appList[2]);
      break;
    default:
      cardSummary =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_card_sub_other'),
          appList[0], appList[1], appList[2]);
      subscription =
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.turn_off_battery_intensive_apps_sub_other'), appList[0],
          appList[1], appList[2]);
      break;
  }
  LogUtil.info(`${TAG} generateModel cardSummary: ${cardSummary}, subscription: ${subscription}`);
  return {
    key: TaskKey.SHUT_DOWN_APP,
    title: $r('app.string.turn_off_battery_intensive_apps'),
    cardSummary: cardSummary,
    subscription: subscription
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.SHUT_DOWN_APP, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: shutDownApp
})