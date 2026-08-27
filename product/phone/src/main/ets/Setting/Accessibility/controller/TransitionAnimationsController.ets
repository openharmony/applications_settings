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

import config from '@ohos.accessibility.config';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
  SettingBaseState,
  SettingCompState,
  SettingDialogState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { a11yInitData } from '../sendable/A11yInitData';
import { AccessibilityCommonModel } from '../utils/AccessibilityCommonModel';
import { TransitionAnimationsDialogContentComponent } from '../view/TransitionAnimationsDialogContentComponent';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  ANIMATION_OFF_KEY,
} from '../constant/Constants';

/* instrument ignore file */
const TAG: string = 'TransitionAnimationsController : ';
const TRANSITION_ANIMATIONS_DIALOG_EVENT: string = 'accessibilityTransitionAnimationsdialogEvent';

@Builder
export function transitionAnimationsDialogContentBuilder(param: SettingItemModel) {
  TransitionAnimationsDialogContentComponent();
}

export class TransitionAnimationsController implements ComponentControl {
  private compId: string = '';
  public animationOffState: boolean = false;
  private isEnableRetail: boolean = false;
  private isHandledDialog: boolean = false;
  private datashareChange: boolean = false;
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`);
    // 由于数据库变化，刷新页面导致的toggle回调不处理
    if (!this.datashareChange) {
      this.handleCheckedChange(isChecked);
      if (toggleState.state) {
        HiSysEventUtil.reportDefaultBehaviorEventByUE(
          HiSysAccessibilityEventGroup.TRANSITION_ANIMATIONS_STATE, 'on');
      }
    }
    this.datashareChange = false;
  };

  private configObserver = (data: boolean): void => {
    LogUtil.info(`${TAG} on animationOffState changed isChecked: ${data}`);
    if (data !== this.animationOffState) {
      this.animationOffState = data;
      a11yInitData.animationOffState = data;
      this.datashareChange = true;
      this.refreshUi();
    }
  };

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    if (!isChecked) {
      this.operConfirmDialog();
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('animationOff', !isChecked);
      this.animationOffState = !isChecked;
    }
    return true;
  }

  private closeDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingBaseState]]
    ));
  }

  private operConfirmDialog(): void {
    notifyCompStateChange(`${this.compId}`, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(transitionAnimationsDialogContentBuilder),
        style: {
          contentButtonSpace: PADDING_0,
          padding: { top: PADDING_0, start: PADDING_0, end: PADDING_0, bottom: PADDING_0 }
        },
        onWillDismiss: () => {
          if (!this.isHandledDialog) {
            AccessibilitySettingModel.accessibilityConfigSetting('animationOff', false);
            this.animationOffState = false;
            HiSysEventUtil.reportDefaultBehaviorEventByUE(
              HiSysAccessibilityEventGroup.TRANSITION_ANIMATIONS_STATE, 'on');
          }
          this.isHandledDialog = false;
          this.refreshUi();
        }
      } as SettingDialogState]]
    ));
  }

  private registerConfigObserver() {
    config.animationOff.on(this.configObserver);
  }

  async getAccessibilityConfig(): Promise<void> {
    let result: boolean = false;
    result = SettingsDataUtils.getSecureValue(ANIMATION_OFF_KEY, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} reload animationOffState success:${result}`);
    this.animationOffState = result;
    a11yInitData.animationOffState = result;
    this.refreshUi();
  }

  private dialogEventCallback = (compId: string, action: string) => {
    LogUtil.info(`${TAG} dialogEventCallback action: ${action}`);
    this.isHandledDialog = true;
    if (action === 'confirm') {
      AccessibilitySettingModel.accessibilityConfigSetting('animationOff', true);
      this.animationOffState = true;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.TRANSITION_ANIMATIONS_STATE, 'off');
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('animationOff', false);
      this.animationOffState = false;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.TRANSITION_ANIMATIONS_STATE, 'on');
    }
    this.refreshUi();
    this.closeDialog();
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.animationOffState}`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    await this.getAccessibilityConfig();
    this.registerConfigObserver();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().on(TRANSITION_ANIMATIONS_DIALOG_EVENT, this.dialogEventCallback);
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    EventBus.getInstance().detach(TRANSITION_ANIMATIONS_DIALOG_EVENT, this.dialogEventCallback);
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
        {
          type: ItemResultType.RESULT_TYPE_TOGGLE,
          result: { state:  !this.animationOffState }
        } as SettingResultState]]));
  }
}
