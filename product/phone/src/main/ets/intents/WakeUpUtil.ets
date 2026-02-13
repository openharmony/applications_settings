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

import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const SETTING_WAKE_CLICK: string = 'settings.power.wakeup_double_click';
const SETTING_WAKE_PICK_UP: string = 'settings.power.wakeup_pick_up';
const STATE_ON: string = '1';
const STATE_OFF: string = '0';

const TAG: string = 'WakeUpUtil : ';

/**
 * 亮屏-双击亮屏-开关选择
 *
 * @since 2024-04-14
 */
export class WakeUpUtil {
  /**
   * 返回抬手开关的实时状态
   */
  static isPickUpEnabled(): boolean {
    let pickup: boolean = SettingsDataUtils.getSettingsData(SETTING_WAKE_PICK_UP, STATE_OFF) == STATE_ON
    return pickup;
  }

  /**
   * 使能抬手开关的状态
   */
  static enablePickUp(): boolean {
    SettingsDataUtils.setSettingsData(SETTING_WAKE_PICK_UP, STATE_ON);
    return true;
  }

  /**
   * 关闭抬手开关的状态
   */
  static disablePickUp(): boolean {
    SettingsDataUtils.setSettingsData(SETTING_WAKE_PICK_UP, STATE_OFF);
    return true;
  }

  /**
   * 返回抬手开关的实时状态
   */
  static isClickEnabled(): boolean {
    let click: boolean = SettingsDataUtils.getSettingsData(SETTING_WAKE_CLICK, STATE_OFF) == STATE_ON
    return click;
  }

  /**
   * 使能双击开关的状态
   */
  static enableClick(): boolean {
    SettingsDataUtils.setSettingsData(SETTING_WAKE_CLICK, STATE_ON);
    return true;
  }

  /**
   * 关闭双击开关的状态
   */
  static disableClick(): boolean {
    SettingsDataUtils.setSettingsData(SETTING_WAKE_CLICK, STATE_OFF);
    return true;
  }
}