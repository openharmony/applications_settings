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
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
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
import { a11yInitData } from '../sendable/A11yInitData';

const TAG: string = 'SingleAudioSettingsController : ';

export class SingleAudioSettingsController implements ComponentControl {
  public audioMonoState: boolean = false;
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
  private configObserver = (data: boolean): void => {
    LogUtil.info(`${TAG} audioMono state change:${data}`);
    if (data === undefined || typeof data !== 'boolean') {
      LogUtil.error(`${TAG} failed to get audioMono config value`);
      return;
    }
    if (SingleAudioSettingsController.switchState === data) {
      SingleAudioSettingsController.switchState = !data;
    }
    if (this.audioMonoState !== data) {
      this.audioMonoState = data;
      a11yInitData.audioMonoState = data;
      this.refreshUi();
      LogUtil.info(`${TAG} audioMono state change:${data}`);
    }
  };

  async getAccessibilityConfig(): Promise<void> {
    let initializationState: boolean | undefined = a11yInitData.audioMonoState;
    if (initializationState === undefined) {
      LogUtil.error(`${TAG} a11yInitData audioMonoState is undefined, try reload`);
      try {
        await config.audioMono.get().then((value: boolean) => {
          if (this.audioMonoState !== value) {
            LogUtil.info(`${TAG} initializationState refresh`);
            this.audioMonoState = value;
            a11yInitData.audioMonoState = value;
          }
        });
        LogUtil.info(`${TAG} reload audioMonoState success:${this.audioMonoState}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload audioMonoState error: ${err?.message}`);
      }
    } else {
      this.audioMonoState = a11yInitData.audioMonoState as boolean;
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange isChecked: ${isChecked}`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.AUDIO_MONO_RADIO_CHANGE, isChecked ? 'on' : 'off');
    SingleAudioSettingsController.switchState = isChecked;
    if (isChecked) {
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', true);
    } else {
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', false);
    }
    return true;
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.audioMono.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe audioMono, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.audioMono.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe audioMono, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.audioMonoState}`);
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

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: this.audioMonoState } } as SettingResultState]]));
  }
}