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

import wifiManager from '@ohos.wifiManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { WifiUtils } from '../../WifiUtils';

/* instrument ignore file */
const TAG: string = 'WifiAutoReConnectController';

export class WifiAutoReConnectController implements ComponentControl {
  private config: wifiManager.WifiDeviceConfig | undefined;
  private compId: string = '';
  private onToggleChange = (state: SettingToggleState) => {
    if (!this.config) {
      LogUtil.warn(`${TAG} config is undefined, skip auto connect setting`);
      return;
    }
    let wifiConfig = WifiUtils.getConfig(this.config.ssid, this.config.securityType) as wifiManager.WifiDeviceConfig;
    let netId = wifiConfig?.netId;
    if (!wifiConfig || netId === undefined) {
      LogUtil.warn(`${TAG} wifiConfig or netId is missing`);
      return;
    }
    LogUtil.info(`${TAG} onToggleChange-state: ${state.state},netId:${netId}`);
    try {
      wifiManager.allowAutoConnect(netId, state.state);
      LogUtil.info(`${TAG} Auto connect setting updated successfully`);
    } catch (e) {
      LogUtil.error(`${TAG} onToggleChange ${e.code}`);
    }
  }

  constructor(config: wifiManager.WifiDeviceConfig | undefined) {
    this.config = config;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
    LogUtil.info(`${TAG} init, end`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.onToggleChange);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}