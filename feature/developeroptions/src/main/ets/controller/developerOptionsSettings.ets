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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';

const AUTOMATIC_SYSTEM_UPDATE_KEY: string = 'ota_disable_automatic_update';
const CHANGE_AUTO_UPDATE_SWITCH: string = 'change_auto_update_switch';

/**
 * 自动系统更新开关控制器
 *
 * @since 2023-03-08
 */
export class DeveloperOptionsSettings extends SwitchMenuController {
  public tag: string = 'DeveloperOptionsSettings : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateDeveloperOptionsSettings(menu: SettingsBaseMenu): Controller {
    return new DeveloperOptionsSettings(menu);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    // 1 表示打开， 0 为关闭
    return SettingsDataUtils.getSettingsData(AUTOMATIC_SYSTEM_UPDATE_KEY,
      '1') === '1';
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag}handleCheckedChange isChecked:${isChecked}`);
    // 1 表示开启， 0 为关闭
    if (isChecked) {
      HiSysEventUtil.reportSwitchEvent(CHANGE_AUTO_UPDATE_SWITCH, 'on');
    } else {
      HiSysEventUtil.reportSwitchEvent(CHANGE_AUTO_UPDATE_SWITCH, 'off');
    }
    return true;
  }
}
