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
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  ComparableSettingItemModel,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  EAP_CA_CERTIFICATE_CHANGED_EVENT,
  EAP_METHOD_CHANGED_EVENT } from '../../model/WifiModel';
import { eapInputComponentBuilder } from '../../WifiPasswordSettingsSheet';
import {
  CaCertificateType,
  WIFI_EAP_ANONYMOUS,
  WIFI_EAP_DOMAIN,
  WIFI_EAP_IDENTITY,
} from '../../WifiMenuManager';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';

const TAG: string = 'EapInputController : ';
const WIFI_EAP_DOMAIN_INDEX: number = 0;
const WIFI_IDENTITY_INDEX: number = 1;
const WIFI_ANONYMOUS_INDEX: number = 2;

export class EapInputController implements ComponentControl {
  public eapConfig?: wifiManager.WifiEapConfig;
  public param?: CompCtrlParam;
  private dataSource?: OrderedDataSource;
  private isDomainVisible: boolean = false;
  private isIdentityVisible: boolean = true;
  private isAnonymousVisible: boolean = true;
  private eapInputMenus: ComparableSettingItemModel[] = [
    {
      id: WIFI_EAP_DOMAIN,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_eap_domain'),
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: wrapBuilder(eapInputComponentBuilder),
      }
    },
    {
      id: WIFI_EAP_IDENTITY,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_eap_identity'),
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: wrapBuilder(eapInputComponentBuilder),
      }
    },
    {
      id: WIFI_EAP_ANONYMOUS,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.wifi_eap_anonymous'),
      },
      result: {
        result: undefined,
        type: ItemResultType.RESULT_TYPE_CUSTOM,
        builder: wrapBuilder(eapInputComponentBuilder),
      }
    },
  ];
  private onEapMethodChangeCallBack = () => {
    // 身份
    this.isIdentityVisible = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PEAP ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TLS ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PWD;
    // 匿名身份
    this.isAnonymousVisible = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PEAP ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS;
    this.refreshMenus();
  }
  private onEapCaCertificateChangeCallBack = () => {
    // 域名
    this.isDomainVisible = typeof this.eapConfig?.caCertAlias === 'number' &&
      this.eapConfig?.caCertAlias === CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM;
    this.refreshMenus();
  }

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    /* instrument ignore if*/
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.dataSource = param.dataSource as OrderedDataSource;
    this.param = (param as CompCtrlParam);
    LogUtil.info(`${TAG} init compId: ${this.param.compId}`);
    this.dataSource?.push(this.eapInputMenus[WIFI_IDENTITY_INDEX]);
    this.dataSource?.push(this.eapInputMenus[WIFI_ANONYMOUS_INDEX]);
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.eapConfig = config?.eapConfig;
    } else {
      this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
    }
    EventBus.getInstance().on(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
    EventBus.getInstance().on(EAP_CA_CERTIFICATE_CHANGED_EVENT, this.onEapCaCertificateChangeCallBack);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
    EventBus.getInstance().detach(EAP_CA_CERTIFICATE_CHANGED_EVENT, this.onEapCaCertificateChangeCallBack);
  }

  private refreshMenus(): void {
    if (!this.dataSource) {
      LogUtil.error(`${TAG} refreshMenus failed.`);
      return;
    }
    LogUtil.info(`${TAG} refreshMenus.`);
    let length: number = this.dataSource.length;
    for (let index = length - 1; index >= 0; index--) {
      this.dataSource.removeDataByIndex(index);
    }
    let eapInputMenus: ComparableSettingItemModel[] = [];
    /* instrument ignore if*/
    if (this.isDomainVisible) {
      eapInputMenus.push(this.eapInputMenus[WIFI_EAP_DOMAIN_INDEX]);
    }
    if (this.isIdentityVisible) {
      eapInputMenus.push(this.eapInputMenus[WIFI_IDENTITY_INDEX]);
    }
    if (this.isAnonymousVisible) {
      eapInputMenus.push(this.eapInputMenus[WIFI_ANONYMOUS_INDEX]);
    }
    this.dataSource?.pushDataArray(eapInputMenus);
  }
}