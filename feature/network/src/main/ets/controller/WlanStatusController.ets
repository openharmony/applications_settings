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
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { WifiState } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

const TAG: string = 'WlanStatusController:';

/**
 * 网络 WLAN 显示状态控制器类
 */
export class WlanStatusController implements ComponentControl {
  private compId: string = '';
  private isWlanSwitchOn: boolean = false;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.isWlanSwitchOn = WifiUtils.isWifiActive();
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }

  private refreshUi(): void {
    LogUtil.info(`${TAG} refreshUi : ${this.isWlanSwitchOn}`);
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.checkState() } } as SettingResultState]]));
  }

  private checkState(): ResourceStr {
    return this.isWlanSwitchOn ? $r('app.string.projection_state_on') :
    $r('app.string.projection_state_off');
  }

  private onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state} `);
    if (state === WifiState.INACTIVE) { // 关闭
      this.isWlanSwitchOn = false;
      this.refreshUi();
    } else if (state === WifiState.ACTIVE) { // 打开
      this.isWlanSwitchOn = true;
      this.refreshUi();
    } else {
      // keep current WLAN status
    }
  }
}
