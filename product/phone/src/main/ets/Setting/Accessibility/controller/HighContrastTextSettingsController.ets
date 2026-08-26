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
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { a11yInitData } from '../sendable/A11yInitData';

const TAG: string = 'HighContrastTextSettingsController : ';

export class HighContrastTextSettingsController implements ComponentControl {
  public highContrastTextState: boolean = false;
  private compId: string = '';

  async getAccessibilityConfig(): Promise<void> {
    let initializationState: boolean | undefined = a11yInitData.highContrastTextState;
    if (initializationState === undefined) {
      LogUtil.error(`${TAG} a11yInitData highContrastTextState is undefined, try reload`);
      try {
        await config.highContrastText.get().then((value: boolean) => {
          if (this.highContrastTextState !== value) {
            LogUtil.info(`${TAG} initializationState refresh`);
            this.highContrastTextState = value;
            a11yInitData.highContrastTextState = value;
          }
        });
        LogUtil.info(`${TAG} reload highContrastTextState success:${this.highContrastTextState}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload highContrastTextState error: ${err?.message}`);
      }
    } else {
      this.highContrastTextState = a11yInitData.highContrastTextState as boolean;
    }
  }

  private configObserver = (data: boolean): void => {
    if (this.highContrastTextState !== data) {
      this.highContrastTextState = data;
      a11yInitData.highContrastTextState = data;
      LogUtil.info(`${TAG} highContrastText state change:${data}`);
      this.refreshUi();
    }
  };

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.highContrastText.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe highContrastText, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.highContrastText.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe highContrastText, because ${err?.message}`);
    }
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.highContrastTextState}`);
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
      this.highContrastTextState ? $r('app.string.accessibility_on') : $r('app.string.accessibility_off');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}
