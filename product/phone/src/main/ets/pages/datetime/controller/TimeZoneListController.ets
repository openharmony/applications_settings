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

import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { DEFAULT_PADDING_START, DefaultEntryMenuStyle, EntryMenu, RootContainerStyle } from '@ohos/settings.uikit';
import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';
import { ExtensionTimeZoneMenuController, TimeZoneMenuController } from './TimeZoneMenuController';
import taskpool from '@ohos.taskpool';
import TimeZoneTPManager, { BasicTimeZoneInfo } from './TimeZoneTaskPoolManager';
import TimeZoneExtensionTPManager, { BasicTimeZoneExtensionInfo } from './TimeZoneExtensionTaskPoolManager';
/* instrument ignore file */
const TAG: string = 'TimeZoneListController : ';
const TIME_ZONE_START_INDEX: number = 0;
const TIME_ZONE_LIST_GROUP: string = 'time_zone_list_group';
const TIME_ZONE_LOADING_DELAY: number = 15;
const WORLD_CLOCK_FIRST_LOAD_NUM: number = 50;

@Concurrent
function sortAsync(data: Array<string>): Array<string> {
  let compare: (string1: string, string2: string) => number = (string1: string, string2: string): number => {
    let collator = new intl.Collator();
    return collator.compare(string1, string2);
  }
  data.sort((firstItem, secondItem) => {
    return compare(firstItem, secondItem);
  })
  return data;
}

@Concurrent
function getTimeZoneInfoAsync(): BasicTimeZoneInfo {
  return TimeZoneTPManager.getTimeZoneInfo()
}

@Concurrent
function getTimeZoneExtensionInfoAsync(locale: string, isFirstLoading: Boolean,
                                       firstLoadNum: number): BasicTimeZoneExtensionInfo {
  return TimeZoneExtensionTPManager.getTimeZoneInfo(locale, isFirstLoading, firstLoadNum);
}

class TimeZoneContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public padding: Padding = {
    top: FontScaleUtils.getCurrentPadding(),
    bottom: FontScaleUtils.getCurrentPadding(),
    left: DEFAULT_PADDING_START,
  };
}

class TimeZoneMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new TimeZoneContainerStyle();
}

let timeZoneMenuStyle = new TimeZoneMenuStyle();

/**
 * 时区列表控制器
 *
 * @since 2022-12-09
 */
export class TimeZoneListController extends PageLifecycleMenuGroupController {
  public currentIndex: number = TIME_ZONE_START_INDEX;
  public isFirstLoading: boolean = true;

  static CreateTimeZoneListController(menu: SettingsBaseMenu): Controller {
    return new TimeZoneListController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.loadTimeZoneCityListAsync();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  /**
   * 获取时区列表
   *
   */
  getTimeZoneList(): Array<i18n.TimeZone> | undefined {
    let cityIds: string[] = TimeZoneUtil.getAvailableZoneCityIDs();
    if (!cityIds) {
      LogUtil.error(`${TAG} get cityIds failed`);
      return;
    }
    let timeZoneList: i18n.TimeZone[] = [];
    cityIds.forEach(cityId => {
      let timeZone: i18n.TimeZone = TimeZoneUtil.getTimezoneFromCity(cityId);
      timeZoneList.push(timeZone);
    });
    LogUtil.info(`${TAG} timeZoneList length is ${timeZoneList.length}`);
    return timeZoneList;
  }

  /**
   * 异步加载时区城市列表
   *
   */
  loadTimeZoneCityListAsync(): void {
    // 这里使用setTimeout来实现异步延迟运行
    setTimeout(() => {
      this.loadTimeZoneCityList();
    }, TIME_ZONE_LOADING_DELAY);
  }

  /**
   * 加载时区城市列表
   *
   */
  async loadTimeZoneCityList(): Promise<void> {
    let isWorldClock: boolean = (AppStorage.get<boolean>('isWorldClock') as boolean);
    let locale: string = TimeZoneUtil.getSystemLanguage();

    if (isWorldClock) {
      let timeZoneInfoObject: BasicTimeZoneExtensionInfo = new BasicTimeZoneExtensionInfo();
      // 第一次加载
      let task: taskpool.Task =
        new taskpool.Task(getTimeZoneExtensionInfoAsync, locale, true, WORLD_CLOCK_FIRST_LOAD_NUM);
      try {
        timeZoneInfoObject = await taskpool.execute(task, taskpool.Priority.MEDIUM) as BasicTimeZoneExtensionInfo;
      } catch (e) {
        LogUtil.error(`${TAG} catch exception when getTimeZoneExtensionInfoAsync [first loading],
        errmsg: ${e?.message}`);
      }
      if (timeZoneInfoObject.titleArray.length < 1) {
        LogUtil.error(`${TAG} get timeZoneInfoObject [first loading] failed`);
        return;
      }
      let menus: SettingsBaseMenu[] = [];
      for (let i = 0; i < timeZoneInfoObject.titleArray.length; i++) {
        menus.push(new EntryMenu({
          key: timeZoneInfoObject.keyArray[i],
          title: timeZoneInfoObject.titleArray[i],
          style: timeZoneMenuStyle,
          summary: timeZoneInfoObject.clockSummary[i],
          controller: {
            createControllerConstructorInter: TimeZoneMenuController.CreateTimeZoneMenuController,
          },
          extra: timeZoneInfoObject.keyArray[i],
          pathInfos: this.menu.pathInfos,
        }));
      }
      this.addChildren(menus);
      this.refreshUi();
      LogUtil.info(`${TAG} end refresh ui`);
      DynamicLoader.getInstance().pageTransitionSuccess('TimeZoneSettings');
      this.publishDataChange(false);

      if (WORLD_CLOCK_FIRST_LOAD_NUM < menus.length) {
        // 第二次加载
        task = new taskpool.Task(getTimeZoneExtensionInfoAsync, locale, false, WORLD_CLOCK_FIRST_LOAD_NUM);
        try {
          timeZoneInfoObject = await taskpool.execute(task, taskpool.Priority.MEDIUM) as BasicTimeZoneExtensionInfo;
        } catch (e) {
          LogUtil.error(`${TAG} catch exception when getTimeZoneExtensionInfoAsync [second loading],
          errmsg: ${e?.message}`);
        }
        if (timeZoneInfoObject.titleArray.length < 1) {
          LogUtil.error(`${TAG} get timeZoneInfoObject [second loading] failed`);
          return;
        }
        for (let i = WORLD_CLOCK_FIRST_LOAD_NUM; i < timeZoneInfoObject.titleArray.length; i++) {
          menus[i].summary = timeZoneInfoObject.clockSummary[i];
        }
        this.clearChildren();
        this.addChildren(menus);
        this.refreshUi();
        LogUtil.info(`${TAG} end refresh ui`);
      }
    } else {
      let timeZoneInfoObject: BasicTimeZoneInfo = new BasicTimeZoneInfo();
      let task: taskpool.Task = new taskpool.Task(getTimeZoneInfoAsync);
      try {
        timeZoneInfoObject = await taskpool.execute(task, taskpool.Priority.MEDIUM) as BasicTimeZoneInfo;
      } catch (e) {
        LogUtil.error(`${TAG} catch exception when getTimeZoneInfoAsync, errmsg: ${e?.message}`);
      }
      if (timeZoneInfoObject.titleArray.length < 1) {
        LogUtil.error(`${TAG} get timeZoneInfoObject failed`);
        return;
      }
      let menus: SettingsBaseMenu[] = [];
      for (let i = 0; i < timeZoneInfoObject.titleArray.length; i++) {
        menus.push(new EntryMenu({
          key: timeZoneInfoObject.keyArray[i],
          title: timeZoneInfoObject.titleArray[i],
          style: timeZoneMenuStyle,
          summary: timeZoneInfoObject.settingSummary[i],
          controller: {
            createControllerConstructorInter: TimeZoneMenuController.CreateTimeZoneMenuController,
          },
          extra: timeZoneInfoObject.keyArray[i],
          pathInfos: this.menu.pathInfos,
        }));
      }
      this.addChildren(menus);
      this.refreshUi();
      LogUtil.info(`${TAG} end refresh ui`);
      DynamicLoader.getInstance().pageTransitionSuccess('TimeZoneSettings');
      this.publishDataChange(false);
    }
  }

  /**
   * 创建时区城市菜单项
   *
   */
  protected createTimeZoneMenu(cityId: string, locale: string): SettingsBaseMenu {
    let timeZone: i18n.TimeZone = TimeZoneUtil.getTimezoneFromCity(cityId);
    let rawOffset: string;
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      rawOffset = TimeZoneUtil.getSelectCitySummary(timeZone, locale);
    } else {
      rawOffset = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
    }
    let menu = new EntryMenu({
      key: cityId,
      title: TimeZoneUtil.getCityDisplayName(cityId, locale),
      style: timeZoneMenuStyle,
      summary: rawOffset,
      controller: {
        createControllerConstructorInter: TimeZoneMenuController.CreateTimeZoneMenuController,
      },
      extra: cityId,
      pathInfos: this.menu.pathInfos,
    });
    return menu;
  }

  /**
   * 时区城市列表的排序
   *
   */
  public compareCity = (city1: SettingsBaseMenu, city2: SettingsBaseMenu): number => {
    let collator = new intl.Collator();
    return collator.compare(city1?.title?.toString() as string, city2?.title?.toString() as string);
  }

  onRegisteredByObserver(observerKey: string): void {
    this.publishDataChange(this.isFirstLoading);
  }

  updateStatus(): void {
    super.updateStatus();
  }
}

export class ExtensionTimeZoneListController extends TimeZoneListController {
  static CreateExtensionTimeZoneListController(menu: SettingsBaseMenu): Controller {
    return new ExtensionTimeZoneListController(menu);
  }

  /**
   * 创建时区城市菜单项
   *
   */
  protected createTimeZoneMenu(cityId: string, locale: string): SettingsBaseMenu {
    let timeZone = TimeZoneUtil.getTimezoneFromCity(cityId);
    let rawOffset = '';
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      rawOffset = TimeZoneUtil.getSelectCitySummary(timeZone, locale);
    } else {
      rawOffset = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
    }
    let menu = new EntryMenu({
      key: cityId,
      title: TimeZoneUtil.getCityDisplayName(cityId, locale),
      style: timeZoneMenuStyle,
      summary: rawOffset,
      controller: {
        createControllerConstructorInter: ExtensionTimeZoneMenuController.CreateExtensionTimeZoneMenuController,
      },
      extra: cityId,
    });
    return menu;
  }
}

/**
 * 应用列表加载中动效控制器
 *
 * @since 2022-05-28
 */
export class TimeZoneLoadingController extends MenuController {
  static CreateTimeZoneLoadingController(menu: SettingsBaseMenu): Controller {
    return new TimeZoneLoadingController(menu);
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange for TimeZoneLoadingController `);
    this.registerControllerDataChange(TIME_ZONE_LIST_GROUP);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange for TimeZoneLoadingController `);
    this.unRegisterControllerDataChange(TIME_ZONE_LIST_GROUP);
  }

  onDataChange(fromKey: string, data: boolean): void {
    LogUtil.info(`${TAG} onDataChange for TimeZoneLoadingController ${fromKey}, ${data}`);
    if (fromKey === TIME_ZONE_LIST_GROUP && typeof data === 'boolean') {
      this.setVisible(data);
    }
  }
}
