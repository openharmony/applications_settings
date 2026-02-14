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

import common from '@ohos.app.ability.common';
import HashMap from '@ohos.util.HashMap';
import { util } from '@kit.ArkTS';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { IpsecVpnConfig } from './VpnConfig';
import { VpnConfigModel } from './VpnConfigModel';
import { VpnTypeModel } from './VpnTypeModel';
import { CommonUtils } from '../utils/CommonUtils';

/* instrument ignore file */
const MODULE_TAG: string = 'setting_vpn:SwanCtlModel:';
const KEY_VPN_ADDRESS: string = 'vpn_address_value';
const KEY_VPN_USERNAME: string = 'vpn_username_value';
const KEY_VPN_IPSEC_IDENTIFIER: string = 'vpn_ipsec_identifier_value';
const KEY_VPN_PASSWORD: string = 'vpn_password_value';
const KEY_VPN_IPSEC_SHAREDKEY: string = 'vpn_ipsec_sharedKey_value';
const SWANCTL_IKE2_IPSEC_MSCHAPV2_PATH: string = 'ike2_ipsec_mschapv2/swanctl.conf';
const STRONGSWAN_IKE2_IPSEC_MSCHAPV2_PATH: string = 'ike2_ipsec_mschapv2/strongswan.conf';
const SWANCTL_IKE2_IPSEC_RSA_PATH: string = 'ike2_ipsec_rsa/swanctl.conf';
const STRONGSWAN_IKE2_IPSEC_RSA_PATH: string = 'ike2_ipsec_rsa/strongswan.conf';
const SWANCTL_IKE2_IPSEC_PSK_PATH: string = 'ike2_ipsec_psk/swanctl.conf';
const STRONGSWAN_IKE2_IPSEC_PSK_PATH: string = 'ike2_ipsec_psk/strongswan.conf';
const SWANCTL_IPSEC_XAUTH_PSK_PATH: string = 'ipsec_xauth_psk/swanctl.conf';
const STRONGSWAN_IPSEC_XAUTH_PSK_PATH: string = 'ipsec_xauth_psk/strongswan.conf';
const SWANCTL_IPSEC_XAUTH_RSA_PATH: string = 'ipsec_xauth_rsa/swanctl.conf';
const STRONGSWAN_IPSEC_XAUTH_RSA_PATH: string = 'ipsec_xauth_rsa/strongswan.conf';
const STRONGSWAN_L2TP_IPSEC_RSA_PATH: string = 'l2tp_ipsec_rsa/strongswan.conf';
const STRONGSWAN_L2TP_IPSEC_PSK_PATH: string = 'l2tp_ipsec_psk/strongswan.conf';
const CLIENT_L2TP_IPSEC_PSK_PATH: string = 'l2tp_ipsec_psk/options.l2tpd.client.conf';
const CLIENT_L2TP_IPSEC_RSA_PATH: string = 'l2tp_ipsec_rsa/options.l2tpd.client.conf';
const XL2TPD_L2TP_IPSEC_PSK_PATH: string = 'l2tp_ipsec_psk/xl2tpd.conf';
const XL2TPD_L2TP_IPSEC_RSA_PATH: string = 'l2tp_ipsec_rsa/xl2tpd.conf';
const IPSECCONF_L2TP_IPSEC_PSK_PATH: string = 'l2tp_ipsec_psk/ipsec.conf';
const IPSECCONF_L2TP_IPSEC_RSA_PATH: string = 'l2tp_ipsec_rsa/ipsec.conf';
const IPSEC_SECRETS_L2TP_IPSEC_PSK_PATH: string = 'l2tp_ipsec_psk/ipsec.secrets.conf';
const IPSEC_SECRETS_L2TP_IPSEC_RSA_PATH: string = 'l2tp_ipsec_rsa/ipsec.secrets.conf';
const SWANCTL_IPSEC_HYBRID_RSA_PATH: string = 'ipsec_hybrid_rsa/swanctl.conf';
const STRONGSWAN_IPSEC_HYBRID_RSA_PATH: string = 'ipsec_hybrid_rsa/strongswan.conf';

/**
 * swanctl config model
 *
 * @since 2024-06-15
 */
export class SwanCtlModel {
  private context: common.UIAbilityContext = undefined;
  private swanCtlMap = new HashMap<number, string>();
  private strongSwanMap = new HashMap<number, string>();
  private l2tpdClientMap = new HashMap<number, string>();
  private xl2tpdMap = new HashMap<number, string>();
  private ipsecConfMap = new HashMap<number, string>();
  private ipsecSecretsMap = new HashMap<number, string>();

  private static instance: SwanCtlModel;

  public static getInstance(): SwanCtlModel {
    if (!this.instance) {
      this.instance = new SwanCtlModel();
    }
    return this.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    if (!context) {
      LogUtil.error(`${MODULE_TAG} init failed, param is error`);
      return;
    }
    this.context = context;
    this.readTemplate();
  }

  public release(): void {
    this.context = undefined;
  }

  public buildConfig(ipsec: IpsecVpnConfig): void {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} buildConfig failed, param is error`);
      return;
    }
    let helper: util.Base64Helper = new util.Base64Helper();
    if (ipsec.vpnType !== VpnTypeModel.TYPE_L2TP_IPSEC_PSK && ipsec.vpnType !== VpnTypeModel.TYPE_L2TP_IPSEC_RSA) {
      ipsec.swanctlConfig = helper.encodeToStringSync(this.ipsec2swanCtl(ipsec));
    }
    ipsec.strongSwanConfig = helper.encodeToStringSync(this.ipsec2strongSwan(ipsec));
    if (ipsec.vpnType === VpnTypeModel.TYPE_L2TP_IPSEC_PSK || ipsec.vpnType === VpnTypeModel.TYPE_L2TP_IPSEC_RSA) {
      ipsec.optionsL2tpdClient = helper.encodeToStringSync(this.ipsec2L2tpdClient(ipsec));
      ipsec.xl2tpdConfig = helper.encodeToStringSync(this.ipsec2Xl2tpd(ipsec));
      ipsec.ipsecConfig = helper.encodeToStringSync(this.ipsec2IpsecConf(ipsec));
      ipsec.ipsecSecrets = helper.encodeToStringSync(this.ipsec2IpsecSecrets(ipsec));
    }
  }

  private ipsec2swanCtl(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2swanCtl failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.swanCtlMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.swanCtlMap.get(ipsec.vpnType);
    let vpnTemplate = String(template);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_ADDRESS, VpnConfigModel.getInstance().getAddress(ipsec));
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_IPSEC_IDENTIFIER, ipsec.ipsecIdentifier);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_IPSEC_SHAREDKEY, ipsec.ipsecPreSharedKey);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_USERNAME, ipsec.userName);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_PASSWORD, ipsec.password);

    let swanCtl = CommonUtils.stringToUint8Array(vpnTemplate);
    return swanCtl;
  }

  private ipsec2strongSwan(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2strongSwan failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.strongSwanMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.strongSwanMap.get(ipsec.vpnType);
    let strongSwan = CommonUtils.stringToUint8Array(String(template));
    return strongSwan;
  }

  private ipsec2Xl2tpd(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2Xl2tpd failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.xl2tpdMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.xl2tpdMap.get(ipsec.vpnType);
    let vpnTemplate = String(template);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_ADDRESS, VpnConfigModel.getInstance().getAddress(ipsec));
    let xl2tpd = CommonUtils.stringToUint8Array(vpnTemplate);
    return xl2tpd;
  }

  private ipsec2L2tpdClient(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2L2tpdClient failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.l2tpdClientMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.l2tpdClientMap.get(ipsec.vpnType);
    let vpnTemplate = String(template);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_USERNAME, ipsec.userName);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_PASSWORD, ipsec.password);
    let xl2tpd = CommonUtils.stringToUint8Array(vpnTemplate);
    return xl2tpd;
  }

  private ipsec2IpsecConf(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2IpsecConf failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.ipsecConfMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.ipsecConfMap.get(ipsec.vpnType);
    let vpnTemplate = String(template);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_ADDRESS, VpnConfigModel.getInstance().getAddress(ipsec));
    let ipsecConf = CommonUtils.stringToUint8Array(vpnTemplate);
    return ipsecConf;
  }

  private ipsec2IpsecSecrets(ipsec: IpsecVpnConfig): Uint8Array {
    if (!ipsec) {
      LogUtil.error(`${MODULE_TAG} ipsec2IpsecSecrets failed, param is error`);
      return new Uint8Array([]);
    }
    if (this.ipsecSecretsMap.isEmpty()) {
      this.readTemplate();
    }
    let template = this.ipsecSecretsMap.get(ipsec.vpnType);
    let vpnTemplate = String(template);
    vpnTemplate = this.replaceConfigParam(vpnTemplate, KEY_VPN_IPSEC_SHAREDKEY, ipsec.ipsecPreSharedKey);
    let ipsecSecrets = CommonUtils.stringToUint8Array(vpnTemplate);
    return ipsecSecrets;
  }

  private readTemplate(): void {
    // swanctl.config
    this.swanCtlMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2, SWANCTL_IKE2_IPSEC_MSCHAPV2_PATH);
    this.swanCtlMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_RSA, SWANCTL_IKE2_IPSEC_RSA_PATH);
    this.swanCtlMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_PSK, SWANCTL_IKE2_IPSEC_PSK_PATH);
    this.swanCtlMap.set(VpnTypeModel.TYPE_IPSEC_XAUTH_PSK, SWANCTL_IPSEC_XAUTH_PSK_PATH);
    this.swanCtlMap.set(VpnTypeModel.TYPE_IPSEC_XAUTH_RSA, SWANCTL_IPSEC_XAUTH_RSA_PATH);
    this.swanCtlMap.set(VpnTypeModel.TYPE_IPSEC_HYBRID_RSA, SWANCTL_IPSEC_HYBRID_RSA_PATH);
    this.readRawFile(this.swanCtlMap);

    // strongSwan.config
    this.strongSwanMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2, STRONGSWAN_IKE2_IPSEC_MSCHAPV2_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_RSA, STRONGSWAN_IKE2_IPSEC_RSA_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_IKEV2_IPSEC_PSK, STRONGSWAN_IKE2_IPSEC_PSK_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_IPSEC_XAUTH_PSK, STRONGSWAN_IPSEC_XAUTH_PSK_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_IPSEC_XAUTH_RSA, STRONGSWAN_IPSEC_XAUTH_RSA_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_IPSEC_HYBRID_RSA, STRONGSWAN_IPSEC_HYBRID_RSA_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_PSK, STRONGSWAN_L2TP_IPSEC_PSK_PATH);
    this.strongSwanMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_RSA, STRONGSWAN_L2TP_IPSEC_RSA_PATH);
    this.readRawFile(this.strongSwanMap);

    // xl2tpd.conf
    this.xl2tpdMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_PSK, XL2TPD_L2TP_IPSEC_PSK_PATH);
    this.xl2tpdMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_RSA, XL2TPD_L2TP_IPSEC_RSA_PATH);
    this.readRawFile(this.xl2tpdMap);

    // options.l2tpd.client.conf
    this.l2tpdClientMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_PSK, CLIENT_L2TP_IPSEC_PSK_PATH);
    this.l2tpdClientMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_RSA, CLIENT_L2TP_IPSEC_RSA_PATH);
    this.readRawFile(this.l2tpdClientMap);

    // ipsec.conf
    this.ipsecConfMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_PSK, IPSECCONF_L2TP_IPSEC_PSK_PATH);
    this.ipsecConfMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_RSA, IPSECCONF_L2TP_IPSEC_RSA_PATH);
    this.readRawFile(this.ipsecConfMap);

    // ipsec.secrets.conf
    this.ipsecSecretsMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_PSK, IPSEC_SECRETS_L2TP_IPSEC_PSK_PATH);
    this.ipsecSecretsMap.set(VpnTypeModel.TYPE_L2TP_IPSEC_RSA, IPSEC_SECRETS_L2TP_IPSEC_RSA_PATH);
    this.readRawFile(this.ipsecSecretsMap);
  }

  private readRawFile(pathMap: HashMap<number, string>): void {
    if (!pathMap) {
      LogUtil.error(`${MODULE_TAG} readRawFile failed, param is error`);
      return;
    }
    try {
      pathMap.forEach((path, key) => {
        let value: Uint8Array = this.context.resourceManager.getRawFileContentSync(path as string);
        let valStr: string = CommonUtils.uint8ArrayToString(value);
        let contentStr: string = valStr.replace(/\r\n/g, '\n');
        pathMap.set(key, contentStr);
      });
    } catch (error) {
      LogUtil.error(`${MODULE_TAG} callback getRawfileContent failed, error: ${error}`);
    }
  }

  private replaceConfigParam(vpnTemplate: string, key: string, value: string): string {
    if (!value || !key) {
      LogUtil.warn(`${MODULE_TAG} replaceConfigParam failed, params is null or undefined`);
      return vpnTemplate;
    }
    while (vpnTemplate.indexOf(key) !== -1) {
      vpnTemplate = vpnTemplate.replace(key, value.trim());
    }
    return vpnTemplate;
  }
}