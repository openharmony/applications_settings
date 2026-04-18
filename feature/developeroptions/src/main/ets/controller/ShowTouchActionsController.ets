
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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

/*
 * 显示触摸操作开关控制器
 */

const TAG: string = 'ShowTouchActionsController : ';
const CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH: string = 'change_settings_input_show_touch_switch';
const SETTINGS_INPUT_SHOW_TOUCH_HINT: string = 'settings.input.show_touch_hint';

export class ShowTouchActionsController extends SwitchMenuController {
  static CreateShowTouchActionController(menu: SettingsBaseMenu): Controller {
    return new ShowTouchActionsController(menu);
  }


  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${TAG} aboutToAppear`);
    SettingsDataUtils.registerKeyObserver(SETTINGS_INPUT_SHOW_TOUCH_HINT, (err, value) => {
      this.setChecked(this.updateCheckedState());
    });
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    LogUtil.info(`${TAG} aboutToDisappear`);
    SettingsDataUtils.unregisterKeyObserver(SETTINGS_INPUT_SHOW_TOUCH_HINT);
  }

  /*
   * 返回开关的实时状态
   * */
  protected updateCheckedState(): boolean {
    //获取当前系统设置中的显示触摸开关的状态,默认false
    let value = SettingsDataUtils.getSettingsData(SETTINGS_INPUT_SHOW_TOUCH_HINT, 'false');
    LogUtil.info(`${TAG} getCurrentShowTouchState : ${value}`);

    return value === 'true';
  }

  /*
 * 开关变化的回调
  * */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}` );

    if (isChecked) {
      SettingsDataUtils.setSettingsData(SETTINGS_INPUT_SHOW_TOUCH_HINT, 'true');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH, 'on');
    } else {
      SettingsDataUtils.setSettingsData(SETTINGS_INPUT_SHOW_TOUCH_HINT, 'false');
      HiSysEventUtil.reportSwitchEvent(CHANGE_SETTINGS_INPUT_SHOW_TOUCH_SWITCH, 'off');
    }
    return true;
  }
}
