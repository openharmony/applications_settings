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

import { util } from '@kit.ArkTS';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { TextWithInput, Selector } from './CustomComponent';
import { IpsecVpnConfig } from './model/VpnConfig';
import { VpnConfigModel, VpnCertItem } from './model/VpnConfigModel';
import VpnConstant from './model/VpnConstant';
import { VpnTypeModel } from './model/VpnTypeModel';

/* instrument ignore file */
const MODULE_TAG: string = 'IpsecVpnEdit:';
const ADD_VPN_DNS_SERVER_ID: string = 'dns_server_id';
const ADD_VPN_FORWARD_ROUTER_ID: string = 'forward_router_id';
const ADD_VPN_SERVER_ADDRESS_ID: string = 'add_server_address_id';
const ADD_VPN_SEARCH_DOMAIN_ID: string = 'dns_search_domain_id';
const ADD_VPN_IPSEC_IDENTIFIER_ID: string = 'add_ipsec_identifier_id';
const VPN_EDIT_ADVANCED_ID: string = 'vpn_edit_advanced_id';
const VPN_EDIT_COLLAPSE_ID: string = 'vpn_edit_collapse_id';

/**
 * ipsec vpn view
 *
 * @since 2024-06-15
 */
@Component
export default struct IpsecVpnEdit {
  onSaveBtnEnableChange: Function = (enabled: boolean) => {};
  @State @Watch('onVpnConfigChange') vpnConfig: IpsecVpnConfig = new IpsecVpnConfig();
  @State ipsecIdentifierVisibility: Visibility = Visibility.None;
  @State l2tpSecretVisibility: Visibility = Visibility.None;
  @State ipsecSecretVisibility: Visibility = Visibility.None;
  @State userCertVisibility: Visibility = Visibility.None;
  @State caServerCertVisibility: Visibility = Visibility.None;
  @State advanceChecked: boolean = false;
  @State vpnAddress: string = '';
  @State dnsAddress: string = '';
  @State caSheetTitles: string[] = [];
  @State caSheetSelectedId: number = 0;
  @State userCertSheetTitles: string[] = [];
  @State userCertSheetSelectedId: number = 0;
  @State serverCertSheetTitles: string[] = [];
  @State serverCertSheetSelectedId: number = 0;
  @State caList: VpnCertItem[] = [];
  @State userCertList: VpnCertItem[] = [];
  @State serverCertList: VpnCertItem[] = [];
  vpnType: number = 0;
  base64Util = new util.Base64Helper();

  aboutToAppear(): void {
    this.vpnAddress = VpnConfigModel.getInstance().getAddress(this.vpnConfig) ?? '';
    let dnsAddresses = this.vpnConfig.dnsAddresses;
    if (dnsAddresses && dnsAddresses.length > 0) {
      this.dnsAddress = dnsAddresses[0];
    }
    this.initCertList();
    this.updateUI();
  }

  initCertList(): void {
    // init ca list
    this.caSheetTitles = [ResourceUtil.getStringSync($r('app.string.vpn_edit_cert_not_verify_server'))];
    // get ca list
    VpnConfigModel.getInstance().getCAList().then((list: VpnCertItem[]) => {
      if (list && list.length > 0) {
        this.caList = list;
        list.forEach(cert => {
          this.caSheetTitles.push(cert.certAlias);
          if (this.vpnConfig.ipsecCaCertConfig === cert.certUri) {
            this.caSheetSelectedId = list.indexOf(cert) + 1;
            LogUtil.info(`${MODULE_TAG} caSheetSelectedId=${this.caSheetSelectedId}`);
          }
        });
      }
    })

    // init user cert list
    this.userCertSheetTitles = [ResourceUtil.getStringSync($r('app.string.vpn_edit_cert_not_specified'))];
    // get user cert list
    VpnConfigModel.getInstance().getSystemAppCertList().then((list: VpnCertItem[]) => {
      if (list && list.length > 0) {
        this.userCertList = list;
        list.forEach(cert => {
          this.userCertSheetTitles.push(cert.certAlias);
          if (this.vpnConfig.ipsecPublicUserCertConfig === cert.certUri) {
            this.userCertSheetSelectedId = list.indexOf(cert) + 1;
            LogUtil.info(`${MODULE_TAG} userCertSheetSelectedId=${this.userCertSheetSelectedId}`);
          }
        });
      }
    })

    this.serverCertSheetTitles = [ResourceUtil.getStringSync($r('app.string.vpn_edit_cert_from_server'))];
    VpnConfigModel.getInstance().getSystemAppCertList().then((list: VpnCertItem[]) => {
      if (list && list.length > 0) {
        this.serverCertList = list;
        list.forEach(cert => {
          this.serverCertSheetTitles.push(cert.certAlias);
          if (this.vpnConfig.ipsecPublicServerCertConfig === cert.certUri) {
            this.serverCertSheetSelectedId = list.indexOf(cert) + 1;
            LogUtil.info(`${MODULE_TAG} serverCertSheetSelectedId=${this.serverCertSheetSelectedId}`);
          }
        });
      }
    })
  }

  updateUI(): void {
    this.updateIpsecIdentifierVisibility();
    this.updateL2tpSecretVisibility();
    this.updateIpsecSecretVisibility();
    this.updateUserCertVisibility();
    this.updateCaServerCertVisibility();
  }

  onVpnConfigChange(): void {
    if (this.vpnType !== this.vpnConfig.vpnType) {
      LogUtil.info(`${MODULE_TAG} onVpnConfigChange ${this.vpnType} -> ${this.vpnConfig.vpnType}`);
      this.vpnType = this.vpnConfig.vpnType;
      this.updateUI();
    }
  }

  onNonNullableParamChange(): void {
    let isNonNullParamReady = true;
    if (this.vpnAddress.trim().length == 0) {
      isNonNullParamReady = false;
    }
    if (this.dnsAddress.length > 0 && !VpnConstant.REGEX_IP.test(this.dnsAddress)) {
      isNonNullParamReady = false;
    }
    if (this.vpnConfig.vpnType !== VpnTypeModel.TYPE_L2TP_IPSEC_PSK) {
      if (this.ipsecIdentifierVisibility === Visibility.Visible && !this.vpnConfig.ipsecIdentifier) {
        isNonNullParamReady = false;
      }
      if (this.l2tpSecretVisibility === Visibility.Visible && !this.vpnConfig.l2tpSharedKey) {
        isNonNullParamReady = false;
      }
    }
    if (this.ipsecSecretVisibility === Visibility.Visible && !this.vpnConfig.ipsecPreSharedKey) {
      isNonNullParamReady = false;
    }
    this.onSaveBtnEnableChange(isNonNullParamReady);
  }

  updateIpsecIdentifierVisibility(): void {
    switch (this.vpnConfig.vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2:
      case VpnTypeModel.TYPE_IKEV2_IPSEC_PSK:
      case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA:
      case VpnTypeModel.TYPE_L2TP_IPSEC_PSK:
      case VpnTypeModel.TYPE_IPSEC_XAUTH_PSK:
        this.ipsecIdentifierVisibility = Visibility.Visible;
        break;
      default:
        this.ipsecIdentifierVisibility = Visibility.None;
        break;
    }
  }

  updateL2tpSecretVisibility(): void {
    switch (this.vpnConfig.vpnType) {
      case VpnTypeModel.TYPE_L2TP_IPSEC_PSK:
      case VpnTypeModel.TYPE_L2TP_IPSEC_RSA:
        this.l2tpSecretVisibility = Visibility.Visible;
        break;
      default:
        this.l2tpSecretVisibility = Visibility.None;
        break;
    }
  }

  updateIpsecSecretVisibility(): void {
    switch (this.vpnConfig.vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_PSK:
      case VpnTypeModel.TYPE_L2TP_IPSEC_PSK:
      case VpnTypeModel.TYPE_IPSEC_XAUTH_PSK:
        this.ipsecSecretVisibility = Visibility.Visible;
        break;
      default:
        this.ipsecSecretVisibility = Visibility.None;
        break;
    }
  }

  updateUserCertVisibility(): void {
    switch (this.vpnConfig.vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA:
      case VpnTypeModel.TYPE_L2TP_IPSEC_RSA:
      case VpnTypeModel.TYPE_IPSEC_XAUTH_RSA:
        this.userCertVisibility = Visibility.Visible;
        break;
      default:
        this.userCertVisibility = Visibility.None;
        break;
    }
  }

  updateCaServerCertVisibility(): void {
    switch (this.vpnConfig.vpnType) {
      case VpnTypeModel.TYPE_IKEV2_IPSEC_MSCHAPv2:
      case VpnTypeModel.TYPE_IKEV2_IPSEC_RSA:
      case VpnTypeModel.TYPE_L2TP_IPSEC_RSA:
      case VpnTypeModel.TYPE_IPSEC_XAUTH_RSA:
      case VpnTypeModel.TYPE_IPSEC_HYBRID_RSA:
        this.caServerCertVisibility = Visibility.Visible;
        break;
      default:
        this.caServerCertVisibility = Visibility.None;
        break;
    }
  }

  build() {
    Column({ space: 12 }) {
      TextWithInput({
        title: $r('app.string.vpn_edit_serveraddress'),
        inputPlaceholder: $r('app.string.please_enter'),
        inputText: this.vpnAddress,
        textInputId: ADD_VPN_SERVER_ADDRESS_ID,
        onChange: (value: string) => {
          this.vpnAddress = value.trim();
          VpnConfigModel.getInstance().setAddress(this.vpnConfig, this.vpnAddress);
          this.onNonNullableParamChange();
        }
      })
      TextWithInput({
        title: $r('app.string.vpn_edit_l2tpsecret'),
        inputPlaceholder: $r('app.string.vpn_edit_unuse'),
        inputText: this.vpnConfig.l2tpSharedKey,
        inputType: VpnConstant.INPUT_TYPE_PWD,
        onChange: (value: string) => {
          this.vpnConfig.l2tpSharedKey = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.l2tpSecretVisibility)
      TextWithInput({
        title: $r('app.string.vpn_edit_ipsecidentifier'),
        inputPlaceholder: $r('app.string.vpn_edit_unuse'),
        inputText: this.vpnConfig.ipsecIdentifier,
        textInputId: ADD_VPN_IPSEC_IDENTIFIER_ID,
        onChange: (value: string) => {
          this.vpnConfig.ipsecIdentifier = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.ipsecIdentifierVisibility)
      TextWithInput({
        title: $r('app.string.vpn_edit_ipsecsecret'),
        inputText: this.vpnConfig.ipsecPreSharedKey,
        inputType: VpnConstant.INPUT_TYPE_PWD,
        onChange: (value: string) => {
          this.vpnConfig.ipsecPreSharedKey = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.ipsecSecretVisibility)

      Selector({
        title: $r('app.string.vpn_edit_usercert'),
        type: VpnConstant.SELECTOR_CERT,
        sheetTitles: this.userCertSheetTitles,
        selectedId: this.userCertSheetSelectedId,
        onSelectedChange: (selectedId: number) => {
          if (selectedId === 0) {
            this.vpnConfig.ipsecPublicUserCertConfig = '';
            this.userCertSheetSelectedId = selectedId;
            this.onNonNullableParamChange();
            return;
          }
          let id = selectedId - 1;
          if (id < 0 || id >= this.userCertList?.length) {
            LogUtil.warn(`${MODULE_TAG} onSelectedChange failed, selectedId=${selectedId}`);
            return;
          }
          LogUtil.info(`${MODULE_TAG} onSelectedChange vpn:${this.userCertList[id].certAlias}`);
          this.vpnConfig.ipsecPublicUserCertConfig = this.userCertList[id].certUri;
          this.userCertSheetSelectedId = selectedId;
          this.onNonNullableParamChange();
        }
      }).visibility(this.userCertVisibility)

      Selector({
        title: $r('app.string.vpn_edit_cacert'),
        type: VpnConstant.SELECTOR_CERT,
        sheetTitles: this.caSheetTitles,
        selectedId: this.caSheetSelectedId,
        onSelectedChange: (selectedId: number) => {
          if (selectedId === 0) {
            this.vpnConfig.ipsecCaCertConfig = '';
            this.caSheetSelectedId = selectedId;
            this.onNonNullableParamChange();
            return;
          }
          let id = selectedId - 1;
          if (id >= this.caList?.length) {
            LogUtil.warn(`${MODULE_TAG} onSelectedChange failed, selectedId=${selectedId}`);
            return;
          }
          LogUtil.info(`${MODULE_TAG} onSelectedChange vpn:${this.caList[id].certAlias}`);
          this.vpnConfig.ipsecCaCertConfig = this.caList[id].certUri;
          this.caSheetSelectedId = selectedId;
          this.onNonNullableParamChange();
        }
      }).visibility(this.caServerCertVisibility)

      Selector({
        title: $r('app.string.vpn_edit_servercert'),
        type: VpnConstant.SELECTOR_CERT,
        sheetTitles: this.serverCertSheetTitles,
        selectedId: this.serverCertSheetSelectedId,
        onSelectedChange: (selectedId: number) => {
          if (selectedId === 0) {
            this.vpnConfig.ipsecPublicServerCertConfig = '';
            this.serverCertSheetSelectedId = selectedId;
            this.onNonNullableParamChange();
            return;
          }
          let id = selectedId - 1;
          if (id < 0 || id >= this.serverCertList?.length) {
            LogUtil.warn(`${MODULE_TAG} onSelectedChange failed, selectedId=${selectedId}`);
            return;
          }
          LogUtil.info(`${MODULE_TAG} onSelectedChange vpn:${this.serverCertList[id].certAlias}`);
          this.vpnConfig.ipsecPublicServerCertConfig = this.serverCertList[id].certUri;
          this.serverCertSheetSelectedId = selectedId;
          this.onNonNullableParamChange();
        }
      }).visibility(this.caServerCertVisibility)

      Row() {
        Text(this.advanceChecked ? $r('app.string.vpn_edit_advanced_expanded') : $r('app.string.vpn_edit_advanced'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.font_14'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .margin({ left: this.advanceChecked ? 8 : 0 })
        Image($r('app.media.ic_vpn_edit_expand'))
          .fillColor($r('sys.color.icon_primary'))
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_12'))
          .draggable(false)
          .id(VPN_EDIT_ADVANCED_ID)
          .draggable(false)
          .onClick(() => {
            this.advanceChecked = true;
          })
          .visibility(this.advanceChecked ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height(40)
      .justifyContent(this.advanceChecked ? FlexAlign.Start : FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Column({ space: 12 }) {
        TextWithInput({
          title: $r('app.string.vpn_edit_searchdomains'),
          inputPlaceholder: $r('app.string.vpn_edit_unuse'),
          inputText: this.vpnConfig.searchDomains?.[0],
          textInputId: ADD_VPN_SEARCH_DOMAIN_ID,
          onChange: (value: string) => {
            this.vpnConfig.searchDomains = [value.trim()];
          }
        })
        TextWithInput({
          title: $r('app.string.vpn_edit_dnsaddresses'),
          inputPlaceholder: $r('app.string.vpn_dns_tips'),
          inputText: this.dnsAddress,
          inputType: VpnConstant.INPUT_TYPE_IP,
          textInputId: ADD_VPN_DNS_SERVER_ID,
          onChange: (value: string) => {
            this.dnsAddress = value.trim();
            this.vpnConfig.dnsAddresses = [this.dnsAddress];
            this.onNonNullableParamChange();
          }
        })
        TextWithInput({
          title: $r('app.string.vpn_edit_router'),
          inputPlaceholder: $r('app.string.vpn_router_tips'),
          inputText: this.vpnConfig.forwardingRoutes,
          textInputId: ADD_VPN_FORWARD_ROUTER_ID,
          onChange: (value: string) => {
            this.vpnConfig.forwardingRoutes = value.trim();
          }
        })
      }.width('100%')
      .alignItems(HorizontalAlign.Start)
      .visibility(this.advanceChecked ? Visibility.Visible : Visibility.None)

      Row() {
        Text($r('app.string.vpn_edit_advanced_collapse'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.font_14'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
        Image($r('app.media.ic_vpn_edit_collapse'))
          .fillColor($r('sys.color.icon_primary'))
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_12'))
          .id(VPN_EDIT_COLLAPSE_ID)
          .draggable(false)
          .onClick(() => {
            this.advanceChecked = false;
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .visibility(this.advanceChecked ? Visibility.Visible : Visibility.None)
    }
  }
}