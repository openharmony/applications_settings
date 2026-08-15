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
import config from '@ohos.accessibility.config';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { a11yInitData } from '../sendable/A11yInitData';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  COLOR_INVERT_SWITCH_STATE,
} from '../constant/Constants';

const TAG: string = 'InvertColorSwitchController : ';

export class InvertColorSwitchController implements ComponentControl {
  public invertColorState: boolean = false;
  private switchState: boolean = true;
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
    if (this.switchState === data) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.CHANGE_INVERT_COLOR_TEXT_SWITCH, data ? 'on' : 'off');
      this.switchState = !data;
    }
    if (this.invertColorState !== data) {
      this.invertColorState = data;
      LogUtil.info(`${TAG} invertColor state change:${data}`);
      a11yInitData.invertColorState = data;
      this.refreshUi();
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    let result: boolean = false;
    result = SettingsDataUtils.getSecureValue(COLOR_INVERT_SWITCH_STATE, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} reload invertColorState success:${result}`);
    if (this.invertColorState !== result) {
      LogUtil.info(`${TAG} initializationState refresh`);
      this.invertColorState = result;
      a11yInitData.invertColorState = result;
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    this.switchState = isChecked;
    AccessibilitySettingModel.accessibilityConfigSetting('invertColor', isChecked);
    return true;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    try {
      config.invertColor.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe invertColor, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.invertColor.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe invertColor, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.invertColorState}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.refreshUi();
    EventBus.getInstance().on(`${this.compId}.toggle`,
      this.toggleStateChangeEventCallback);
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`,
      this.toggleStateChangeEventCallback);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.invertColorState } } as SettingResultState]]));
  }
}
