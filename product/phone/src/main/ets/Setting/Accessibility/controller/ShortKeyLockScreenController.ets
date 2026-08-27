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

import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CompCtrlParam, ComponentControl, } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  HiSysAccessibilityEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import dataShare from '@ohos.data.dataShare';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CLICK_SWITCH_OFF, CLICK_SWITCH_ON, SHORTCUT_ENABLED_ON_LOCK_SCREEN } from '../constant/Constants';
/* instrument ignore file */
const TAG: string = 'ShortKeyLockScreenController : ';

export class ShortKeyLockScreenController implements ComponentControl {
  public shortKeyOnLockScreenState: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
  private static switchState: boolean = true;
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`)
    this.handleCheckedChange(isChecked);
  };

  async getAccessibilityConfig(): Promise<void> {
    this.shortKeyOnLockScreenState =
      SettingsDataUtils.getSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} get invertColorState success:${this.shortKeyOnLockScreenState}`);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (isChecked) {
      SettingsDataUtils.setSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, CLICK_SWITCH_ON);
    } else {
      SettingsDataUtils.setSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, CLICK_SWITCH_OFF);
    }
    if (ShortKeyLockScreenController.switchState || isChecked) {
      ShortKeyLockScreenController.switchState = true;
    }
    return true;
  }

  /**
   * 返回开关的实时状态
   */
  updateStatus(): void {
    let status: boolean =
      SettingsDataUtils.getSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.shortKeyOnLockScreenState = status;
    ShortKeyLockScreenController.switchState = status;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.SHORTKEY_LOCK_SCREEN_SWITCH, status ? 'on' : 'off');
    this.refreshUi();
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }

  protected registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SHORTCUT_ENABLED_ON_LOCK_SCREEN,
        this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SHORTCUT_ENABLED_ON_LOCK_SCREEN) as Promise<dataShare.DataShareHelper>).then(
        (dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerSecurityDataChange(this.dataHelper, SHORTCUT_ENABLED_ON_LOCK_SCREEN,
              this.onDataChange);
          }
        })
    }
    LogUtil.info(`{TAG} Screen reader key listener registerd`);
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper as dataShare.DataShareHelper,
      SHORTCUT_ENABLED_ON_LOCK_SCREEN);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
  }

  async onPageShow(): Promise<void> {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: this.shortKeyOnLockScreenState }
        } as SettingResultState]]));
  }
}
