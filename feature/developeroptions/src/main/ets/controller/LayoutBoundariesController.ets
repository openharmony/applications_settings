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

import systemParameter from '@ohos.systemparameter';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { BusinessError } from '@ohos.base';

const DISPLAY_LAYOUT_BOUNDARIES_SWITCH: string = 'display_layout_boundaried_switch';
const TAG: string = 'LayoutBoundariesController : ';

export class LayoutBoundariesController extends SwitchMenuController {
  static CreateLayoutBoundariesController(menu: SettingsBaseMenu): Controller {
    return new LayoutBoundariesController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  protected updateCheckedState(): boolean {
    // 获取当前系统设置中的debug布局边界状态
    let state: string = systemParameter.getSync('persist.ace.debug.boundary.enabled');
    LogUtil.info(`${TAG} getCurrentBoundaryState : ${state}`);

    if (state) {
      return state === 'true';
    } else {
      return false;
    }
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} enter handleCheckedChange...`);

    if (isChecked) {
      this.enableDebugBoundary();
    } else {
      this.disableDebugBoundary();
    }
    return true;
  }

  private enableDebugBoundary(): void {
    LogUtil.info(`${TAG} enable debug boundary`);

    systemParameter.set('persist.ace.debug.boundary.enabled', 'true').then(() => {
      LogUtil.info(`${TAG} enable debug boundary success`);
      this.refreshUi();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} enable debug boundary failed, err: ${err}`);
    });

    HiSysEventUtil.reportSwitchEvent(DISPLAY_LAYOUT_BOUNDARIES_SWITCH, 'on');
  }

  private disableDebugBoundary(): void {
    LogUtil.info(`${TAG} disable debug boundary`);

    systemParameter.set('persist.ace.debug.boundary.enabled', 'false').then(() => {
      LogUtil.info(`${TAG} disable boundary success `);
      this.refreshUi();
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} disable debug boundary failed, err: ${err}`);
    });

    HiSysEventUtil.reportSwitchEvent(DISPLAY_LAYOUT_BOUNDARIES_SWITCH, 'off');
  }
}
