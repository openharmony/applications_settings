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
import { image } from '@kit.ImageKit';
import { LengthMetrics } from '@kit.ArkUI';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import emitter from '@ohos.events.emitter';
import taskpool from '@ohos.taskpool';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { HdsDrawableTools } from '@ohos/settings.application/src/main/ets/AppIconProcessing';
import { PageList, ThemeManager } from '@ohos/settings.application/src/main/ets/util/ThemeManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import BatteryListDataManager from '@ohos/settings.common/src/main/ets/data/BatteryListDataManager';
import { BatteryListData } from '@ohos/settings.common/src/main/ets/data/BatteryListDataType';
import {
  EVENT_ID_BUNDLE_RESOURCES_CHANGED,
  REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS,
  REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import {
  NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const TAG: string = 'PowerConsumptionListController: ';
const POWER_DATA_LOADING: string = 'PowerDataLoading';
const DEFAULT_APP_VERSION: string = '1.0.1';
// 分段加载 5 个刚刚好第一次可以显示折线图
const FIRST_RENDER_NUM: number = 5;
const BUNDLE_RESOURCE_CHANGE_TIMEOUT: number = 50;
const MAX_REFRESH_TIMES: number = 100000;
// 最大耗电量临界值2mAh，小于最大耗电量所有耗电量显示为-，否则显示对应的数值，直接获取的耗电数据单位为mAs，由mAh转换为mAs；
const MAX_POWER_CONSUMPTION_CRITICAL_VALUE: number = 2 * 60 * 60;

@Builder
function appCloneBadgeBuilder(param: object): void {
  AppCloneBadgeComponent({
    appCloneBadgeParam: param as SettingItemModel,
    iconSize: 48,
    bundleName: ((param as SettingItemModel)?.extra as AppEntry)?.name
  })
}

/**
 * 数据库插入完成通知刷新事件
 */
const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: [POWER_DATA_LOADING],
  publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
};

@Concurrent
async function refreshDealBatteryData(context:common.Context): Promise<BatteryListData[]> {
  const listData: BatteryListData[] = await BatteryListDataManager.queryBatteryHistoryData(context);
  return listData;
}

/**
 * 耗电排行展示
 */
export class PowerConsumptionListController implements ComponentControl {
  public dataSource?: DynamicDataSource;
  private readonly pageName: PageList = PageList.BATTERY_PAGE;
  private timerId?: number;
  private refreshTimes: number = 0;
  private endTimestamp: number = DateTimeUtil.getPassTimestamp();
  private startTimestamp: number = this.endTimestamp - DateTimeUtil.getPerDayInMillis();
  private allAppData: BatteryListData[] = [];
  private currentAppListShow: BatteryListData[] = [];
  private bundleResourceChangeTimeoutId: number | null = null;
  private onBundleResourcesChangedCallback: (isChanged: boolean) => void = async (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (!isChanged) {
      return;
    }
    if (this.bundleResourceChangeTimeoutId !== null) {
      clearTimeout(this.bundleResourceChangeTimeoutId);
    }
    this.bundleResourceChangeTimeoutId = setTimeout(async () => {
      LogUtil.info(`${TAG} refresh for bundle resources changed`);
      if (this.dataSource) {
        this.dataSource.splice(0, this.dataSource.length);
      }
      EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, true);
      await this.refreshAppList(this.allAppData, true);
      await this.createItemModels(this.currentAppListShow);
    }, BUNDLE_RESOURCE_CHANGE_TIMEOUT);
  };

  private powerDataState: CommonEventHelper = new CommonEventHelper(subscribeInfo, (err, data) => {
    if (err?.code) {
      LogUtil.error(`${TAG} CommonEventHelper failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.info(`${TAG} getDataFromDatabase from common event:${data?.event}`);
      this.getDataFromDatabase();
    }
  });

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.dataSource = (compParam.dataSource) as DynamicDataSource;
    // 初始化查询应用耗电列表数据
    this.getDataFromDatabase();
    this.powerDataState.registerCommonEvent();
    this.registerDataChange();
    // 每次进来的时候 需要判断下是否删除应用缓存
    AppListLoader.getInstance().updateSystemLocale();
  }

  private registerDataChange(): void {
    // 折线图点击时间段的事件
    emitter.on({ eventId: REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT },
      (eventData: emitter.EventData) => {
        LogUtil.info(`${TAG} getTimeDataFromDatabase from lineChart select time period`);
        this.startTimestamp = eventData?.data?.startTimestamp;
        this.endTimestamp = eventData?.data?.endTimestamp;
        this.getTimeDataFromDatabase(eventData?.data?.startTimestamp, eventData?.data?.endTimestamp);
      });
    // 折线图还原全部数据的事件
    emitter.on({ eventId: REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS }, () => {
      LogUtil.info(`${TAG} getDataFromDatabase from lineChart restore all data`);
      this.endTimestamp = DateTimeUtil.getPassTimestamp();
      this.startTimestamp = this.endTimestamp - DateTimeUtil.getPerDayInMillis();
      this.getDataFromDatabase();
    });
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.powerDataState.unRegisterCommonEvent();
    this.unregisterDataChange();
    if (this.bundleResourceChangeTimeoutId !== null) {
      clearTimeout(this.bundleResourceChangeTimeoutId);
    }
  }

  private unregisterDataChange(): void {
    emitter.off(REFRESH_THE_RANKING_OF_POWER_CONSUMING_APPS_WITHIN_THE_TIME_SEGMENT);
    emitter.off(REFRESH_ALL_POWER_CONSUMPTION_RANKING_EVENTS);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  private async refreshAppList(appList: BatteryListData[], isNeedToRefreshAll: boolean) {
    // 取出所有应用的bundleName
    let bundleNameList: string[] = [];
    // 先判断对应应用图标是否在缓存区中，如果不存在，则记录需要创建的
    for (let data of appList) {
      if (data.appType === 0) {
        bundleNameList.push(data.bundleName);
      }
    }

    await AppListLoader.getInstance().updateAppEntriesCache(bundleNameList, isNeedToRefreshAll);
    ThemeManager.getInstance().resetRefreshStatus(this.pageName);
  }


  /**
   * 从数据库获取全部应用耗电数据
   */
  private getDataFromDatabase(): void {
    EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, true);
    try {
      let taskPoolTask: taskpool.Task = new taskpool.Task(refreshDealBatteryData, AbilityContextManager.getContext());
      taskpool.execute(taskPoolTask, taskpool.Priority.HIGH).then(async res => {
        const appPowerConsumptionData = res as BatteryListData[];
        LogUtil.info(`${TAG} getDataFromDatabase appPowerConsumptionData.length:${appPowerConsumptionData?.length}`);
        // 根据应用bundleName合并数据
        this.allAppData = this.collationAppPowerData(appPowerConsumptionData);
        this.currentAppListShow = this.allAppData;

        await this.refreshAppList(this.allAppData, ThemeManager.getInstance().checkIsNeedToRefresh(this.pageName));

        await this.createItemModels(this.allAppData);
      });
    } catch (error) {
      EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, false);
      LogUtil.error(`${TAG} getDataFromDatabase catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  /**
   * 从数据库获取时间段内应用耗电数据
   */
  private getTimeDataFromDatabase(startTimestamp: number, endTimestamp: number) {
    EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, true);
    BatteryListDataManager.queryBatteryTimeAppData(AbilityContextManager.getContext(),
      startTimestamp, endTimestamp).then(async appPowerConsumptionData => {
      LogUtil.info(`${TAG} getTimeDataFromDatabase appPowerConsumptionData.length:${appPowerConsumptionData?.length}`);
      this.currentAppListShow = this.collationAppPowerData(appPowerConsumptionData)
      // 根据应用bundleName合并数据
      await this.createItemModels(this.currentAppListShow);
    }).catch((error: BusinessError) => {
      EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, false);
      LogUtil.info(`${TAG} getTimeDataFromDatabase catch error. code:${error?.code} message:${error?.message}`);
    });
  }

  /**
   * 关闭标题头loading样式
   */
  private setListLoadingFalse(): void {
    if (this.timerId) {
      clearTimeout(this.timerId);
    }
    // 延时取消 loading 动画 避免数据量小的时候动画闪烁
    this.timerId = setTimeout(() => {
      EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_APP_POWER_LIST_LOADING, false);
      this.timerId = undefined;
    }, 500)
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = { border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0, width: 48, height: 48, mirrored: false };
    return style;
  }

  private async createItemModels(appDatas: BatteryListData[]): Promise<void> {
    LogUtil.info(`${TAG} createItemModels. startTimestamp:${this.startTimestamp} endTimestamp:${this.endTimestamp}`);
    // 根据耗电量排序
    appDatas.sort((firstItem: BatteryListData, secondItem: BatteryListData) => {
      let first: number = firstItem?.totalPower ?? 0;
      let second: number = secondItem?.totalPower ?? 0;
      return second - first;
    });
    let maxPower: number = appDatas.length > 0 ? (appDatas[0]?.totalPower ?? 0) : 0;
    let totalPower: number = appDatas.reduce((prev, curr) => prev + curr.foregroundPower + curr.backgroundPower, 0);
    // 需要分段更新列表的次数
    let totalNum = Math.ceil(appDatas.length / FIRST_RENDER_NUM);
    // 是否只需要一段更新 即表示一次完成更新
    let isReplaceOnce = totalNum <= 1;
    // 除去最后一段push 前面几段需要替换的次数
    let fullTotalNum = totalNum - 1;
    // 先把最后一段数据删除 为push做准备
    if (!isReplaceOnce) {
      this.dataSource?.splice(fullTotalNum * FIRST_RENDER_NUM,
        this.dataSource?.length - fullTotalNum * FIRST_RENDER_NUM);
    }
    let pushNum: number = 0;
    let splitMenus: AppPowerSettingItemModel[] = [];
    this.refreshTimes = (this.refreshTimes++) > MAX_REFRESH_TIMES ? 0 : this.refreshTimes;
    for (let data of appDatas) {
      let powerEntry: AppPowerEntry = new AppPowerEntry();
      let isValid: boolean = await powerEntry.init(data, totalPower, this.startTimestamp, this.endTimestamp, maxPower);
      if (!isValid) {
        LogUtil.info(`${TAG} createItemModels powerEntry.init failed. name:${powerEntry.name} isValid:${isValid}`);
        continue;
      }
      const item = this.createSettingItemModel(powerEntry);
      LogUtil.info(`${TAG} after createSettingItemModel name:${powerEntry.name} percentage:${powerEntry.percentage}`);
      splitMenus.push(item);
      if (isReplaceOnce) {
        continue;
      }
      if (pushNum < fullTotalNum && splitMenus.length === FIRST_RENDER_NUM) {
        let oldLength = this.dataSource?.length || 0;
        if (pushNum * FIRST_RENDER_NUM >= oldLength) {
          this.dataSource?.pushData(...splitMenus)
        } else {
          this.dataSource?.splice(pushNum * FIRST_RENDER_NUM, FIRST_RENDER_NUM, ...splitMenus);
        }
        pushNum = pushNum + 1;
        splitMenus = [];
      }
    }
    if (isReplaceOnce) {
      // 一次完成更新
      this.dataSource?.splice(0, this.dataSource?.length, ...splitMenus)
    } else {
      // 分段更新时 最后一段直接push
      this.dataSource?.pushData(...splitMenus);
    }
    this.setListLoadingFalse();
    LogUtil.info(`${TAG} createItemModels. dataSource.length:${this.dataSource?.length}`);
  }

  private createSettingItemModel(powerEntry: AppPowerEntry): AppPowerSettingItemModel {
    let itemModel: AppPowerSettingItemModel = {
      id: powerEntry.name + powerEntry.appPower + this.refreshTimes,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: powerEntry.icon,
        iconType: SettingIconType.ICON_TYPE_APPICON,
        style: this.getIconStyle(),
        builder: AppUtils.isSupportShowIconBadge(powerEntry.appEntry as AppEntry)
          ? wrapBuilder(appCloneBadgeBuilder) : undefined
      },
      layout: {
        middleColumnSpace: LengthMetrics.vp(2)
      },
      desc: {
        content: this.getDescription(powerEntry),
        style: {
          fontSize: $r('sys.float.Body_S')
        }
      },
      title: { content: powerEntry.title },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: powerEntry.percentage } },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        iconType: SettingIconType.ICON_TYPE_ARROW,
        style: { width: 12, height: 24 },
        onItemClick: (component: SettingBaseModel) => {
          LogUtil.info(`${TAG} onItemClick`);
          PageRouter.push(NavEntryKey.POWER_CONSUMPTION_ENTRY, new PushParam(powerEntry));
        },
      },
      extra: powerEntry.appEntry as AppEntry
    };
    return itemModel;
  }

  private getDescription(powerEntry: AppPowerEntry): ResourceStr {
    const backGroundPowerInmAh = powerEntry.backgroundPower / DateTimeUtil.TIME_HOUR_IN_SECONDS;
    const isOverOneHour = powerEntry.endTimestamp - powerEntry.startTimestamp > DateTimeUtil.getPerHourInMillis();
    if ((isOverOneHour && backGroundPowerInmAh > 100) || (!isOverOneHour && backGroundPowerInmAh > 50)) {
      return $r('app.string.background_activities');
    }
    return '';
  }

  private collationAppPowerData(appEnergyArray: BatteryListData[]) {
    let subMap: Map<string, BatteryListData> = new Map();
    LogUtil.info(`${TAG} collationAppPowerData appEnergyArray length: ${appEnergyArray.length}`);
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
    LogUtil.info(`${TAG} collationAppPowerData. subMap.size: ${subMap?.size}`);
    return Array.from(subMap.values());
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
  public appEntry: AppEntry | null = null;

  async init(data: BatteryListData, totalPower: number, startTimestamp: number, endTimestamp: number, maxPower: number):
    Promise<boolean> {
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
    this.backgroundPower = data.backgroundPower;
    this.appPower = data.totalPower;
    this.endTimestamp = endTimestamp;
    this.startTimestamp = startTimestamp;
    this.calculatePowerPercentage(maxPower, totalPower);
    let logStr = `${TAG} AppPowerEntry init. `;
    logStr = logStr + `name:${this.name} percentage:${this.percentage}%`;
    logStr = logStr + `fore/backTime:${this.foregroundTime}/${this.backgroundTime} `;
    logStr = logStr + `fore/backPower:${this.foregroundPower}/${this.backgroundPower}`;
    LogUtil.info(logStr);
    return true;
  }

  private calculatePowerPercentage(maxPower: number, totalPower: number): void {
    if (maxPower < MAX_POWER_CONSUMPTION_CRITICAL_VALUE) {
      this.percentage = '-';
    } else {
      let percentage: number = totalPower === 0 ? 0 : Math.floor(this.appPower * 100 / totalPower);
      this.percentage = percentage === 0 ? '-' : `${percentage}%`;
    }
  }

  async updateDisplayInfo(appType: number): Promise<Boolean> {
    if (appType === 0) {
      return await this.updateDisplayInfoFromBMS();
    } else {
      return this.updateDisplayInfoFromLocal();
    }
  }

  updateDisplayInfoFromLocal(): Boolean {
    LogUtil.info(`${TAG} updateDisplayInfoFromLocal start. name:${this.name}`);
    if (!this.name) {
      LogUtil.error(`${TAG} update app power entry from local error, name is empty.`);
      return false;
    }
    this.isVirtualApp = true;
    let resourceName = `vapp_${this.name}`;
    this.title = ResourceUtil.getStringByName(resourceName);
    if (!this.title) {
      LogUtil.error(`${TAG} update app power entry from local error, no resource: ${resourceName}}`);
      return false;
    }
    this.version = DEFAULT_APP_VERSION;
    let resName: string = `ic_${this.name}`;
    this.icon = $r(`app.media.${resName}`);
    let pixelMap: PixelMap | undefined = HdsDrawableTools.getInstance().getHdsIconFromResource(resName, this.name);
    if (pixelMap) {
      this.icon = pixelMap;
    }
    return true;
  }

  async updateDisplayInfoFromBMS(): Promise<Boolean> {
    try {
      LogUtil.info(`${TAG} updateDisplayInfoFromBMS start. name:${this.name}`);
      let entry = await AppListLoader.getInstance().getAndUpdateAppEntryByNameForBattery(this.name);
      if (!entry) {
        LogUtil.error(`${TAG}: update app power entry from bms error, not find app: ${this.name}`);
        return false;
      }
      this.appEntry = entry;
      this.title = entry.label as string;
      this.icon = entry.icon as ResourceStr | PixelMap;
      this.version = entry.versionName as string;
      this.printIconInfo();
    } catch (error) {
      LogUtil.error(`${TAG} update app power entry from bms error, name: ${this.name} code: ${error?.code} message: ${error?.message}`);
      return false;
    }
    return true;
  }

  /**
   * 打印icon信息
   */
  printIconInfo(): void {
    if (typeof this.icon === 'string') {
      LogUtil.info(`${TAG} tile ${this.title} icon is string: ${this.icon}`);
    } else {
      let pixelMap = this.icon as PixelMap;
      try {
        let imageInfo: image.ImageInfo = pixelMap.getImageInfoSync();
        LogUtil.info(`${TAG} tile ${this.title} icon is pixelMap, size {${imageInfo?.size?.width}, ${imageInfo?.size?.height}}`);
      } catch {
        LogUtil.error(`${TAG} tile ${this.title} icon is pixelMap, get imageInfo failed`);
      }
    }
  }
}

export interface AppPowerSettingItemModel extends ComparableSettingItemModel {
  appPowerEntry?: AppPowerEntry;
}