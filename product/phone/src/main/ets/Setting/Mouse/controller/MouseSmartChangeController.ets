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

/* instrument ignore file */
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { MouseConstants } from '../utils/Constants';
import { Utils } from '../utils/Utils';
import { HiSysMouseEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

export class MouseSmartChangeController implements ComponentControl {
  private tag: string = 'MouseSmartChangeController: ';
  private compId?: string;
  private isChecked: boolean = Utils.getSmartChangeState();
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
    this.refreshUi();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.compId = compParam?.compId;
    this.getChecked();
    this.refreshUi();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  destroy(): void {
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }

  private handleCheckedChange(isChecked: boolean): void {
    LogUtil.info(`${this.tag} handleCheckedChange isChecked:  ${isChecked}`);
    this.isChecked = isChecked;
    SettingsDataUtils.setSettingsData(MouseConstants.MOUSE_MAGIC_VARIABLE, isChecked ? 'true' : 'false');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMouseEventGroup.MOUSE_VARIABLE_CHANGE, isChecked.toString());
  }

  private getChecked(): void {
    this.isChecked = Utils.getSmartChangeState();
  }

  private refreshUi(): void {
    this.getChecked();
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: this.isChecked } as SettingToggleState
      } as SettingResultState]]
    ));
  }
}