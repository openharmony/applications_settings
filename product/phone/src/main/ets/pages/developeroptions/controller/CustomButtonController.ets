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

import netQuality from '@hms.networkboost.netquality';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
export class CustomButtonController implements ComponentControl {
  public param?: CompCtrlParam;
  init(compParam: CompCtrlParam): void {
  }

  aboutToAppear(): void {
    LogUtil.info(`CustomButtonController aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`CustomButtonController aboutToDisappear`);
  }

  destroy(): void {
  }

  public onButtonClicked(scenarioId?: number): void {
    LogUtil.info(`CustomButtonController onSaveButtonClicked.`);
    this.closeSheet(scenarioId);
  }

  private closeSheet(scenarioId?: number): void {
    // 自定义的
    if (scenarioId !== undefined && scenarioId > 0) {
      notifyCompStateChange(`Setting.network_navigator_entry.EffectiveSceneGroup.${scenarioId}`,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
          {
            state: false,
          } as SettingCompState]]
        ));
      notifyCompStateChange(`Setting.network_navigator_entry.CustomSceneGroup.${scenarioId}`,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
          {
            state: false,
          } as SettingCompState]]
        ));
    } else {
      // 关闭半模态
      notifyCompStateChange('Setting.network_navigator_entry.AddCustomSceneGroup.AddCustomScene',
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
          {
            state: false,
          } as SettingCompState]]
        ));
    }
  }
}
