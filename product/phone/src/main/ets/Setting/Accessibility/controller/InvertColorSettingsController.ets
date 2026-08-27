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

const TAG: string = 'InvertColorSettingsController : ';

export class InvertColorSettingsController implements ComponentControl {
  public invertColorState: boolean = false;
  private compId: string = '';

  async getAccessibilityConfig(): Promise<void> {
    let initializationState: boolean | undefined = a11yInitData.invertColorState;
    if (initializationState === undefined) {
      LogUtil.error(`${TAG} a11yInitData invertColorState is undefined, try reload`);
      try {
        await config.invertColor.get().then((value) => {
          if (this.invertColorState !== value) {
            LogUtil.info(`${TAG} initializationState refresh`);
            this.invertColorState = value;
            a11yInitData.invertColorState = value;
          }
        });
        LogUtil.info(`${TAG} reload invertColorState success:${this.invertColorState}`);
      } catch (err) {
        LogUtil.error(`${TAG} reload invertColorState error: ${err?.message}`);
      }
    } else {
      this.invertColorState = a11yInitData.invertColorState as boolean;
    }
  }

  private configObserver = (data: boolean): void => {
    if (data === undefined || typeof data !== 'boolean') {
      LogUtil.error(`${TAG} failed to get invertColor config value`);
      return;
    }

    if (this.invertColorState !== data) {
      this.invertColorState = data;
      LogUtil.info(`${TAG} invertColor state change:${data}`);
      a11yInitData.invertColorState = data;
      this.refreshUi();
    }
  };

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
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
      this.invertColorState ? $r('app.string.accessibility_on') : $r('app.string.accessibility_off');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: statusResult } } as SettingResultState]]));
  }
}
