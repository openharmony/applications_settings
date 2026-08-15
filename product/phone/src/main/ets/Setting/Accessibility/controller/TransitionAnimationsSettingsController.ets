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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { a11yInitData } from '../sendable/A11yInitData';
import {
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  ANIMATION_OFF_KEY,
} from '../constant/Constants';

const TAG: string = 'TransitionAnimationsSettingsController : ';

export class TransitionAnimationsSettingsController implements ComponentControl {
  public animationOffState: boolean = false;
  private compId: string = '';

  async getAccessibilityConfig(): Promise<void> {
    let animationOffState: boolean | undefined = a11yInitData.animationOffState;
    let result: boolean = SettingsDataUtils.getSecureValue(ANIMATION_OFF_KEY, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    if (animationOffState === undefined || animationOffState !== result) {
      try {
        this.animationOffState = result;
        a11yInitData.animationOffState = result;
        LogUtil.info(`${TAG} reload animationOffState success:${this.animationOffState}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload animationOffState error: ${err?.message}`);
      }
    } else {
      this.animationOffState = a11yInitData.animationOffState as boolean;
    }
  }

  private configObserver = (data: boolean): void => {
    if (data === undefined || typeof data !== 'boolean') {
      LogUtil.error(`${TAG} failed to get animationOff config value`);
      return;
    }

    if (this.animationOffState !== data) {
      this.animationOffState = data;
      LogUtil.info(`${TAG} animationOff state change:${data}`);
      a11yInitData.animationOffState = data;
      this.refreshUi();
    }
  };

  /**
   * 监听状态
   */
  protected async registerDataChange(): Promise<void> {
    LogUtil.info(`${TAG} animationOff listener registerd`);
    try {
      config.animationOff.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe animationOff, because ${err?.message}`);
    }
  }

  /**
   * 取消监听
   */
  protected async unRegisterDataChange(): Promise<void> {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.animationOff.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe animationOff, because ${err?.message}`);
    }
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
    this.registerDataChange();
  }

  destroy(): void {
    LogUtil.info(`${TAG} on destroy`);
    this.unRegisterDataChange();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private refreshUi(): void {
    let statusResult: ResourceStr =
      this.animationOffState ? $r('app.string.accessibility_off') : $r('app.string.accessibility_on');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}
