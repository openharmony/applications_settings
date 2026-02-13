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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { EAP_METHOD_CHANGED_EVENT, PendingIpConfig } from '../../model/WifiModel';
import {
  EAP_PHASE2_NAME_VALUE_MAP,
  EAP_TTLS_PHASE2_NAME_VALUE_MAP,
  WIFI_EAP_SELECT_PHASE2
} from '../../WifiMenuManager';

const TAG: string = 'EapPhase2Controller : ';
const EAP_PHASE_2_KEY: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_select_phase2_section`;
const EAP_PHASE_2_MENU_KEY: string =
  `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_select_phase2_section.wifi_eap_select_phase2`;

export class EapPhase2Controller implements ComponentControl {
  public pendingIpConfig: PendingIpConfig | null = null;
  public eapConfig?: wifiManager.WifiEapConfig;
  public param?: CompCtrlParam;
  private isCurrentTTLSSelected: boolean = false;
  private onEapMethodChangeCallBack = () => {
    // eap 发生变化后，需要动态隐藏或者显示当前菜单
    let isTTLSSelected: boolean = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS;
    if (this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PEAP || isTTLSSelected) {
      this.showOrHideEapPhase2Group(true);
    } else {
      this.showOrHideEapPhase2Group(false);
    }
    if (isTTLSSelected && !this.isCurrentTTLSSelected) {
      // 刷新阶段2身份验证的items数据
      this.isCurrentTTLSSelected = true;
      this.refreshMenuData();
      return;
    }
    if (!isTTLSSelected && this.isCurrentTTLSSelected) {
      this.isCurrentTTLSSelected = false;
      this.refreshMenuData();
      return;
    }
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    /* instrument ignore if*/
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.eapConfig = config?.eapConfig;
    } else {
      this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
    }
    this.param = (param as CompCtrlParam);
    EventBus.getInstance().on(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
    (param.dataSource as DynamicDataSource)?.pushData({
      id: WIFI_EAP_SELECT_PHASE2,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.please_select_phase2'),
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_arrow_pull'),
        style: {
          width: 12,
          height: 18,
          fillColor: $r('sys.color.icon_fourth'),
        },
        menu: {
          items: [
            $r('app.string.phase2_mschapv2'),
            $r('app.string.phase2_gtc'),
            $r('app.string.phase2_sim'),
            $r('app.string.phase2_aka'),
            $r('app.string.phase2_aka_prime'),
          ],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            this.onSelected(index);
          },
          defaultFocus: 0,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.phase2_mschapv2'),
        }
      }
    })
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
  }

  onSelected(index: number): void {
    if (this.isCurrentTTLSSelected) {
      let eapPhases: ResourceStr [] = Array.from(EAP_TTLS_PHASE2_NAME_VALUE_MAP.keys());
      this.onEapEapPhase2Changed(EAP_TTLS_PHASE2_NAME_VALUE_MAP.get(eapPhases[index]) ??
      wifiManager.Phase2Method.PHASE2_MSCHAPV2);
      return;
    }
    let eapPhases: ResourceStr [] = Array.from(EAP_PHASE2_NAME_VALUE_MAP.keys());
    this.onEapEapPhase2Changed(EAP_PHASE2_NAME_VALUE_MAP.get(eapPhases[index]) ??
    wifiManager.Phase2Method.PHASE2_MSCHAPV2);
  }

  private onEapEapPhase2Changed(eapPhase: wifiManager.Phase2Method): void {
    if (!this.eapConfig) {
      LogUtil.error(`${TAG} onEapEapPhase2Changed failed, eapConfig is undefined.`);
      return;
    }
    if (this.eapConfig.eapMethod === wifiManager.EapMethod.EAP_PWD) {
      this.eapConfig.phase2Method = wifiManager.Phase2Method.PHASE2_NONE;
    } else {
      this.eapConfig.phase2Method = eapPhase;
    }
  }

  private showOrHideEapPhase2Group(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideEapPhase2Group: ${isShow}`);
    let id: string = EAP_PHASE_2_KEY;
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_select_phase2_section`;
    }
    notifyCompStateChange(id, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }

  private refreshMenuData(): void {
    LogUtil.info(`${TAG} refreshMenuData.`);
    /* instrument ignore if*/
    if (!this.eapConfig) {
      LogUtil.error(`${TAG} refreshMenuData failed.`);
      return;
    }
    let newResult: Resource = $r('app.string.phase2_mschapv2');
    if (this.isCurrentTTLSSelected) {
      newResult = $r('app.string.phase2_pap');
      this.eapConfig.phase2Method = wifiManager.Phase2Method.PHASE2_PAP;
    } else {
      this.eapConfig.phase2Method = wifiManager.Phase2Method.PHASE2_MSCHAPV2;
    }
    let id: string = EAP_PHASE_2_MENU_KEY;
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_select_phase2_section.wifi_eap_select_phase2`;
    }
    // 刷新result
    notifyCompStateChange(id,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          result: {
            content: newResult,
          },
          type: ItemResultType.RESULT_TYPE_TEXT,
        } as SettingResultState]]
      ));
    // 刷新菜单列表
    notifyCompStateChange(id, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: this.isCurrentTTLSSelected ? [
          $r('app.string.phase2_pap'),
          $r('app.string.phase2_mschapv2'),
          $r('app.string.phase2_mschap'),
          $r('app.string.phase2_gtc'),
        ] : [
          $r('app.string.phase2_mschapv2'),
          $r('app.string.phase2_gtc'),
          $r('app.string.phase2_sim'),
          $r('app.string.phase2_aka'),
          $r('app.string.phase2_aka_prime'),
        ],
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          this.onSelected(index);
        },
        defaultFocus: 0,
      } as SettingSelectMenuState]]
    ));
  }
}