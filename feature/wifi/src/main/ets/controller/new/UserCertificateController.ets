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
import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingSelectMenuState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CaCertificateType, WIFI_EAP_USER_CERTIFICATE } from '../../WifiMenuManager';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { WifiCertUtils } from '../../WifiCertUtils';

const TAG: string = 'UserCertificateController : ';
const USER_CERTIFICATE_KEY: string = `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_user_certificate_section`;
const USER_CERTIFICATE_MENU_KEY: string =
  `${PageRouter.getRouterName()}.wifi_password_config.wifi_eap_user_certificate_section.wifi_eap_user_certificate`;

export class UserCertificateController implements ComponentControl {
  public eapConfig?: wifiManager.WifiEapConfig;
  public param?: CompCtrlParam;
  private hasInitUserCertificateData: boolean = false;
  private userCertificateMaps: Map<ResourceStr, string | number> = new Map([
    [$r('app.string.wifi_do_not_provide_eap_user_cert'), CaCertificateType.CA_CERTIFICATE_TYPE_NONE],
  ]);
  private onEapMethodChangeCallBack = () => {
    // eap 发生变化后，需要动态隐藏或者显示当前菜单
    let showUserCertificateGroup: boolean = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TLS;
    this.showUserCertificateGroup(showUserCertificateGroup);
    if (!this.hasInitUserCertificateData && showUserCertificateGroup) {
      this.hasInitUserCertificateData = true;
      this.updateUserCertificate();
    }
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.param = (param as CompCtrlParam);
    this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
    let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
    dataSource?.pushData(this.createUserCertificateMenus());
    EventBus.getInstance().on('EAP_METHOD_CHANGED', this.onEapMethodChangeCallBack);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach('EAP_METHOD_CHANGED', this.onEapMethodChangeCallBack);
  }

  onSelected(index: number): void {
    let userCertificate: ResourceStr [] = Array.from(this.userCertificateMaps.keys());
    this.onUserCertificateChanged(this.userCertificateMaps.get(userCertificate[index]) ??
    CaCertificateType.CA_CERTIFICATE_TYPE_NONE);
  }

  private onUserCertificateChanged(value: string | number): void {
    if (!this.eapConfig) {
      LogUtil.error(`${TAG} onUserCertificateChanged failed, eapConfig is undefined.`);
      return;
    }
    this.eapConfig.clientCertAlias = value as string;
    EventBus.getInstance().emit('WLAN_CONFIG_INPUT_CHANGE');
  }

  private createUserCertificateMenus(): SettingItemModel {
    return {
      id: WIFI_EAP_USER_CERTIFICATE,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_user_certificate'),
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
            $r('app.string.wifi_do_not_provide_eap_user_cert'),
          ],
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            this.onSelected(index);
          },
          defaultFocus: -1,
        }
      },
      onTouchEvent: () => {
        this.refreshUserCertificate();
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: $r('app.string.please_select'),
        }
      }
    };
  }

  /**
   * 获取用户安装的用户凭据
   */
  private async updateUserCertificate(): Promise<void> {
    const certList = await WifiCertUtils.getAllSystemAppCertificates();
    LogUtil.info(`${TAG} getAllSystemAppCertificates length:${certList.length}`);
    for (let item of certList) {
      this.userCertificateMaps.set(item.alias, item.keyUri);
    }
    this.refreshUserCertificate();
  }

  /**
   * 刷新菜单列表
   */
  private refreshUserCertificate(): void {
    notifyCompStateChange(USER_CERTIFICATE_MENU_KEY, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_MENU, {
        items: Array.from(this.userCertificateMaps.keys()),
        selectIcon: $r('app.media.ic_selected_ok'),
        onSelected: (index) => {
          this.onSelected(index);
        },
        defaultFocus: -1,
      } as SettingSelectMenuState]]));
  }

  private showUserCertificateGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showUserCertificateGroup: ${isShow}`);
    notifyCompStateChange(USER_CERTIFICATE_KEY, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow } as SettingCompState]]
    ));
  }
}