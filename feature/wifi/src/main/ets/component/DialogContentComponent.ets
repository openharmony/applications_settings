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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SharedNetworkModel } from '../model/SharedNetworkModel';
import { WifiUtils } from '../WifiUtils';

export const OPERATOR_DISCONNECT: number = 1;
export const OPERATOR_CONNECT_FAILED: number = 2;

export enum ErrorResult {
  SUCCESS = 0,
  ERR_NO_RESOURCE = 1,
  ERR_BUS_FAILURE = 2,
  ERR_ACTIVATION_FAILURE = 3,
  ERR_ROUTE_FAILURE = 4,
  NETWORK_ERROR_FAILED_MSG = 100,
  NETWORK_ERROR_DATA_NOT_ENABLED = 200,
  NETWORK_ERROR_SUB_SWITCH_OFF = 210,
  NETWORK_ERROR_UNAVAILABLE = 220,
};

@Component
export struct DialogContentComponent{
  tag: string = 'SharedNetworkDialogContentComponent: ';
  item?: SettingItemModel;
  content: ResourceStr = '';

  build() {
    Column() {
      Text(this.content)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
    }
    .id('DialogContentComponent_column')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear(): void {
    let sharedNetworkModel: SharedNetworkModel = this.item as SharedNetworkModel;
    LogUtil.info(`${this.tag} aboutToAppear deviceName:${sharedNetworkModel.deviceName ?? ''},
    operator:${sharedNetworkModel.operator ?? ''}, ${sharedNetworkModel.connectedDeviceName ?? ''}`);
    if (sharedNetworkModel.operator === OPERATOR_DISCONNECT) {
      let replaceDeviceName: string = sharedNetworkModel.deviceName ?? '';
      this.content = ResourceUtil.getFormatStringSync($r('app.string.shared_network_disconnect_message'), replaceDeviceName);
    }
    if (sharedNetworkModel.operator === OPERATOR_CONNECT_FAILED) {
      let errorResult = sharedNetworkModel.errorResult;
      LogUtil.info(`${this.tag} Shared_Network failed dialog, errorResult=${errorResult}`);
      let errorMessages = new Map<ErrorResult, Resource>([
        [ErrorResult.NETWORK_ERROR_FAILED_MSG, $r('app.string.ensure_mobile_data_enabled')],
        [ErrorResult.NETWORK_ERROR_DATA_NOT_ENABLED, $r('app.string.mobile_data_not_enabled')],
        [ErrorResult.NETWORK_ERROR_SUB_SWITCH_OFF, $r('app.string.network_sharing_sub_switch_not_enabled')],
        [ErrorResult.NETWORK_ERROR_UNAVAILABLE, $r('app.string.mobile_network_unavailable')]
      ]);
      let errorMsgKey = errorMessages.get(errorResult)|| $r('app.string.ensure_mobile_data_enabled');
      LogUtil.info(`${this.tag} errorMsgKey: ${errorMsgKey}`);
      this.content = ResourceUtil.getStringSync(errorMsgKey);
    }
    sharedNetworkModel.connectedDeviceName = '';
  }

  onPageShow(): void {
    LogUtil.info(`${this.tag} DialogContentComponent onPageShow`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} DialogContentComponent aboutToDisappear`);
  }
}