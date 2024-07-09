/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import parameter from '@ohos.systemParameterEnhance';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const MODULE_TAG: string = 'setting_vpn:VpnTypeModel:';

/**
 * support vpn type & displayname
 */
export class VpnTypeModel {
  static readonly TYPE_IKEV2_IPSEC_MSCHAPv2: number = 1; // vpn.SysVpnType.IKEV2_IPSEC_MSCHAPv2;
  static readonly TYPE_IKEV2_IPSEC_PSK: number = 2; // vpn.SysVpnType.IKEV2_IPSEC_PSK;
  static readonly TYPE_IKEV2_IPSEC_RSA: number = 3; // vpn.SysVpnType.IKEV2_IPSEC_RSA;
  static readonly TYPE_L2TP_IPSEC_PSK: number = 4; // vpn.SysVpnType.L2TP_IPSEC_PSK;
  static readonly TYPE_L2TP_IPSEC_RSA: number = 5; // vpn.SysVpnType.L2TP_IPSEC_RSA;
  static readonly TYPE_IPSEC_XAUTH_PSK: number = 6; // vpn.SysVpnType.IPSEC_XAUTH_PSK;
  static readonly TYPE_IPSEC_XAUTH_RSA: number = 7; // vpn.SysVpnType.IPSEC_XAUTH_RSA;
  static readonly TYPE_IPSEC_HYBRID_RSA: number = 8; // vpn.SysVpnType.IPSEC_HYBRID_RSA;
  static readonly TYPE_OPENVPN: number = 9; // vpn.SysVpnType.OPENVPN;

  private supportVpnTypes: number[] = [];
  private static instance: VpnTypeModel;

  public static getInstance(): VpnTypeModel {
    if (!this.instance) {
      this.instance = new VpnTypeModel();
    }
    return this.instance;
  }

  constructor() {
    let supportStr: string = parameter.getSync("const.product.supportVpn", "");
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
        default :
          LogUtil.info(MODULE_TAG + supportStr + ` has unknown vpnType:` + vpnType);
          break;
      }
    })
    LogUtil.info(MODULE_TAG + `supportVpn ${this.supportVpnTypes}`);
  }

  isSupportVpn(): boolean {
    return this.supportVpnTypes.length > 0;
  }

  getSupportVpnTypes(): number[] {
    return this.supportVpnTypes;
  }

  getSupportVpnTypeStrs(): string[] {
    let types: string[] = [];
    this.supportVpnTypes.forEach(type => {
      types.push(this.getVpnTypeStr(type))
    });
    return types;
  }

  getVpnTypeStr(vpnType: number): string {
    switch (vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2: return 'IKEv2/IPSec MSCHAPv2';
      case VpnTypeModel.TYPE_IKEV2_IPSEC_PSK: return 'IKEv2/IPSec PSK';
      case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA: return 'IKEv2/IPSec RSA';
      case VpnTypeModel.TYPE_L2TP_IPSEC_PSK: return 'L2TP/IPSec PSK';
      case VpnTypeModel.TYPE_L2TP_IPSEC_RSA: return 'L2TP/IPSec RSA';
      case VpnTypeModel.TYPE_IPSEC_XAUTH_PSK: return 'IPSec Xauth PSK';
      case VpnTypeModel.TYPE_IPSEC_XAUTH_RSA: return 'IPSec Xauth RSA';
      case VpnTypeModel.TYPE_IPSEC_HYBRID_RSA: return 'IPSec Hybrid RSA';
      case VpnTypeModel.TYPE_OPENVPN: return 'OpenVpn';
      default :
        LogUtil.warn(MODULE_TAG + 'getVpnTypeStr unknown vpnType:' + vpnType);
        return '';
    }
  }
}