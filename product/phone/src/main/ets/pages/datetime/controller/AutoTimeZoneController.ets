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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { BusinessError } from '@ohos.base';
import systemParameter from '@ohos.systemparameter';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import emitter from '@ohos.events.emitter';
import { AUTO_SET_UPDATE_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import { EventId } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DISABLE_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
/* instrument ignore file */
const KEY_AUTO_TIMEZONE: string = 'auto_timezone';
const KEY_AUTO_TIME: string = 'auto_time';
const SWITCH_ON: string = '1';
const SWITCH_OFF : string = '0';
const TAG: string = 'AutoTimeZoneController: ';

/**
 * 自动时区开关控制器
 *
 */
@Observed
export default class AutoTimeZoneController extends SwitchMenuController {
  static ControlAutoTimeZoneController(menu: SettingsBaseMenu): Controller {
    return new AutoTimeZoneController(menu);
  }

  private isDisabledAutoTimeZoneSwitch: boolean = false;

  aboutToAppear(): void {
    this.updateStatus();
    this.menu?.addControllerToPage(this.getKey(), this);
    LogUtil.showInfo(TAG, `aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, `aboutToDisappear`);
  }

  public onMenuClick(): boolean {
    if (this.isDisabledAutoTimeZoneSwitch) {
      ToastUtil.handleMultiToast(ResourceUtil
        .getStringSync($r('app.string.reset_factory_disabled_toast')), ToastUtil.SHORT_DURATION);
    }
    return true;
  }

  public setAutoTimeZoneSwitchState(isDisabledSwitch: boolean): void {
    this.isDisabledAutoTimeZoneSwitch = isDisabledSwitch;
    if (this.isDisabledAutoTimeZoneSwitch) {
      this.menu.opacity = DISABLE_OPACITY;
      this.setToggleState(false);
      if (!this.updateCheckedState()) {
        this.setChecked(true);
      }
    } else {
      this.menu.opacity = undefined;
      this.setToggleState(true);
    }
  }

  /**
   * 处理开关变化
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.AUTO_SETTING_SWITCH, isChecked ?
      'on' : 'off');
    SettingsDataUtils.setSettingsData(KEY_AUTO_TIMEZONE, isChecked ? SWITCH_ON : SWITCH_OFF);
    SettingsDataUtils.setSettingsData(KEY_AUTO_TIME, isChecked ? SWITCH_ON : SWITCH_OFF);
    //报错：需要配置DAC和MAC权限
    systemParameter.set('persist.time.auto_time', isChecked ? 'ON' : 'OFF', (err: BusinessError, data: void) => {
      if (err === undefined) {
        SearchDataController.getInstance().updateSearchItemStatus('date_settings_title', !isChecked);
        SearchDataController.getInstance().updateSearchItemStatus('time_settings_title', !isChecked);
        LogUtil.showInfo(TAG, 'set test.parameter.key value success');
        this.publishDataChange(isChecked);
        this.updateStatus();
      } else {
        LogUtil.showError(TAG, `set test.parameter.key value err: ${err?.code}`);
      }
    });
    return true;
  }

  /**
   * 更新开关的实时状态
   */
  protected updateCheckedState(): boolean {
    return systemParameter.getSync('persist.time.auto_time', 'ON') === 'ON';
  }

  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    emitter.emit({
      eventId: EventId.UpdateAutoTimeZoneStateNum
    }, { data: { isChecked: isChecked } });
    emitter.emit({ eventId: AUTO_SET_UPDATE_EVENTS });
    this.refreshUi();
  }
}