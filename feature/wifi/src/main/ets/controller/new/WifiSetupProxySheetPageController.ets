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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingSheetPageContext } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';

/* instrument ignore file */
const TAG: string = 'WifiSetupProxySheetPageController : ';
const PROXY_INFO_SAVED: string = 'PROXY_INFO_SAVED';

export class WifiSetupProxySheetPageController implements ComponentControl {
  public param?: CompCtrlParam;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  private sheetPageCtx?: SettingSheetPageContext;
  private wifiProxyGroupId: string = `${PageRouter.getRouterName()}.wifi_setup_proxy_config.proxy_input_group`;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.param) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.sheetPageCtx = compParam?.param as SettingSheetPageContext;
    this.wifiConfig = WifiPasswordConfigManager.getInstance().getConfig();
    if (!this.wifiConfig) {
      this.wifiConfig = AddOtherWlanConfigManager.getInstance().getConfig();
    }
    EventBus.getInstance().on(PROXY_INFO_SAVED, () => {
      this.sheetPageCtx?.pathStack?.pop();
    });
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().off(PROXY_INFO_SAVED);
  }

  onManualProxyChecked(isCheck: boolean): void {
    this.showOrHideGroup(isCheck);
    if (!this.wifiConfig?.proxyConfig) {
      LogUtil.error(`${TAG} onManualProxyChecked failed.`);
      return;
    }
    this.wifiConfig.proxyConfig.proxyMethod =
      isCheck ? wifiManager.ProxyMethod.METHOD_MANUAL : wifiManager.ProxyMethod.METHOD_NONE;
    EventBus.getInstance().emit('WLAN_PROXY_INPUT_CHANGE');
    // 刷新上一个界面代理菜单result值
    let id: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_config_ip_group.wifi_setup_proxy_entry`;
    if (AddOtherWlanConfigManager.getInstance().getConfig()) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_config_ip_group.wifi_setup_proxy_entry`;
    }
    notifyCompStateChange(id,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: isCheck ? $r('app.string.wifi_proxy_settings_manual') : $r('app.string.wifi_proxy_settings_none'),
          }
        } as SettingResultState]]));
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideGroup: ${isShow}, id: ${this.wifiProxyGroupId}`);
    notifyCompStateChange(this.wifiProxyGroupId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
    notifyCompStateChange(`${this.wifiProxyGroupId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }
}