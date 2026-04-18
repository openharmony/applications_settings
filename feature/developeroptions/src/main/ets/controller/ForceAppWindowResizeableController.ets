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
import { BusinessError } from '@ohos.base';
import systemParameter from '@ohos.systemparameter';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';

const TAG: string = 'ForceResizableAppInterfacesController : ';
const FORCE_RESIZABLE_APP_INTERFACES_SWITCH: string = 'force_resizable_app_interfaces_switch';
const MULTI_WINDOW_DEBUG_PARAM_KEY = 'persist.debug.multi_window';

export class ForceResizableAppInterfacesController extends SwitchMenuController {
  static CreateForceResizableAppInterfacesController(menu: SettingsBaseMenu): Controller {
    return new ForceResizableAppInterfacesController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  protected updateCheckedState(): boolean {
    // 获取当前系统设置中的多窗 debug 状态
    let state: string = SystemParamUtils.getSystemParam(MULTI_WINDOW_DEBUG_PARAM_KEY, 'false');
    LogUtil.info(`${TAG} getCurrentForceResizableAppInterfacesState : ${state}`);

    if (state) {
      return state === 'true';
    } else {
      return false;
    }
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} enter handleCheckedChange...`);

    if (isChecked) {
      this.enableForceAppWindowResizeable();
    } else {
      this.disableForceAppWindowResizeable();
    }
    return true;
  }

  private enableForceAppWindowResizeable(): void {
    LogUtil.info(`${TAG} enable force resizable app interfaces`);

    systemParameter.set(MULTI_WINDOW_DEBUG_PARAM_KEY, 'true').then(() => {
      LogUtil.info(`${TAG} enable force resizable app interfaces success`);
      this.refreshUi();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} enable force resizable app interfaces failed, err: ${err}`);
    });
  }

  private disableForceAppWindowResizeable(): void {
    LogUtil.info(`${TAG} disable force resizable app interfaces`);

    systemParameter.set(MULTI_WINDOW_DEBUG_PARAM_KEY, 'false').then(() => {
      LogUtil.info(`${TAG} disable force resizable app interfaces success `);
      this.refreshUi();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} disable force resizable app interfaces failed, err: ${err}`);
    });
  }
}
