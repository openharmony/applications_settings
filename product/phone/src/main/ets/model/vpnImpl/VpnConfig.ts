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

import vpn from '@ohos.net.vpn';
import { VpnTypeModel } from './VpnTypeModel';

/**
 * extend system VpnConig
 */
export default class VpnConfig implements vpn.SysVpnConfig {
  // vpnConfig
  addresses: Array<vpn.LinkAddress> = [];
  routes?: Array<vpn.RouteInfo>;
  dnsAddresses?: Array<string>;
  searchDomains?: Array<string>;
  isLegacy: boolean = true;

  // sysVpnConfig
  vpnId: string = '';
  vpnName: string = '';
  vpnType: vpn.SysVpnType = VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2;
  userName?: string;
  password?: string;
  saveLogin: boolean = false;
  userId?: number;
  forwardingRoutes?: string;
}

export class OpenVpnConfig extends VpnConfig implements vpn.OpenVpnConfig {
  ovpnConfigFilePath?: string // openVpn file name
  ovpnConfigContent?: string // openVpn config
  ovpnConfig?: string // openVpn config base64
  ovpnAuthType: number = 0 // openvpn auth type
  ovpnProtocolFileRaw?: string // Protocol
  ovpnProtocol: number = 0 // 0:tcp 1:udp
  ovpnAddressPortFileRaw?: string // port
  ovpnPort?: string // openvpn port
  askpass: string // private key password
  ovpnCaCertFilePath?: string // openVpn CA FilePath
  ovpnUserCertFilePath?: string // openVpn USER FilePath
  ovpnPrivateKeyFilePath?: string // openVpn private key  FilePath
  ovpnCaCertFileRaw?: string // ca raw data
  ovpnCaCert?: string // CA data
  ovpnUserCertFileRaw?: string //
  ovpnUserCert?: string //
  ovpnPrivateKeyFileRaw?: string // private key raw data
  ovpnPrivateKey?: string // private key data
  ovpnUserPassFileRaw?: string // userpass raw d
  ovpnProxyHostFileRaw?: string // host raw data
  ovpnProxyHost?: string //ovpn host
  ovpnProxyPort?: string //ovpn port
  ovpnProxyUserPassFileRaw?: string // userpass data
  ovpnProxyUser?: string //ovpn user
  ovpnProxyPass?: string //ovpn pass
}

export class IpsecVpnConfig extends VpnConfig implements vpn.IpsecVpnConfig {
  ipsecIdentifier?: string // ipsec identifier
  ipsecPreSharedKey?: string // ipsec pre sharedKey
  l2tpSharedKey?: string // L2TP secret
  ipsecPublicUserCertConfig?: string // public userCert config
  ipsecPublicUserCertFilePath?: string // public userCert FilePath
  ipsecPrivateUserCertConfig?: string // private userCert config
  ipsecPrivateUserCertFilePath?: string // private userCert FilePath
  ipsecCaCertConfig?: string // ca config
  ipsecCaCertFilePath?: string // ca FilePath
  ipsecPublicServerCertConfig?: string // public serverCert config
  ipsecPublicServerCertFilePath?: string // public serverCert FilePath
  ipsecPrivateServerCertConfig?: string // private serverCert config
  ipsecPrivateServerCertFilePath?: string // private serverCert FilePath
  swanctlConfig?: string // swanctl config base64
  strongSwanConfig?: string // strongswan config base64
  optionsL2tpdClient?: string // optionsL2tpd Client base64
  xl2tpdConfig?: string // xl2tpd config base64
  ipsecConfig?: string // swanctl config base64
  ipsecSecrets?: string // swanctl config base64
}

export class VpnListItem {
  vpnName: string //vpnName
  vpnId: string //UUID
}