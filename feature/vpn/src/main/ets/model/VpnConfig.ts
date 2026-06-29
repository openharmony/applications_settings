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

import { vpn } from '@kit.NetworkKit';
import { VpnTypeModel } from './VpnTypeModel';

/**
 * VPN config
 *
 * @since 2024-06-15
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
  ovpnConfigFilePath?: string;
  ovpnConfigContent?: string;
  ovpnConfig?: string;
  ovpnAuthType: number = 0;
  ovpnProtocolFileRaw?: string;
  ovpnProtocol: number = 0;
  ovpnAddressPortFileRaw?: string;
  ovpnPort?: string;
  askpass: string;
  ovpnCaCertFilePath?: string;
  ovpnUserCertFilePath?: string;
  ovpnPrivateKeyFilePath?: string;
  ovpnCaCertFileRaw?: string;
  ovpnCaCert?: string;
  ovpnUserCertFileRaw?: string;
  ovpnUserCert?: string;
  ovpnPrivateKeyFileRaw?: string;
  ovpnPrivateKey?: string;
  ovpnUserPassFileRaw?: string;
  ovpnProxyHostFileRaw?: string;
  ovpnProxyHost?: string;
  ovpnProxyPort?: string;
  ovpnProxyUserPassFileRaw?: string;
  ovpnProxyUser?: string;
  ovpnProxyPass?: string;
}

export class IpsecVpnConfig extends VpnConfig implements vpn.IpsecVpnConfig {
  ipsecIdentifier?: string;
  ipsecPreSharedKey?: string;
  l2tpSharedKey?: string;
  ipsecPublicUserCertConfig?: string;
  ipsecPublicUserCertFilePath?: string;
  ipsecPrivateUserCertConfig?: string;
  ipsecPrivateUserCertFilePath?: string;
  ipsecCaCertConfig?: string;
  ipsecCaCertFilePath?: string;
  ipsecPublicServerCertConfig?: string;
  ipsecPublicServerCertFilePath?: string;
  ipsecPrivateServerCertConfig?: string;
  ipsecPrivateServerCertFilePath?: string;
  swanctlConfig?: string;
  strongSwanConfig?: string;
  optionsL2tpdClient?: string;
  xl2tpdConfig?: string;
  ipsecConfig?: string;
  ipsecSecrets?: string;
}

export class VpnListItem {
  vpnName: string;
  vpnId: string;
}