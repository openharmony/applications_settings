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

const TOGGLE_KEY: string = 'Setting.enhance_netmanager.concurrent_acc_group.enable_smart_cloud_acc';
const INTELLIGENCE_CLOUD_SWITCH_ENABLE: string = 'intelligence_cloud_switch_enable';

export class IntelligenceCloudController implements ComponentControl {
  private readonly tag: string = 'IntelligenceCloudController : ';
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
    this.updateCheckedState();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  protected updateCheckedState(): boolean {
    let value: string = SettingsDataUtils.getSettingsData(INTELLIGENCE_CLOUD_SWITCH_ENABLE, '0');
    this.isSwitchOn = value === '1' ? true : false;
    return this.isSwitchOn;
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange isChecked:${isChecked}`);
    if (isChecked && !this.isSwitchOn) {
      SettingsDataUtils.setSettingsData(INTELLIGENCE_CLOUD_SWITCH_ENABLE, '1');
    }
    if (!isChecked && this.isSwitchOn) {
      SettingsDataUtils.setSettingsData(INTELLIGENCE_CLOUD_SWITCH_ENABLE, '0');
    }
    this.isSwitchOn = isChecked;
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
      SettingsDataUtils.registerDataChange(this.dataHelper, INTELLIGENCE_CLOUD_SWITCH_ENABLE, this.onDataChange)
    } else {
      (SettingsDataUtils.createDataHelper(INTELLIGENCE_CLOUD_SWITCH_ENABLE) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, INTELLIGENCE_CLOUD_SWITCH_ENABLE, this.onDataChange);
          }
        })
    }
  }

  protected unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper,
      INTELLIGENCE_CLOUD_SWITCH_ENABLE)
  }
}