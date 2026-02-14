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
import { DeveloperOptionUtils } from '../utils/DeveloperOptionsUtils';
/* instrument ignore file */
const TAG: string = 'OuterAppController : ';
const SWITCH_PARAM_NAME: string = 'debug.outer.app';
const SWITCH_ENABLE: string = 'true';
const SWITCH_DISABLE: string = 'false';
const SYS_EVENT_NAME: string = 'debug_outer_app';

export class OuterAppController extends SwitchMenuController {
  static CreateLeakDetectController(menu: SettingsBaseMenu): Controller {
    return new OuterAppController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  // 查询当前状态
  protected updateCheckedState(): boolean {
    try {
      let state: string = SettingsDataUtils.getSettingsData(SWITCH_PARAM_NAME, SWITCH_DISABLE);
      LogUtil.info(`${TAG} getCurrentState : ${state}`);
      return state === SWITCH_ENABLE;
    } catch (error) {
      LogUtil.error(`${TAG} systemParameter getSync failed, ${error?.message}`);
    }
    return false;
  }

  // 下发更新状态
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange ${isChecked}`);
    try {
      SettingsDataUtils.setSettingsData(SWITCH_PARAM_NAME, isChecked ? SWITCH_ENABLE : SWITCH_DISABLE);
      this.refreshUi();
      DeveloperOptionUtils.reportDebugOuterAppSwitchParams(isChecked ? 'on' : 'off');
      return true;
    } catch (error) {
      LogUtil.error(`${TAG} systemParameter setSync failed, ${error?.message}`);
    }
    return false;
  }
}
