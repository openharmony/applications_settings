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
import common from '@ohos.app.ability.common';
import commonEventManager from '@ohos.commonEventManager';
import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import BatteryListDataManager from '@ohos/settings.common/src/main/ets/data/BatteryListDataManager';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS,
  REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT
} from '@ohos/settings.common/src/main/ets/event/types';
import { BatteryListData } from '@ohos/settings.common/src/main/ets/data/BatteryListDataType';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { DefaultEntryMenuStyle, RootContainerStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { BaseEntryMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';


const TAG: string = 'PowerConsumptionListController : ';
const APP_POWER_LIST_GROUP: string = 'app_power_list_group';
const POWER_DATA_LOADING: string = 'PowerDataLoading';
const DEFAULT_APP_VERSION: string = '1.0.1';
const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: [POWER_DATA_LOADING],
  publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
};

@Concurrent
async function refreshDealBatteryData(context:common.Context): Promise<BatteryListData[]> {
  let lineData: BatteryListData[] = [];
  lineData = await BatteryListDataManager.queryBatteryHistoryData(context);
  return lineData;
}

/**
 * 耗电排行展示
 */
export class PowerConsumptionListController extends PageLifecycleMenuGroupController {
  public tag: string = 'PowerConsumptionListController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreatePowerConsumptionController(menu: SettingsBaseMenu): Controller {
    return new PowerConsumptionListController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();

    this.powerDataState.registerCommonEvent();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.powerDataState.unRegisterCommonEvent();
  }

  private powerDataState: CommonEventHelper = new CommonEventHelper(subscribeInfo, (err, data) => {
    let scanTask: taskpool.Task = new taskpool.Task(refreshDealBatteryData, AbilityContextManager.getContext());
    try {
      taskpool.execute(scanTask).then(async res =>{
        let menus: SettingsBaseMenu[] = [];
        menus = await this.collationBatteryHistoryData(res as BatteryListData[]);
        this.publishDataChange(false);
        this.clearChildren();
        this.addChildren(menus);
        this.refreshUi();
      })
    } catch (error) {
      LogUtil.error(` catch exception when setAppPowerData, code: ${error?.code} message: ${error?.message}`);
    }
  })

  onPageShow(): void {
    LogUtil.info(`${this.tag} onPageShow`);
    emitter.on({
      eventId: REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT,
    }, (eventData: emitter.EventData) => {
      this.getHourAppPowerData(eventData?.data?.startTimestamp, eventData?.data?.endTimestamp)
    });
    emitter.on({
      eventId: REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS,
    }, (eventData: emitter.EventData) => {
      this.getAppPowerData();
    });
  }

  onPageHide(): void {
    LogUtil.info(`${this.tag} onPageHide`);
    emitter.off(REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT);
    emitter.off(REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS);
  }

  /**
   * 获取1小时内应用耗电信息
   */
  private async getHourAppPowerData(startTimestamp: number, endTimestamp: number) {
    let menus: SettingsBaseMenu[] = [];
    await BatteryListDataManager.queryBatteryTimeAppData(AbilityContextManager.getContext(),
      startTimestamp, endTimestamp).then(async res => {
      menus = await this.collationBatteryHistoryData(res);
    }).catch((error: BusinessError) => {
      LogUtil.info(`${TAG} queryBatteryTimeAppData fail, error->${error?.message}`);
    });
    this.publishDataChange(false);
    this.clearChildren();
    this.addChildren(menus);
    this.refreshUi();
  }

  /**
   * 获取24小时内应用耗电信息
   */
  private async getAppPowerData() {
    LogUtil.info(`${TAG} xPowerManager getAppPowerData.`);
    let menus: SettingsBaseMenu[] = [];
    await BatteryListDataManager.queryBatteryHistoryData(AbilityContextManager.getContext()).then(async res => {
      menus = await this.collationBatteryHistoryData(res);
    }).catch((error: BusinessError) => {
      LogUtil.info(`${TAG} queryBatteryHistoryData fail, error->${error?.message}`);
    });
    this.publishDataChange(false);
    this.clearChildren();
    this.addChildren(menus);
    this.refreshUi();
  }

  collationAppPowerData(appEnergyArray: BatteryListData[]) {
    let subMap: Map<string, BatteryListData> = new Map();
    if (appEnergyArray.length < 1) {
      return appEnergyArray;
    }
    appEnergyArray.forEach(item => {
      if (subMap.has(item.bundleName)) {
        let hItem: BatteryListData = subMap.get(item.bundleName) as BatteryListData;
        hItem.foregroundTime += item.foregroundTime;
        hItem.foregroundPower += item.foregroundPower;
        hItem.backgroundTime += item.backgroundTime;
        hItem.backgroundPower += item.backgroundPower;
        hItem.totalPower += item.totalPower;
        return subMap.set(item.bundleName, hItem);
      } else {
        return subMap.set(item.bundleName, item);
      }
    })
    return Array.from(subMap.values());
  }

  async collationBatteryHistoryData(historyData: BatteryListData[]) {
    let menus: SettingsBaseMenu[] = [];
    let endTimestamp: number = DateTimeUtil.getPassTimestamp();
    let startTimestamp: number = endTimestamp - DateTimeUtil.getPerDayInMillis();
    LogUtil.info(`${TAG} startTimestamp:${startTimestamp},endTimestamp:${endTimestamp}`);
    let appDatas = this.collationAppPowerData(historyData);

    let totalPower: number = appDatas.reduce((prev, curr) => prev + curr.foregroundPower + curr.backgroundPower, 0);
    for (let data of appDatas) {
      let powerEntry: AppPowerEntry = new AppPowerEntry();
      let isValid: Boolean = await powerEntry.init(data, totalPower, startTimestamp, endTimestamp);
      if (isValid) {
        menus.push(new AppPowerMenu(powerEntry, this.menu.pathInfos));
      }
    }

    menus.sort((firstItem: AppPowerMenu, secondItem: AppPowerMenu) => {
      let first: AppPowerEntry = firstItem.extra as AppPowerEntry;
      let second: AppPowerEntry = secondItem.extra as AppPowerEntry;
      return second.appPower - first.appPower;
    });
    return menus;
  }
}

export class AppPowerMenu extends BaseEntryMenu {
  constructor(appPowerEntry: AppPowerEntry, pathInfos?: NavPathStack) {
    super({
      key: appPowerEntry.name,
    });
    this.title = appPowerEntry.title;
    this.icon = appPowerEntry.icon;
    this.stateIcon = $r('app.media.ic_settings_arrow');
    this.style = new PhonePowerConsumptionMenuStyle();
    this.timestamp = new Date().getTime();
    this.controller = {
      createControllerConstructorInter: AppEntryController.createAppEntryController,
    };
    this.pathInfos = pathInfos;
    this.state = appPowerEntry.percentage;
    this.extra = appPowerEntry;
  }
}

class PhonePowerConsumptionMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new PhonePowerConsumptionContainerStyle();
  public iconImage: ImageStyle = new AppIconStyle();
}

class PhonePowerConsumptionContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_64'),
  };
  public backgroundColor: ResourceStr = $r('sys.color.ohos_id_color_background');
}

export class AppIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: $r('app.float.wh_value_48'),
    height: $r('app.float.wh_value_48'),
  };
  public margin: Margin = {
    right: $r('app.float.margin_16'),
  };
  public imageFit = ImageFit.Contain;
  public visible = true;
  public borderWidth = '1px';
  public borderColor = '#3F808080';
}

/**
 * 应用列表项控制器
 *
 * @since 2024-01-02
 */
export class AppEntryController extends MenuController {
  static createAppEntryController(menu: SettingsBaseMenu): Controller {
    return new AppEntryController(menu);
  }

  onMenuClick(): boolean {
    if (!(this.menu instanceof AppPowerMenu)) {
      return false;
    }
    this.menu.pushName(NavEntryKey.POWER_CONSUMPTION_ENTRY, new PushParam(this.menu.extra as Object));
    return true;
  }
}

export class AppPowerEntry {
  public name: string = '';
  public title: ResourceStr | string = '';
  public icon: ResourceStr | PixelMap = '';
  public version: string = '';
  public foregroundTime: number = 0;
  public foregroundPower: number = 0;
  public backgroundTime: number = 0;
  public backgroundPower: number = 0;
  public appPower: number = 0;
  public percentage: string = '';
  public endTimestamp: number = 0;
  public startTimestamp: number = 0;
  public isVirtualApp: Boolean = false;

  async init(data: BatteryListData, totalPower: number, startTimestamp: number, endTimestamp: number):
    Promise<Boolean> {
    if (!data.bundleName) {
      LogUtil.error(`${TAG} AppPowerEntry init error, no bundle name.`);
      return false;
    }
    this.name = data.bundleName;

    let isSuccess: Boolean = await this.updateDisplayInfo(data.appType);
    if (!isSuccess) {
      return false;
    }

    this.foregroundTime = data.foregroundTime;
    this.foregroundPower = data.foregroundPower;
    this.backgroundTime = data.backgroundTime;
    this.foregroundPower = data.foregroundPower;
    this.backgroundPower = data.backgroundPower;
    this.appPower = data.foregroundPower + data.backgroundPower;
    let percentage: number = totalPower === 0 ? 0 : Math.round(this.appPower * 100 / totalPower);
    this.percentage = percentage === 0 ? '-' : percentage + '%';
    this.endTimestamp = endTimestamp;
    this.startTimestamp = startTimestamp;
    return true;
  }

  async updateDisplayInfo(appType: number): Promise<Boolean> {
    if (appType === 0) {
      return await this.updateDisplayInfoFromBMS();
    } else {
      return this.updateDisplayInfoFromLocal();
    }
  }

  updateDisplayInfoFromLocal(): Boolean {
    if (!this.name) {
      LogUtil.error(`${TAG} update app power entry from local error, name is empty.`);
      return false;
    }
    this.isVirtualApp = true;
    let resourceStr = `app.string.vapp_${this.name}`;
    this.title = ResourceUtil.getStringSync($r(resourceStr));
    if (!this.title) {
      LogUtil.error(`${TAG} update app power entry from local error, no resource: ${resourceStr}}`);
      return false;
    }
    this.icon = $r(`app.media.ic_${this.name}`)
    this.version = DEFAULT_APP_VERSION;
    return true;
  }

  async updateDisplayInfoFromBMS(): Promise<Boolean> {
    try {
      let entry = await AppListLoader.getInstance().getAndUpdateAppEntryByName(this.name);
      if (!entry) {
        LogUtil.error(`${TAG}: update app power entry from bms error, not find app: ${this.name}`);
        return false;
      }

      this.title = entry.label as string;
      this.icon = entry.icon as ResourceStr | PixelMap;
      this.version = entry.versionName as string;
    } catch (error) {
      LogUtil.error(`${TAG} update app power entry from bms error, name: ${this.name}`);
      return false;
    }
    return true;
  }
}

/**
 * 应用耗电列表加载中动效控制器
 *
 * @since 2024-01-05
 */
export class AppLoadingController extends MenuController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateAppLoadingController(menu: SettingsBaseMenu): Controller {
    return new AppLoadingController(menu);
  }

  protected registerDataChange(): void {
    this.registerControllerDataChange(APP_POWER_LIST_GROUP);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(APP_POWER_LIST_GROUP);
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === APP_POWER_LIST_GROUP && typeof data === 'boolean') {
      this.setVisible(data);
    }
  }
}