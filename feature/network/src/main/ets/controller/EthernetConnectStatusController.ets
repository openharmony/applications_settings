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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
  SettingTextState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { Constants } from '../constant/Constants';
import { EthernetUtil } from '../util/EthernetUtil';

const TAG: string = 'EthernetConnectStatusController : ';

export class EthernetConnectStatusController implements ComponentControl {
  private compId: string = '';
  private onEthernetInternetChange = (isInternetAvailable: boolean) => {
    this.updateStatus(isInternetAvailable);
  };
  private updateStatusViewVisible = () => {
    // UX要求以太网卡片显示的时候，不显示以太网连接状态设置项
    let isShow: boolean = !EthernetUtil.isEthernetDetailViewShow();
    LogUtil.info(`${TAG} updateStatusViewVisible: ${isShow}`);
    notifyCompStateChange(`Setting.PcNetwork.pc_ethernet_status_group`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
    notifyCompStateChange(`Setting.PcNetwork.pc_ethernet_status_group.header`,
      new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
      ));
  };

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.compId = (param as CompCtrlParam).compId;
    EventBus.getInstance().on(Constants.ETHERNET_INTERNET_AVAILABLE_EVENT, this.onEthernetInternetChange);
    EventBus.getInstance().on(Constants.ETHERNET_CHANGE_EVENT, this.updateStatusViewVisible);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(Constants.ETHERNET_INTERNET_AVAILABLE_EVENT, this.onEthernetInternetChange);
    EventBus.getInstance().detach(Constants.ETHERNET_CHANGE_EVENT, this.updateStatusViewVisible);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  private updateStatus(isInternetAvailable: boolean): void {
    LogUtil.info(`${TAG} updateStatus isInternetAvailable: ${isInternetAvailable}`);
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_DESP,
        {
          content: isInternetAvailable ? $r('app.string.ethernet_status_connected') :
          $r('app.string.ethernet_status_disconnected')
        } as SettingTextState]]));
  }
}