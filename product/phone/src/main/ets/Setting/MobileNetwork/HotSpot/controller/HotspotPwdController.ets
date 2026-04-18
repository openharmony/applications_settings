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

import { window } from '@kit.ArkUI';
import wifiManager from '@ohos.wifiManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG: string = 'HotspotPwdController';

export class HotspotPwdController implements ComponentControl {
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.updateStatus();
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
      true);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
      false);
  }

  updateStatus(): void {
    try {
      let config: wifiManager.HotspotConfig = wifiManager.getHotspotConfig();
      notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingResultState>(
        [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: config.preSharedKey
          },
        } as SettingResultState]]
      ));
    } catch (error) {
      LogUtil.error(`${TAG} getHotspotConfig fail, ${error?.message}`);
    }
  }
}