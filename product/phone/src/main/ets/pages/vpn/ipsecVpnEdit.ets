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

import { util } from '@kit.ArkTS';
import { TextWithInput, SelectFile, INPUT_TYPE_IP, INPUT_TYPE_PWD, Selector, SELECTER_CERT } from './customComponent';
import { IpsecVpnConfig } from '../../model/vpnImpl/VpnConfig';
import { VpnTypeModel } from '../../model/vpnImpl/VpnTypeModel';
import { VpnConfigModel, VpnCertItem} from '../../model/vpnImpl/VpnConfigModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';

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
  @State caSheetInfos: SheetInfo[] = [];
  @State caSheetSelectedId: number = 0;
  @State userCertSheetTitles: string[] = [];
  @State userCertSheetInfos: SheetInfo[] = [];
  @State userCertSheetSelectedId: number = 0;
  @State serverCertSheetTitles: string[] = [];
  @State serverCertSheetInfos: SheetInfo[] = [];
  @State serverCertSheetSelectedId: number = 0;

  vpnType: number = 0;
  base64Util = new util.Base64Helper();

  aboutToAppear() {
    this.vpnAddress = VpnConfigModel.getInstance().getAddress(this.vpnConfig) ?? '';
    let dnsAddresses = this.vpnConfig.dnsAddresses;
    if (dnsAddresses) {
      this.dnsAddress = dnsAddresses[0];
    }
    this.initCertList();
    this.updateUI();
  }

  initCertList() {
    // init ca list
    this.caSheetTitles = [ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_verify_server'))];
    this.caSheetInfos = [{
      title: ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_verify_server')),
      action: () => {
        this.vpnConfig.ipsecCaCertConfig = '';
        this.caSheetSelectedId = 0;
        this.onNonNullableParamChange();
      }
    }];
    // get ca list
    VpnConfigModel.getInstance().getCAList((error: number, list: VpnCertItem[]) => {
      LogUtil.info('getCAList size:' + list?.length + ' error:' + error);
      list?.forEach(cert => {
        this.caSheetTitles.push(cert.certAlias);
        this.caSheetInfos.push({
          title: cert.certAlias,
          action: () => {
              LogUtil.debug('select ca cert:' + JSON.stringify(cert));
              this.vpnConfig.ipsecCaCertConfig = cert.certUri;
              this.caSheetSelectedId = list.indexOf(cert) + 1;
              this.onNonNullableParamChange();
            }
          })
        // reset selected id
        if (this.vpnConfig.ipsecCaCertConfig === cert.certUri) {
          this.caSheetSelectedId = list.indexOf(cert) + 1;
        }
      });
    })

    // init user cert list
    this.userCertSheetTitles = [ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_specified'))];
    this.userCertSheetInfos = [{
      title: ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_specified')),
      action: () => {
        this.vpnConfig.ipsecPublicUserCertConfig = '';
        this.userCertSheetSelectedId = 0;
        this.onNonNullableParamChange();
      }
    }];
    // get user cert list
    VpnConfigModel.getInstance().getSystemAppCertList((error: number, list: VpnCertItem[]) => {
      LogUtil.info('get user cert list size:' + list?.length + ' error:' + error);
      list?.forEach(cert => {
        this.userCertSheetTitles.push(cert.certAlias);
        this.userCertSheetInfos.push({
          title: cert.certAlias,
          action: () => {
            LogUtil.debug('select user cert:' + JSON.stringify(cert));
            this.vpnConfig.ipsecPublicUserCertConfig = cert.certUri;
            this.userCertSheetSelectedId = list.indexOf(cert) + 1;
            this.onNonNullableParamChange();
          }
        })
        // reset selected id
        if (this.vpnConfig.ipsecPublicUserCertConfig === cert.certUri) {
          this.userCertSheetSelectedId = list.indexOf(cert) + 1;
        }
      });
    })

    // init server cert list
    this.serverCertSheetTitles = [ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_from_server'))];
    this.serverCertSheetInfos = [{
      title: ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_verify_server')),
      action: () => {
        this.vpnConfig.ipsecPublicServerCertConfig = '';
        this.serverCertSheetSelectedId = 0;
        this.onNonNullableParamChange();
      }
    }];
    // get server cert list
    VpnConfigModel.getInstance().getSystemAppCertList((error: number, list: VpnCertItem[]) => {
      LogUtil.info('get server cert list size:' + list?.length + ' error:' + error);
      list?.forEach(cert => {
        this.serverCertSheetTitles.push(cert.certAlias);
        this.serverCertSheetInfos.push({
          title: cert.certAlias,
          action: () => {
            LogUtil.debug('select server cert' + JSON.stringify(cert));
            this.vpnConfig.ipsecPublicServerCertConfig = cert.certUri;
            this.serverCertSheetSelectedId = list.indexOf(cert) + 1;
            this.onNonNullableParamChange();
          }
        })
        // reset selected id
        if (this.vpnConfig.ipsecPublicServerCertConfig === cert.certUri) {
          this.serverCertSheetSelectedId = list.indexOf(cert) + 1;
        }
      });
    })
  }

  updateUI() {
    this.updateIpsecIdentifierVisibility();
    this.updateL2tpSecretVisibility();
    this.updateIpsecSecretVisibility();
    this.updateUserCertVisibility();
    this.updateCaServerCertVisibility();
  }

  onVpnConfigChange() {
    if (this.vpnType !== this.vpnConfig.vpnType) {
      LogUtil.info('onVpnConfigChange ' + this.vpnType + '->' + this.vpnConfig.vpnType);
      this.vpnType = this.vpnConfig.vpnType;
      this.updateUI();
    }
  }

  onNonNullableParamChange(): void {
    let isNonNullParamReady = true;
    if (!VpnConstant.REGEX_IP.test(this.vpnAddress)) {
      isNonNullParamReady = false;
    }
    if (this.dnsAddress.length >0 && !VpnConstant.REGEX_IP.test(this.dnsAddress)) {
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
    Column() {
      TextWithInput({
        title: $r('app.string.vpn_edit_serveraddress'),
        inputPlaceholder: '',
        inputText: this.vpnAddress,
        inputType: INPUT_TYPE_IP,
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
        inputType: INPUT_TYPE_PWD,
        onChange: (value: string) => {
          this.vpnConfig.l2tpSharedKey = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.l2tpSecretVisibility)
      TextWithInput({
        title: $r('app.string.vpn_edit_ipsecidentifier'),
        inputPlaceholder: $r('app.string.vpn_edit_unuse'),
        inputText: this.vpnConfig.ipsecIdentifier,
        onChange: (value: string) => {
          this.vpnConfig.ipsecIdentifier = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.ipsecIdentifierVisibility)
      TextWithInput({
        title: $r('app.string.vpn_edit_ipsecsecret'),
        inputText: this.vpnConfig.ipsecPreSharedKey,
        inputType: INPUT_TYPE_PWD,
        onChange: (value: string) => {
          this.vpnConfig.ipsecPreSharedKey = value.trim();
          this.onNonNullableParamChange();
        }
      }).visibility(this.ipsecSecretVisibility)

      Selector({
        title: $r('app.string.vpn_edit_usercert'),
        vpnConfig: this.vpnConfig,
        type: SELECTER_CERT,
        sheetTitles: this.userCertSheetTitles,
        sheetInfos: this.userCertSheetInfos,
        certSelectedId: this.userCertSheetSelectedId
      }).margin({ top: 15 })
        .visibility(this.userCertVisibility)

      Selector({
        title: $r('app.string.vpn_edit_cacert'),
        vpnConfig: this.vpnConfig,
        type: SELECTER_CERT,
        sheetTitles: this.caSheetTitles,
        sheetInfos: this.caSheetInfos,
        certSelectedId: this.caSheetSelectedId
      }).margin({ top: 10 })
        .visibility(this.caServerCertVisibility)

      Selector({
        title: $r('app.string.vpn_edit_servercert'),
        vpnConfig: this.vpnConfig,
        type: SELECTER_CERT,
        sheetTitles: this.serverCertSheetTitles,
        sheetInfos: this.serverCertSheetInfos,
        certSelectedId: this.serverCertSheetSelectedId
      }).margin({ top: 10, bottom: 10 })
        .visibility(this.caServerCertVisibility)

      Row({ space: 10 }) {
        Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).onChange((value) => {
          this.advanceChecked = value;
        })
        Text($r('app.string.vpn_edit_advanced'))
      }.width('100%').margin({ left: 4 })
      Column({ space: 10 }) {
        TextWithInput({
          title: $r('app.string.vpn_edit_searchdomains'),
          inputPlaceholder: $r('app.string.vpn_edit_unuse'),
          inputText: this.vpnConfig.searchDomains?.[0],
          onChange: (value: string) => {
            this.vpnConfig.searchDomains = [value.trim()];
          }
        })
        TextWithInput({
          title: $r('app.string.vpn_edit_dnsaddresses'),
          inputPlaceholder: $r('app.string.vpn_edit_unuse'),
          inputText: this.dnsAddress,
          inputType: INPUT_TYPE_IP,
          onChange: (value: string) => {
            this.dnsAddress = value.trim();
            this.vpnConfig.dnsAddresses = [this.dnsAddress];
            this.onNonNullableParamChange();
          }
        })
        TextWithInput({
          title: $r('app.string.vpn_edit_router'),
          inputPlaceholder: $r('app.string.vpn_edit_unuse'),
          inputText: this.vpnConfig.forwardingRoutes,
          onChange: (value: string) => {
            this.vpnConfig.forwardingRoutes = value.trim();
          }
        })
      }.width('100%')
      .alignItems(HorizontalAlign.Start)
      .visibility(this.advanceChecked ? Visibility.Visible : Visibility.None)
    }
  }
}