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
import hgmnapi from '@ohos.libhgmnapi.z.so';


/*
 * 实时显示帧率开关控制器
 * */

const TAG: string = 'RealTimeRefreshFrameRateController : ';
const ENABLED_STATUS_VALUE: number = 1;
const CHANGE_DISPLAY_REFRESH_FREQUENCY_SWITCH: string = 'change_display_refresh_frequency_switch';

export class RealTimeRefreshFrameRateController extends SwitchMenuController {
  static CreateRealTimeRefreshRateController(menu: SettingsBaseMenu): Controller {
    return new RealTimeRefreshFrameRateController(menu);
  }

  /*
   * 返回开关的实时状态
   * */
  protected updateCheckedState(): boolean {
    try {
      //获取当前设置中 显示刷新频率的状态
      let state: number = hgmnapi.getShowRefreshRateEnabled();
      LogUtil.info(`${TAG} getShowRefreshRateState : ${state}`);
      return state === ENABLED_STATUS_VALUE;
    } catch (err) {
      LogUtil.error(`${TAG} listen to updateCheckedStateChange catch, err->${err?.message}`);
    }
    return false;
  }

  /*
  * 开关变化的回调
   * */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);

    try {
      hgmnapi.setShowRefreshRateEnabled(isChecked);
    } catch (err) {
      LogUtil.error(`${TAG} listen to activeStateChange catch, err->${err?.message}`);
    }
    HiSysEventUtil.reportSwitchEvent(CHANGE_DISPLAY_REFRESH_FREQUENCY_SWITCH, isChecked ? 'on' : 'off');
    return true;
  }
}