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
import { dataShare } from '@kit.ArkData';
import config from '@ohos.accessibility.config';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED } from '../constant/Constants';
import { a11yInitData } from '../sendable/A11yInitData';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  DISPLAY_DALTONIZER_ENABLED,
} from '../constant/Constants';

const TAG: string = 'ColorFilterSwitchController : ';
const COLOR_FILTER_SWITCH_ON: string = '1';
const COLOR_FILTER_SWITCH_OFF: string = '0';

/**
 * 色彩校正开关控制器
 *
 * @since 2024-08-18
 */
export class ColorFilterSwitchController implements ComponentControl {
  public daltonizationState: boolean = false;
  protected dataHelper?: dataShare.DataShareHelper;
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
  private configObserver = (data: boolean): void => {
    if (this.daltonizationState !== data) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.DALTONIZATION_SWITCH, data ? 'on' : 'off');
      this.daltonizationState = data;
      a11yInitData.daltonizationState = data;
      LogUtil.info(`${TAG} daltonizationState state change:${data}`);
      this.setColorFilterEnableState(data);
      this.refreshUi(this.daltonizationState);
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    let result: boolean = false;
    result = SettingsDataUtils.getSecureValue(DISPLAY_DALTONIZER_ENABLED, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} reload daltonizationState success:${result}`);
    this.daltonizationState = result;
    a11yInitData.daltonizationState = result;
    this.setColorFilterEnableState(this.daltonizationState);
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    AccessibilitySettingModel.accessibilityConfigSetting('colorFilter', isChecked);
    return true;
  }

  private setColorFilterEnableState(data: boolean): void {
    if (data) {
      SettingsDataUtils.setSettingsData(ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED, COLOR_FILTER_SWITCH_ON);
    } else {
      SettingsDataUtils.setSettingsData(ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED, COLOR_FILTER_SWITCH_OFF);
    }
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.daltonizationState.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe daltonizationState, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.daltonizationState.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe daltonizationState, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.daltonizationState}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi(this.daltonizationState);
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(isEnabled: boolean): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state: isEnabled }
        } as SettingResultState]]));
  }
}
