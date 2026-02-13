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

import util from '@ohos.util';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { certificateManager } from '@kit.DeviceCertificateKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import VpnConfig, { IpsecVpnConfig, OpenVpnConfig } from './VpnConfig';
import VpnConstant from './VpnConstant';
import { VpnTypeModel } from './VpnTypeModel';
import { SwanCtlModel } from './SwanCtlModel';
import { CommonUtils } from '../utils/CommonUtils';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnConnectModel:';
const OVPN_PROTOCOL_TCP: number = 0;
const OVPN_PROTOCOL_UDP: number = 1;

/**
 * VPN config data model
 *
 * @since 2024-06-15
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
    if (!vpnConfig) {
      LogUtil.error(`${MODULE_TAG} setAddress failed, invalid config`);
      return;
    }
    vpnConfig.addresses = [{
      address: { address: vpnAddress },
      prefixLength: 1,
    }];
  }

  getAddress(vpnConfig: VpnConfig): string | undefined {
    if (!vpnConfig) {
      LogUtil.error(`${MODULE_TAG} getAddress failed, invalid config`);
      return undefined;
    }
    if (vpnConfig.addresses?.length > 0) {
      return vpnConfig.addresses[0].address?.address;
    }
    LogUtil.error(`${MODULE_TAG} getAddress getAddress, invalid address`);
    return undefined;
  }

  showToast(msg: string | Resource): void {
    if (!msg) {
      LogUtil.error(`${MODULE_TAG} showToast failed, invalid msg`);
      return;
    }
    promptAction.showToast({
      message: msg,
      duration: 2000,
    });
  }

  inflateConfigFromFileData(config: OpenVpnConfig, data: string[]): void {
    if (!config || !data) {
      LogUtil.error(`${MODULE_TAG} inflateConfigFromFileData failed, params is error`);
      return;
    }
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

    regex = /<ca>([\s\S]*?)<\/ca>/;
    match = regex.exec(content);
    if (match) {
      config.ovpnCaCertFileRaw = match[0];
    }

    regex = /<cert>([\s\S]*?)<\/cert>/;
    match = regex.exec(content);
    if (match && match.length >= 1) {
      config.ovpnUserCertFileRaw = match[0];
    }

    regex = /<key>([\s\S]*?)<\/key>/;
    match = regex.exec(content);
    if (match && match.length >= 1) {
      config.ovpnPrivateKeyFileRaw = match[0];
    }
    this.inflateConfigFromContent(config, content);
  }

  inflateConfigFromContent(config: OpenVpnConfig, content: string): void {
    if (!config || !content) {
      LogUtil.error(`${MODULE_TAG} inflateConfigFromContent failed, params is error`);
      return;
    }
    let regex = /<auth-user-pass>\s*([\s\S]+?)\s*(\r?\n|\r)\s*([\s\S]+?)\s*<\/auth-user-pass>/;
    let match = regex.exec(content);
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
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareAddSysVpnConfig failed, params is error`);
      return;
    }
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
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareIpsecConfig faild, invalid param.`);
      return;
    }
    SwanCtlModel.getInstance().buildConfig(config);
  }

  prepareOvpnConfigForCert(config: OpenVpnConfig): string {
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareOvpnConfigForCert faild, invalid param.`);
      return '';
    }
    let content = '';
    if (config.ovpnCaCert) {
      content += `\n${config.ovpnCaCert}`;
    }

    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_PWD) {
      config.ovpnUserCert = undefined;
      config.ovpnUserCertFileRaw = undefined;
      config.ovpnUserCertFilePath = undefined;
    }

    if (config.ovpnUserCert) {
      content += `\n${config.ovpnUserCert}`;
    }
    return content;
  }

  prepareOvpnConfigForAuth(config: OpenVpnConfig): string {
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareOvpnConfigForAuth faild, invalid param.`);
      return '';
    }
    let content = '';
    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_PWD) {
      config.ovpnPrivateKey = undefined;
      config.ovpnPrivateKeyFileRaw = undefined;
      config.ovpnPrivateKeyFilePath = undefined;
    }

    if (config.ovpnPrivateKey) {
      content += `\n${config.ovpnPrivateKey}`;
    }

    if (config.ovpnAuthType === VpnConstant.OVPN_AUTH_TYPE_TLS) {
      config.userName = undefined;
      config.password = undefined;
    }
    return content;
  }

  prepareOvpnConfigForProxy(config: OpenVpnConfig): string {
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareOvpnConfigForProxy faild, invalid param.`);
      return '';
    }
    let content = '';
    if (config.userName) {
      content += `\n<auth-user-pass>\n${config.userName}\n${config.password}\n</auth-user-pass>`;
    }

    if (config.ovpnProxyHost) {
      content += `\nhttp-proxy ${config.ovpnProxyHost} ${config.ovpnProxyPort ?? ''}`;
    }

    if (config.ovpnProxyUser) {
      content += `\n<http-proxy-user-pass>\n${config.ovpnProxyUser}\n${config.ovpnProxyPass}\n</http-proxy-user-pass>\n`;
    }
    return content;
  }

  prepareOvpnConfig(config: OpenVpnConfig): void {
    if (!config) {
      LogUtil.error(`${MODULE_TAG} prepareOvpnConfig faild, invalid param.`);
      return;
    }
    let that = new util.Base64Helper();
    let content = '';
    if (config.ovpnConfigFilePath) {
      if (config.ovpnConfigContent) {
        let regex = /^\s*$\n/gm;
        content = config.ovpnConfigContent.replace(regex, '');
        config.ovpnConfig = that.encodeToStringSync(CommonUtils.stringToUint8Array(content));
      }
      return;
    }

    let protocolReplace: string = `proto ${config.ovpnProtocol === OVPN_PROTOCOL_TCP ? 'tcp' : 'udp'}`;
    content += `client\ndev tun\n${protocolReplace}`;

    let vpnAddress: string = this.getAddress(config);
    content += `\nremote ${vpnAddress} ${config.ovpnPort}`;
    content += `\ndev-node \/dev\/tun\nresolv-retry infinite\nnobind\npersist-key\npersist-tun`;
    let certContent = this.prepareOvpnConfigForCert(config);
    let authContent = this.prepareOvpnConfigForAuth(config);
    let proxyContent = this.prepareOvpnConfigForProxy(config);
    content = content + certContent + authContent + proxyContent;
    config.ovpnConfig = that.encodeToStringSync(CommonUtils.stringToUint8Array(content));
  }

  async getCAList(): Promise<VpnCertItem[]> {
    LogUtil.info(`${MODULE_TAG} getCAList start`);
    let certList: VpnCertItem[] = [];
    try {
      let result = await certificateManager.getAllUserTrustedCertificates();
      if (result?.certList === undefined) {
        LogUtil.error(`${MODULE_TAG} getCAList failed, undefined`);
        return certList;
      }
      LogUtil.info(`${MODULE_TAG} getCAList end size = ${result.certList.length}`);
      for (let i = 0; i < result.certList.length; i++) {
        if (String(result.certList[i].uri).indexOf('u=0;') === -1) {
          certList.push(new VpnCertItem(
            String(result.certList[i].certAlias), String(result.certList[i].uri)));
        }
      }
      return certList;
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      LogUtil.error(`${MODULE_TAG} getCAList err, message: ${error.message} , code: ${error.code}`);
      return certList;
    }
  }

  async getSystemAppCertList(): Promise<VpnCertItem[]> {
    LogUtil.info(`${MODULE_TAG} getSystemAppCertList start`);
    let certList: VpnCertItem[] = [];
    try {
      let result = await certificateManager.getAllSystemAppCertificates();
      if (result?.credentialList !== undefined) {
        LogUtil.info(`${MODULE_TAG} getSystemAppCertList size = ${result.credentialList.length}`);
        for (let i = 0; i < result.credentialList.length; i++) {
          certList.push(new VpnCertItem(
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        return certList;
      } else {
        LogUtil.error(`${MODULE_TAG} getSystemAppCertList failed, undefined.`);
        return certList;
      }
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      LogUtil.error(`${MODULE_TAG} getSystemAppCertList failed, message : ${error.message} , code: ${error.code}`);
      return certList;
    }
  }
}

export class VpnCertItem {
  certAlias: string;
  certUri: string;

  constructor(alias: string, uri: string) {
    this.certAlias = alias;
    this.certUri = uri;
  }
}
