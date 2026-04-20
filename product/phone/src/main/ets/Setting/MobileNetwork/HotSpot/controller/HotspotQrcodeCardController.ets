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
import CommonEventManager from '@ohos.commonEventManager';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { QrcodeComponent } from '../view/QrcodeComponent';
/* instrument ignore file */
@Builder
function qrCodeBuilder(param: object) {
  QrcodeComponent();
}

const TAG: string = 'HotspotQrcodeCardController';

export class HotspotQrcodeCardController implements ComponentControl {
  private isHotspotOpen: boolean = false;
  private dataSource?: OrderedDataSource;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE,
    ]
  };
  private apConnected: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    this.updateStatus();
  });

  private updateHotspotState(): void {
    try {
      this.isHotspotOpen = wifiManager.isHotspotActive();
      LogUtil.info(`${TAG} isHotspotActive: ${this.isHotspotOpen}`);
    } catch (error) {
      LogUtil.error(`${TAG} get isHotspotActive fail, ${error?.message}}`);
    }
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.dataSource = (compParam.dataSource) as OrderedDataSource;
    this.apConnected.registerCommonEvent();
    this.updateStatus();
    this.dataSource.push({
      id: 'qr_code',
      type: ItemType.ITEM_TYPE_CUSTOM,
      builder: wrapBuilder(qrCodeBuilder),
    })
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.apConnected.unRegisterCommonEvent();
  }

  updateStatus(): void {
    this.updateHotspotState();
    notifyCompStateChange('Setting.hotspot_data_entry.qr_code_group',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: this.isHotspotOpen,
      } as SettingCompState]]
      ));
  }
}