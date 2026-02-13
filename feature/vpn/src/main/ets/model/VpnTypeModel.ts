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

import { TAG } from '@ohos/hypium/src/main/Constant';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const MODULE_TAG: string = 'VpnTypeModel:';

/**
 * VPN type model
 *
 * @since 2024-06-15
 */
export class VpnTypeModel {
  static readonly TYPE_IKEV2_IPSEC_MSCHAPv2: number = 1;
  static readonly TYPE_IKEV2_IPSEC_PSK: number = 2;
  static readonly TYPE_IKEV2_IPSEC_RSA: number = 3;
  static readonly TYPE_L2TP_IPSEC_PSK: number = 4;
  static readonly TYPE_L2TP_IPSEC_RSA: number = 5;
  static readonly TYPE_IPSEC_XAUTH_PSK: number = 6;
  static readonly TYPE_IPSEC_XAUTH_RSA: number = 7;
  static readonly TYPE_IPSEC_HYBRID_RSA: number = 8;
  static readonly TYPE_OPENVPN: number = 9;

  private supportVpnTypes: number[] = [];
  private static instance: VpnTypeModel;

  public static getInstance(): VpnTypeModel {
    if (!this.instance) {
      this.instance = new VpnTypeModel();
    }
    return this.instance;
  }

  constructor() {
    let supportStr: string = '';
    try {
       supportStr = SystemParamUtils.getSystemParam('const.product.supportVpn', '1,2,3,4,5,6,7,8,9');
      LogUtil.info(`${MODULE_TAG} getSupportStr: ${supportStr} `);
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} getSupportStr is failed , err : ${err} `);
    }
    if (supportStr !== '') {
      supportStr.split(',').forEach((vpnTypeStr) => {
        let vpnType: number = Number(vpnTypeStr);
        switch (vpnType) {
          case VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2:
          case VpnTypeModel.TYPE_IKEV2_IPSEC_PSK:
          case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA:
          case VpnTypeModel.TYPE_L2TP_IPSEC_PSK:
          case VpnTypeModel.TYPE_L2TP_IPSEC_RSA:
          case VpnTypeModel.TYPE_IPSEC_XAUTH_PSK:
          case VpnTypeModel.TYPE_IPSEC_XAUTH_RSA:
          case VpnTypeModel.TYPE_IPSEC_HYBRID_RSA:
          case VpnTypeModel.TYPE_OPENVPN:
            this.supportVpnTypes.push(vpnType);
            break;
          default:
            LogUtil.info(`${MODULE_TAG} ${supportStr} has unknown vpnType:${vpnType}`);
            break;
        }
      });
    }
    LogUtil.info(`${MODULE_TAG} supportVpn ${this.supportVpnTypes}`);
  }

  isSupportVpn(): boolean {
    return this.supportVpnTypes.length > 0;
  }

  getSupportVpnTypes(): number[] {
    LogUtil.info(TAG+'VPNTYPE'+this.supportVpnTypes)
    return this.supportVpnTypes;
  }

  getSupportVpnTypeStrs(): string[] {
    let types: string[] = [];
    this.supportVpnTypes.forEach(type => {
      types.push(this.getVpnTypeStr(type));
    });
    return types;
  }

  getVpnTypeStr(vpnType: number): string {
    switch (vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2:
        return 'IKEv2/IPSec MSCHAPv2';
      case VpnTypeModel.TYPE_IKEV2_IPSEC_PSK:
        return 'IKEv2/IPSec PSK';
      case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA:
        return 'IKEv2/IPSec RSA';
      case VpnTypeModel.TYPE_L2TP_IPSEC_PSK:
        return 'L2TP/IPSec PSK';
      case VpnTypeModel.TYPE_L2TP_IPSEC_RSA:
        return 'L2TP/IPSec RSA';
      case VpnTypeModel.TYPE_IPSEC_XAUTH_PSK:
        return 'IPSec Xauth PSK';
      case VpnTypeModel.TYPE_IPSEC_XAUTH_RSA:
        return 'IPSec Xauth RSA';
      case VpnTypeModel.TYPE_IPSEC_HYBRID_RSA:
        return 'IPSec Hybrid RSA';
      case VpnTypeModel.TYPE_OPENVPN:
        return 'OpenVpn';
      default:
        LogUtil.warn(`${MODULE_TAG} getVpnTypeStr unknown vpnType : ${vpnType}`);
        return '';
    }
  }
}