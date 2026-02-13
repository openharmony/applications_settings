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
import dataShare from '@ohos.data.dataShare';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysMobileNetworkEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';

const TOGGLE_KEY: string = 'Setting.enhance_netmanager.switch_acc_group.enable_wlan_to_cell';
const INTELLIGENCE_NETWORK_SWITCHING: string = 'intelligence_network_switching';

export class IntelligenceNetworkController implements ComponentControl {
  private readonly tag: string = 'IntelligenceNetworkController : ';
  private compId: string = '';
  private dataHelper: dataShare.DataShareHelper | null = null;
  /**
   * 当前开关状态
   */
  private isSwitchOn: boolean = false;
  private onToggleChange = (state: SettingToggleState) => {
    LogUtil.info(`${this.tag} onToggleChange ${state.state}`);
    if (!this.handleCheckedChange(state.state)) {
      LogUtil.info(`${this.tag} handleCheckedChange fail`);
      return false;
    }
    return true;
  }

  public onDataChange = () => {
    this.updateStatus();
    LogUtil.info(`${this.tag} onDataChange: ${this.isSwitchOn}` );
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    if (!param) {
      LogUtil.info(`${this.tag} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    this.registerDataChange();
    this.updateStatus();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMobileNetworkEventGroup.ENTER_NETWORK_OPTIMIZATION);
    this.updateCheckedState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  protected updateCheckedState(): boolean {
    let value: string = SettingsDataUtils.getSettingsData(INTELLIGENCE_NETWORK_SWITCHING, '0');
    this.isSwitchOn = value === '1' ? true : false;
    return this.isSwitchOn;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked && !this.isSwitchOn) {
      SettingsDataUtils.setSettingsData(INTELLIGENCE_NETWORK_SWITCHING, '1');
    }
    if (!isChecked && this.isSwitchOn) {
      SettingsDataUtils.setSettingsData(INTELLIGENCE_NETWORK_SWITCHING, '0');
    }
    this.isSwitchOn = isChecked;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysMobileNetworkEventGroup.NETWORK_OPTIMIZATION_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    return true;
  }

  private updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    let isChecked = this.updateCheckedState();
    notifyCompStateChange(TOGGLE_KEY,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: {
            state: isChecked,
          },
        } as SettingResultState]]));
  }

  protected registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, INTELLIGENCE_NETWORK_SWITCHING, this.onDataChange)
    } else {
      (SettingsDataUtils.createDataHelper(INTELLIGENCE_NETWORK_SWITCHING) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, INTELLIGENCE_NETWORK_SWITCHING, this.onDataChange);
          }
        })
    }
  }

  protected unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, INTELLIGENCE_NETWORK_SWITCHING)
  }
}