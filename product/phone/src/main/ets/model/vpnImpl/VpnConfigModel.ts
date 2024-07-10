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

import util from '@ohos.util';
import { promptAction } from '@kit.ArkUI';
import VpnConfig, { IpsecVpnConfig, OpenVpnConfig } from './VpnConfig';
import VpnConstant from './VpnConstant';
import { VpnTypeModel } from './VpnTypeModel';
import { SwanCtlModel } from './SwanCtlModel';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const MODULE_TAG: string = 'setting_vpn:VpnConnectModel:';
const OVPN_PROTOCOL_TCP: number = 0;
const OVPN_PROTOCOL_UDP: number = 1;

/**
 * system vpn config model
 */
export class VpnConfigModel {
  private static instance: VpnConfigModel;

  private isNeedUpdateVpnList: boolean = false;

  public static getInstance(): VpnConfigModel {
    if (!this.instance) {
      this.instance = new VpnConfigModel();
    }
    return this.instance;
  }

  isUpdateVpnList(): boolean {
    return this.isNeedUpdateVpnList;
  }

  setNeedUpdateVpnList(isUpdate: boolean): void {
    this.isNeedUpdateVpnList = isUpdate;
  }

  setAddress(vpnConfig: VpnConfig, vpnAddress: string): void {
    if (vpnConfig === undefined || vpnConfig === null) {
      LogUtil.error(MODULE_TAG + `setAddress failed, invalid config`);
      return;
    }
    vpnConfig.addresses = [{
      address: { address: vpnAddress },
      prefixLength: 1,
    }]
  }

  getAddress(vpnConfig: VpnConfig): string | undefined {
    if (vpnConfig === undefined || vpnConfig === null) {
      LogUtil.error(MODULE_TAG + `setRoutes failed, invalid config`);
      return undefined;
    }
    if (vpnConfig.addresses?.length > 0) {
      return vpnConfig.addresses[0].address?.address;
    }
    LogUtil.error(MODULE_TAG + `getAddress invalid vpnConfig`);
    return undefined;
  }

  stringToUint8Array(str: string): Uint8Array {
    let arr: number[] = [];
    for (let i = 0, j = str.length; i < j; ++i) {
      arr.push(str.charCodeAt(i));
    }
    return new Uint8Array(arr);
  }

  uint8ArrayToString(data: Uint8Array): string {
    let resultStr: string = '';
    const charArray = data.map(value => Number(value));
    charArray.forEach((value) => {
      resultStr += String.fromCharCode(value);
    });
    return resultStr;
  }

  showToast(msg: string | Resource): void {
    if (!msg) {
      LogUtil.error(MODULE_TAG + `showToast failed, invalid msg`);
      return;
    }
    promptAction.showToast({
      message: msg,
      duration: 2000,
    });
  }

  inflateConfigFromFileData(config: OpenVpnConfig, data: string[]): void {
    config.ovpnConfigFilePath = data[0];
    let content = data[1];
    config.ovpnConfigContent = content;

    let regex = /proto\s+(tcp|udp)/;
    let match = regex.exec(content);
    if (match && match.length >= 1) {
      config.ovpnProtocolFileRaw = match[0];
      config.ovpnProtocol = match[1] === 'udp' ? OVPN_PROTOCOL_UDP : OVPN_PROTOCOL_TCP;
    }

    regex = /remote\s+([^\s]+)\s+(\d+)/;
    match = regex.exec(content);
    if (match && match.length >= 2) {
      config.ovpnAddressPortFileRaw = match[0];
      this.setAddress(config, match[1]);
      config.ovpnPort = match[2];
    }

    regex = /<ca>([\s\S]*?)<\/ca>/
    match = regex.exec(content);
    if (match) {
      config.ovpnCaCertFileRaw = match[0];
    }

    regex = /<cert>([\s\S]*?)<\/cert>/
    match = regex.exec(content);
    if (match && match.length >= 1) {
      config.ovpnUserCertFileRaw = match[0];
    }

    regex = /<key>([\s\S]*?)<\/key>/
    match = regex.exec(content);
    if (match && match.length >= 1) {
      config.ovpnPrivateKeyFileRaw = match[0];
    }

    regex = /<auth-user-pass>\s*([\s\S]+?)\s*(\r?\n|\r)\s*([\s\S]+?)\s*<\/auth-user-pass>/
    match = regex.exec(content);
    if (match && match.length >= 4) {
      config.ovpnUserPassFileRaw = match[0];
      config.userName = match[1];
      config.password = match[3];
    }

    regex = /http-proxy\s+([^\s]+)\s+(\d+)/;
    match = regex.exec(content);
    if (match && match.length >= 3) {
      config.ovpnProxyHostFileRaw = match[0];
      config.ovpnProxyHost = match[1];
      config.ovpnProxyPort = match[2];
    }

    regex = /<http-proxy-user-pass>\s*([\s\S]+?)\s*(\r?\n|\r)\s*([\s\S]+?)\s*<\/http-proxy-user-pass>/;
    match = regex.exec(content);
    if (match && match.length >= 4) {
      config.ovpnProxyUserPassFileRaw = match[0];
      config.ovpnProxyUser = match[1];
      config.ovpnProxyPass = match[3];
    }
  }

  prepareAddSysVpnConfig(config: VpnConfig): void {
    switch (config?.vpnType) {
      case VpnTypeModel.TYPE_OPENVPN:
        this.prepareOvpnConfig(config as OpenVpnConfig);
        break;
      default:
        this.prepareIpsecConfig(config as IpsecVpnConfig);
        break;
    }
  }

  prepareIpsecConfig(config: IpsecVpnConfig): void {
    if (config === undefined || config === null) {
      LogUtil.error(MODULE_TAG + "prepareIpsecConfig faild, invalid param.")
      return;
    }
    SwanCtlModel.getInstance().buildConfig(config);
  }

  prepareOvpnConfig(config: OpenVpnConfig): void {
    if (config === undefined || config === null) {
      LogUtil.error(MODULE_TAG + "prepareOvpnConfig faild, invalid param.")
      return;
    }
    let that = new util.Base64Helper();
    let content = '';
    if (config.ovpnConfig) {
      let data = that.decodeSync(config.ovpnConfig);
      content = this.uint8ArrayToString(data);
    } else {
      content = config.ovpnConfigContent ?? 'client\ndev tun';
    }

    let protocolReplace: string = `proto ${config.ovpnProtocol === OVPN_PROTOCOL_TCP ? 'tcp' : 'udp'}`;
    if (protocolReplace === config.ovpnProtocolFileRaw) {
      content = content.replace(config.ovpnProtocolFileRaw, '\n' + protocolReplace);
    } else {
      content += '\n';
      content += protocolReplace;
    }

    let vpnAddress: string = this.getAddress(config);
    if (vpnAddress && config.ovpnPort) {
      let addressPortReplace: string = `remote ${vpnAddress} ${config.ovpnPort}`;
      if (addressPortReplace === config.ovpnAddressPortFileRaw) {
        content = content.replace(config.ovpnAddressPortFileRaw, '\n' + addressPortReplace);
      } else {
        content += '\n';
        content += addressPortReplace;
        content += '\nlog \/data\/service\/el1\/public\/netmanager\/config.log\ndev-node \/dev\/tun' +
          '\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 7\n';
      }
    }

    if (config.ovpnCaCert) {
      let caCert: string = config.ovpnCaCert;
      if (config.ovpnCaCertFileRaw) {
        if (config.ovpnCaCertFileRaw !== caCert) {
          content = content.replace(config.ovpnCaCertFileRaw, '\n' + caCert);
        }
      } else {
        content += '\n';
        content += caCert;
      }
    }

    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_PWD) {
      config.ovpnUserCert = undefined;
      if (config.ovpnUserCertFileRaw) {
        content.replace(config.ovpnUserCertFileRaw, '');
      }
      config.ovpnUserCertFileRaw = undefined;
      config.ovpnUserCertFilePath = undefined;
    }

    if (config.ovpnUserCert) {
      let userCert: string = config.ovpnUserCert;
      if (config.ovpnUserCertFileRaw) {
        if (config.ovpnUserCertFileRaw !== userCert) {
          content = content.replace(config.ovpnUserCertFileRaw, '\n' + userCert);
        }
      } else {
        content += '\n';
        content += userCert;
      }
    }

    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_PWD) {
      config.ovpnPrivateKey = undefined;
      if (config.ovpnPrivateKeyFileRaw) {
        content.replace(config.ovpnPrivateKeyFileRaw, '');
      }
      config.ovpnPrivateKeyFileRaw = undefined;
      config.ovpnPrivateKeyFilePath = undefined;
    }

    if (config.ovpnPrivateKey) {
      let privateKey: string = config.ovpnPrivateKey;
      if (config.ovpnPrivateKeyFileRaw) {
        if (config.ovpnPrivateKeyFileRaw !== privateKey) {
          content = content.replace(config.ovpnPrivateKeyFileRaw, '\n' + privateKey);
        }
      } else {
        content += '\n';
        content += privateKey;
      }
    }

    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_TLS) {
      config.userName = undefined;
      config.password = undefined;
      if (config.ovpnUserPassFileRaw) {
        content = content.replace(config.ovpnUserPassFileRaw, '');
      }
    }

    if (config.userName) {
      let userPass: string = '<auth-user-pass>';
      userPass += '\n';
      userPass += config.userName;
      userPass += '\n';
      userPass += config.password;
      userPass += '\n';
      userPass += '</auth-user-pass>'

      if (config.userName) {
        if (config.ovpnUserPassFileRaw) {
          if (config.ovpnUserPassFileRaw !== userPass) {
            content = content.replace(config.ovpnUserPassFileRaw, '\n' + userPass);
          }
        } else {
          content += '\n';
          content += userPass;
        }
      }
    }

    if (config.ovpnProxyHost) {
      let proxyHostPort: string = `http-proxy ${config.ovpnProxyHost} ${config.ovpnProxyPort ?? ''}`;
      if (config.ovpnProxyHostFileRaw) {
        if (config.ovpnProxyHostFileRaw !== proxyHostPort) {
          content = content.replace(config.ovpnProxyHostFileRaw, '\n' + proxyHostPort);
        }
      } else {
        content += '\n';
        content += proxyHostPort;
      }
    }

    if (config.ovpnProxyUser) {
      let proxyUserPass: string = '<http-proxy-user-pass>';
      proxyUserPass += '\n';
      proxyUserPass += config.ovpnProxyUser;
      proxyUserPass += '\n';
      proxyUserPass += config.ovpnProxyPass;
      proxyUserPass += '\n';
      proxyUserPass += '</http-proxy-user-pass>'
      if (config.ovpnProxyUserPassFileRaw) {
        if (config.ovpnProxyUserPassFileRaw !== proxyUserPass) {
          content = content.replace(config.ovpnProxyUserPassFileRaw, '\n' + proxyUserPass);
        }
      } else {
        content += '\n';
        content += proxyUserPass;
      }
    }

    let regex = /^\s*$\n/gm;
    content = content.replace(regex, '');
    config.ovpnConfig = that.encodeToStringSync(this.stringToUint8Array(content));
  }
}