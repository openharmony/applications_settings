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
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WLAN_IP_INPUT_CHANGE_EVENT } from '../../model/WifiModel';

/* instrument ignore file */
const TAG: string = 'WifiSetupIpSheetPageController : ';
const IP_INFO_SAVED: string = 'IP_INFO_SAVED';

export class WifiSetupIpSheetPageController implements ComponentControl {
  public param?: CompCtrlParam;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  private sheetPageCtx?: SettingSheetPageContext;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.param) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    let wifiConfig: wifiManager.WifiDeviceConfig | undefined = WifiPasswordConfigManager.getInstance().getConfig();
    if (wifiConfig) {
      this.wifiConfig = wifiConfig;
    } else {
      this.wifiConfig = AddOtherWlanConfigManager.getInstance().getConfig();
    }
    this.sheetPageCtx = compParam?.param as SettingSheetPageContext;
    EventBus.getInstance().on(IP_INFO_SAVED, () => {
      this.sheetPageCtx?.pathStack?.pop();
    });
  }

  onStaticIpChecked(isCheck: boolean): void {
    this.showOrHideGroup(isCheck);
    if (this.wifiConfig?.ipType === undefined) {
      LogUtil.error(`${TAG} onStaticIpChecked failed.`);
      return;
    }
    this.wifiConfig.ipType = isCheck ? wifiManager.IpType.STATIC : wifiManager.IpType.DHCP;
    EventBus.getInstance().emit(WLAN_IP_INPUT_CHANGE_EVENT);
    let id: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_config_ip_group.wifi_setup_ip_entry`;
    if (AddOtherWlanConfigManager.getInstance().getConfig()) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_config_ip_group.wifi_setup_ip_entry`;
    }
    notifyCompStateChange(id,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: isCheck ?
            $r('app.string.wifi_ip_settings_static') : $r('app.string.wifi_ip_settings_dhcp'),
          }
        } as SettingResultState]]));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().off(IP_INFO_SAVED);
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideGroup: ${isShow}`);
    notifyCompStateChange(`${PageRouter.getRouterName()}.wifi_setup_ip_config.static_ip_input_group`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }
}