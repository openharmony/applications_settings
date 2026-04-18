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

import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import settings from '@ohos.settings';

/*
 * 指针位置开关控制器
 */

const TAG: string = 'ShowTouchTrackController : ';
const CHANGE_SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK_SWITCH: string = 'change_settings_developer_show_touch_track_switch';
const SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK: string = 'settings.developer.show_touch_track';

export class ShowTouchTrackController extends SwitchMenuController {
  static CreateShowTouchTrackController(menu: SettingsBaseMenu): Controller {
    return new ShowTouchTrackController(menu);
  }
  private context: Context = AppStorage.get<Context>('pageContext') as Context;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  /*
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    if (!this.context) {
      LogUtil.error(`${TAG} updateCheckedState failed, context is null`);
      return false;
    }
    //获取当前系统设置中的指针位置开关的状态,默认false
    let value: string = 'false';
    try {
      value = settings.getValueSync(this.context, SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, 'false');
    } catch (e) {
      LogUtil.error(`${TAG} updateCheckedState settings getValueSync err`);
    }
    LogUtil.info(`${TAG} getCurrentShowTouchTrackState : ${value}`);
    return value === 'true';
  }

  /*
 * 开关变化的回调
  * */
  protected handleCheckedChange(isChecked: boolean): boolean {
    if (!this.context) {
      LogUtil.error(`${TAG} handleCheckedChange failed, context is null`);
      return false;
    }
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    try {
      settings.getValueSync(this.context, SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, JSON.stringify(isChecked));
      LogUtil.info(`${TAG} getShowTouchTrackChange success `);
    } catch (err) {
      LogUtil.error(`${TAG} listen to trackStateChange catch, err->${err}`);
    }
    try {
      if (isChecked) {
        settings.setValueSync(this.context, SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, 'true');
        HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK_SWITCH, 'on');
      } else {
        settings.setValueSync(this.context, SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK, 'false');
        HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_DEVELOPER_SHOW_TOUCH_TRACK_SWITCH, 'off');
      }
    } catch (e) {
      LogUtil.error(`${TAG} setSettingsData error: ${e?.code}`);
    }
    return true;
  }
}