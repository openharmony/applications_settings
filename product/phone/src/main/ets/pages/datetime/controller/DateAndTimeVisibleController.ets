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

import { dateTimeManager } from '@kit.MDMKit';
import { BusinessError } from '@ohos.base';
import systemParameter from '@ohos.systemparameter';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContainerStyle, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import {
  PageLifecycleMenuGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { RootContainerStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import systemDateTime from '@ohos.systemDateTime';
import i18n from '@ohos.i18n';
import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';
import intl from '@ohos.intl';
import emitter from '@ohos.events.emitter';
import { EventId } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DefaultEntryMenuStyle, EntryMenu, NavigationEntry, StateMenu, StateTextStyle } from '@ohos/settings.uikit';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import DateController from './DateController';
import TimeController from './TimeController';
import TimeZoneController from './TimeZoneController';
import { PageUrl } from '../../PageUrl';
import AutoTimeZoneController from './AutoTimeZoneController';
import NoClickTimeZoneController from './NoClickTimeZoneController';

/* instrument ignore file */
const DATE_SETTINGS: string = 'date_settings';
const KEY_TIME_SETTINGS: string = 'time_settings';
const KEY_TIME_ZONE_SETTINGS: string = 'time_zone_settings';
const KEY_TIME_ZONE_NOT_CLICK: string = 'time_zone_not_click';
const KEY_TIME_ZONE_ON_CLICK: string = 'time_zone_on_click';
const TAG: string = 'DateAndTimeVisibleController: ';

class TimeZoneTextStyle extends StateTextStyle {
  public constraintSize: ConstraintSizeOptions = {
    maxWidth: 'calc(100% - 42vp)'
  }
}

let timeZoneTextStyle = new TimeZoneTextStyle();

// 设置时间菜单窗口偏移量
class TimeZoneMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootContainerStyle();
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
  public state: TextStyle = timeZoneTextStyle;
}

/**
 * 时间，日期显示隐藏控制器
 *
 * @since 2022-04-27
 */
export class DateAndTimeVisibleController extends PageLifecycleMenuGroupController {
  static CreateDateAndTimeVisibleController(menu: SettingsBaseMenu): Controller {
    return new DateAndTimeVisibleController(menu);
  }

  private isDisabledAutoTimeZoneSwitch: boolean = false;

  private changeValue(): void {
    let checkedState: boolean = this.updateCheckedState();
    LogUtil.info(`${TAG}  changeValue, autoTimeState: ${checkedState}`);
    if (checkedState) {
      let stateStr: string = '';
      let timeZoneTimer = setTimeout(() => {
        this.deleteChildren();
        this.getPhoneTimeZoneMenu();
        clearTimeout(timeZoneTimer);
      }, 50)
    } else {
      this.deleteChildren();
      this.removeChildren(KEY_TIME_ZONE_SETTINGS);
      this.addChildMenu();
    }
    this.refreshUi();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG}  onPageShow`);
    this.updateChildMenu();
  }

  async updateChildMenu(): Promise<void> {
    await dateTimeManager.isModifyDateTimeDisallowed(null).then((result) => {
      if (this.isDisabledAutoTimeZoneSwitch === result) {
        return;
      }
      this.isDisabledAutoTimeZoneSwitch = result;
      let autoTimeZoneController: AutoTimeZoneController =
        this.menu?.getControllerFromPage('auto_timezone') as AutoTimeZoneController;
      autoTimeZoneController?.setAutoTimeZoneSwitchState(this.isDisabledAutoTimeZoneSwitch);
      this.changeValue();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG}: Failed to query modify date time is disallowed or not, Code: ${err?.code},
        message: ${err?.message}`);
    });
  }

  addChildMenu(): void {
    this.addChildren([
      new EntryMenu(
        {
          key: DATE_SETTINGS,
          index: 50,
          title: $r('app.string.date_settings_title'),
          controller: {
            createControllerConstructorInter: DateController.CreateDateController,
          },
          stateIcon: $r('app.media.ic_settings_arrow'),
        }
      ),
      new EntryMenu(
        {
          key: 'time_settings',
          index: 100,
          title: $r('app.string.time_settings_title'),
          controller: {
            createControllerConstructorInter: TimeController.CreateTimeController,
          },
          stateIcon: $r('app.media.ic_settings_arrow'),
        }
      ),
      new NavigationEntry(
        {
          key: 'time_zone_settings',
          index: 150,
          title: $r('app.string.time_zone_settings_title'),
          stateIcon: $r('app.media.ic_settings_arrow'),
          style: new TimeZoneMenuStyle(),
          targetPageUrl: PageUrl.TIME_ZONE_PAGE_URL,
          controller: {
            createControllerConstructorInter: TimeZoneController.CreateTimeZoneController,
          },
          pathInfos: this.menu.pathInfos,
        },
      ),
    ]);
  }

  refreshUi(): void {
    super.refreshUi();
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    return systemParameter.getSync('persist.time.auto_time', 'ON') === 'ON';
  }

  protected deleteChildren(): void {
    this.removeChildren(DATE_SETTINGS);
    this.removeChildren(KEY_TIME_SETTINGS);
    this.removeChildren(KEY_TIME_ZONE_NOT_CLICK);
    this.removeChildren(KEY_TIME_ZONE_ON_CLICK);
  }

  updateStatus(): void {
    super.updateStatus();
    emitter.off(EventId.UpdateAutoTimeZoneStateNum);
    emitter.on({
      eventId: EventId.UpdateAutoTimeZoneStateNum,
    }, (eventData: emitter.EventData) => {
      this.changeValue();
    });
  }

  private getPadTimeZoneMenu() {
    const menu = (stateStr: ResourceStr | undefined) => new NavigationEntry(
      {
        key: 'time_zone_on_click',
        index: 150,
        title: $r('app.string.time_zone_settings_title'),
        stateIcon: $r('app.media.ic_settings_arrow'),
        style: new TimeZoneMenuStyle(),
        targetPageUrl: PageUrl.TIME_ZONE_PAGE_URL,
        state: stateStr,
        controller: {
          createControllerConstructorInter: TimeZoneController.CreateTimeZoneController,
        },
        pathInfos: this.menu.pathInfos,
      },
    )
    this.addTimeZoneMenu(menu);
  }

  private getPhoneTimeZoneMenu() {
    const menu = (stateStr: ResourceStr | undefined) => new StateMenu(
      {
        key: 'time_zone_not_click',
        index: 150,
        title: $r('app.string.time_zone_settings_title'),
        style: new TimeZoneMenuStyle(),
        state: stateStr,
        enable: !this.isDisabledAutoTimeZoneSwitch,
        accessibilityDescription: ' ',
        controller: {
          createControllerConstructorInter: NoClickTimeZoneController.CreateTimeZoneController,
        },
      }
    )
    this.addTimeZoneMenu(menu);
  }

  private addTimeZoneMenu(menu: (str: string) => SettingsBaseMenu) {
    let stateStr: string = '';
    systemDateTime.getTimezone().then((timeZoneId) => {
      let timeZone = i18n.getTimeZone(timeZoneId);
      stateStr = `${TimeZoneUtil.getRawOffsetSummary(timeZone, true)} ${
      timeZone.getDisplayName(new intl.Locale(i18n.System.getSystemLanguage())?.toString())}`;
      LogUtil.info(`${TAG} getTimezone, timeZoneId: ${timeZoneId}, stateStr: ${stateStr}`);
      this.addChildren([menu(stateStr)]);
      this.removeChildren(KEY_TIME_ZONE_SETTINGS);
      this.refreshUi();
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get timezone failed: ${error.message}`);
    });
  }
}
