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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { CaCertificateType, WIFI_EAP_CA_CERTIFICATE } from '../../WifiMenuManager';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { WifiCertUtils } from '../../WifiCertUtils';
import {
  EAP_CA_CERTIFICATE_CHANGED_EVENT,
  EAP_METHOD_CHANGED_EVENT,
  PendingIpConfig,
  WLAN_CONFIG_INPUT_CHANGE_EVENT,
} from '../../model/WifiModel';

const TAG: string = 'CaCertificateController : ';
const CA_CERTIFICATE_KEY: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_ca_certificate_section`;
const CA_CERTIFICATE_MENU_KEY: string =
  `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_ca_certificate_section.wifi_eap_ca_certificate`;

export class CaCertificateController implements ComponentControl {
  public pendingIpConfig: PendingIpConfig | null = null;
  public eapConfig?: wifiManager.WifiEapConfig;
  public param?: CompCtrlParam;
  private currentSelected: number = -1;
  private caCertificateMaps: Map<ResourceStr, string | number> = new Map([
    [$r('app.string.wifi_do_not_validate_eap_server'), CaCertificateType.CA_CERTIFICATE_TYPE_NONE],
    [$r('app.string.wifi_use_system_certs'), CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM],
  ]);
  private onEapMethodChangeCallBack = () => {
    // eap 发生变化后，需要动态隐藏或者显示当前菜单
    let showCaCertificateGroup: boolean = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PEAP ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TLS ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS;
    this.showCaCertificateGroup(showCaCertificateGroup);
    this.showOrHideFooter(this.currentSelected === 0 && showCaCertificateGroup);
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    /* instrument ignore if*/
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.param = param as CompCtrlParam;
    if (AddOtherWlanConfigManager.getInstance().wifiConfig) {
      this.eapConfig = AddOtherWlanConfigManager.getInstance().wifiConfig?.eapConfig;
    } else {
      this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
    }
    let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
    dataSource?.pushData({
      id: WIFI_EAP_CA_CERTIFICATE,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.ca_certificate'),
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
            $r('app.string.wifi_do_not_validate_eap_server'),
            $r('app.string.wifi_use_system_certs'),
          ],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            this.onSelected(index);
          },
          defaultFocus: -1,
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.please_select'),
        }
      }
    });
    EventBus.getInstance().on(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
    this.updateCACertificate();
    this.showOrHideFooter(false);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
  }

  onSelected(index: number): void {
    this.currentSelected = index;
    let caCertificate: ResourceStr [] = Array.from(this.caCertificateMaps.keys());
    this.onCaCertificateChanged(this.caCertificateMaps.get(caCertificate[index]) ??
    CaCertificateType.CA_CERTIFICATE_TYPE_NONE);
    this.showOrHideFooter(index === 0);
  }

  private onCaCertificateChanged(value: string | number): void {
    if (!this.eapConfig) {
      LogUtil.error(`${TAG} onCaCertificateChanged failed, eapConfig is undefined.`);
      return;
    }
    this.eapConfig.caCertAlias = value as string;
    if (value === CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM) {
      this.eapConfig.caPath = '/system/etc/security/certificates/';
    } else {
      this.eapConfig.caPath = '';
    }
    EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT);
    EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
  }

  private showOrHideFooter(showFooter: boolean): void {
    let footerId: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_ca_certificate_section.footer`;
    if (AddOtherWlanConfigManager.getInstance().wifiConfig) {
      footerId = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_ca_certificate_section.footer`;
    }
    notifyCompStateChange(footerId,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: showFooter } as SettingCompState]]
      ));
  }

  /**
   * 获取用户安装得CA证书转成选项
   */
  private async updateCACertificate(): Promise<void> {
    const certList = await WifiCertUtils.getAllUserTrustedCertificates();
    LogUtil.info(`${TAG} getAllUserTrustedCertificates length:${certList.length}`);
    for (let item of certList) {
      this.caCertificateMaps.set(item.certAlias, item.uri);
    }
    let id: string = CA_CERTIFICATE_MENU_KEY;
    if (AddOtherWlanConfigManager.getInstance().wifiConfig) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_ca_certificate_section.wifi_eap_ca_certificate`;
    }
    // 刷新菜单列表
    notifyCompStateChange(id, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: Array.from(this.caCertificateMaps.keys()),
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          this.onSelected(index);
        },
        defaultFocus: -1,
      } as SettingSelectMenuState]]));
  }

  private showCaCertificateGroup(isShow: boolean): void {
    let id: string = CA_CERTIFICATE_KEY;
    if (AddOtherWlanConfigManager.getInstance().wifiConfig) {
      id = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_eap_ca_certificate_section`;
    }
    LogUtil.info(`${TAG} showCaCertificateGroup: ${isShow}`);
    notifyCompStateChange(id, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }
}