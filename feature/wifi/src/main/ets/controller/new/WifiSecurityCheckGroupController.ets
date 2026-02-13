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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { WLAN_SWITCH_ID } from '../../model/WifiModel';
import { WifiSecuritySwitchController } from './WifiSecuritySwitchController';
import { WifiMenuManager } from '../../WifiMenuManager';

const TAG: string = 'WifiSecurityCheckGroupController : ';

export class WifiSecurityCheckGroupController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    let isInOObeStage: boolean = WifiMenuManager.isInOObeStage();
    // wlan开关状态发生变化后，显示或者隐藏添加其他wlan菜单
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: toggleState.state && !isInOObeStage } as SettingCompState]]));
    notifyCompStateChange(`${this.compId}.footer`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: toggleState.state && !isInOObeStage } as SettingCompState]]
    ));
  };

  init(param: CompCtrlParam): void {
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.compId = param.compId;
    this.dataSource = param.dataSource as DynamicDataSource;
    // 注册wlan开关变化监听
    EventBus.getInstance().on(WLAN_SWITCH_ID, this.onToggleChangeCallback);
    // this.dataSource.pushData(this.createWifiSecurityCheck());
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(WLAN_SWITCH_ID, this.onToggleChangeCallback);
  }

  private createWifiSecurityCheck(): SettingItemModel {
    return {
      id: 'WlanSecurityChecks',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.wlan_security_title') },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: true },
      },
      compControl: new WifiSecuritySwitchController(),
    };
  }
}