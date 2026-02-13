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

import {
  SwitchMenuController,
  LogUtil,
  SettingsBaseMenu,
  Controller,
  SettingsDataUtils
} from '@ohos/settings.common';
import settings from '@ohos.settings';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';

/* instrument ignore file */
const TAG: string = 'ShowWLANLogsController : ';
const CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH: string = 'change_settings_input_show_touch_switch';
const SETTINGS_SWITCH_WLAN_LOGS: string = 'settings.switch_wlan_logs';

/*
 * 显示WLAN详细日志开关控制器
 */

export class ShowWLANLogsController extends SwitchMenuController {
  static CreateShowWLANLogsController(menu: SettingsBaseMenu): Controller {
    return new ShowWLANLogsController(menu);
  }


  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  /*
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    // 获取当前系统设置中的WLAN详细日志开关的状态,默认false
    let value = SettingsDataUtils.getSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false');
    LogUtil.info(`${TAG} getCurrentShowTouchState : ${value}`);
    return value === 'true';
  }

  /*
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}` );
    if (isChecked) {
      SettingsDataUtils.setSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'true');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH, 'on');
    } else {
      SettingsDataUtils.setSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH, 'off');
    }
    return true;
  }
}
