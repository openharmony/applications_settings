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
import resourceManager from '@ohos.resourceManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { TextWithInput, Selector, SelectFile } from './CustomComponent';
import { OpenVpnConfig } from './model/VpnConfig';
import { VpnConfigModel, VpnCertItem } from './model/VpnConfigModel';
import VpnConstant from './model/VpnConstant';
import { CommonUtils } from './utils/CommonUtils';

/* instrument ignore file */
const MODULE_TAG: string = 'openVpnEdit:';
const OPEN_VPN_AUTH_TYPE_ID: string = 'open_vpn_auth_type_id';
const OPEN_VPN_DISPLAY_PROXY_ID: string = 'open_vpn_display_proxy_id';
const OPEN_VPN_PRIVATE_PWD_ID: string = 'open_vpn_private_pwd_id';
const OPEN_VPN_PROTOCOL_ID: string = 'openvpn_protocol_id';
const OPEN_VPN_PROXY_HOST_ID: string = 'open_vpn_proxy_host_id';
const OPEN_VPN_PROXY_PORT_ID: string = 'open_vpn_proxy_port_id';
const OPEN_VPN_PROXY_USERNAME_ID: string = 'open_vpn_proxy_username_id';
const OPEN_VPN_PROXY_PASSWORD_ID: string = 'open_vpn_proxy_password_id';
const OPEN_VPN_SERVER_ADDRESS_ID: string = 'openvpn_server_address_id';
const OPEN_VPN_SERVER_PORT_ID: string = 'openvpn_server_port_id';
const VPN_EDIT_ADVANCED_ID: string = 'vpn_edit_advanced_id';
const VPN_EDIT_COLLAPSE_ID: string = 'vpn_edit_collapse_id';

/**
 * OpenVpn Edit View
 *
 * @since 2024-06-15
 */
@Component
export default struct OpenVpnEdit {
  onSaveBtnEnableChange: Function = (enabled: boolean) => {};
  @State vpnConfig: OpenVpnConfig = new OpenVpnConfig();
  @State vpnAddress: string = '';
  @State vpnPort: string = '';
  @State isShowSelectFile: boolean = true;
  @State ovpnAdvanceChecked: boolean = false;
  @State ovpnProxyChecked: boolean = false;
  @State ovpnProxyHost: string = '';
  @State ovpnProxyPort: string = '';
  @State caSheetTitles: string[] = [];
  @State caSheetSelectedId: number = 0;
  @State userCertSheetTitles: string[] = [];
  @State userCertSheetSelectedId: number = 0;
  @State caList: VpnCertItem[] = [];
  @State userCertList: VpnCertItem[] = [];
  ovpnProtocolSheetTitles: string[] = [];
  ovpnAuthSheetTitles: string[] = [];

  aboutToAppear(): void {
    try {
      let resMgr: resourceManager.ResourceManager = getContext().resourceManager;
      this.vpnConfig.ovpnProtocol = this.vpnConfig.ovpnProtocol ?? 0;
      this.ovpnProtocolSheetTitles = resMgr.getStringArrayValueSync($r('app.strarray.ovpn_protocol').id);
      this.vpnConfig.ovpnAuthType = this.vpnConfig.ovpnAuthType ?? 0;
      this.ovpnAuthSheetTitles = resMgr.getStringArrayValueSync($r('app.strarray.ovpen_auth_type').id);

      if (this.vpnConfig.ovpnConfig) {
        let that = new util.Base64Helper();
        let data = that.decodeSync(this.vpnConfig.ovpnConfig);
        let content: string = CommonUtils.uint8ArrayToString(data);
        let regex: RegExp = /remote\s(.+?)\s\d+/;
        let match: RegExpExecArray | null = regex.exec(content);
        if (match) {
          let vpnAddress: string = match && match[1];
          VpnConfigModel.getInstance().setAddress(this.vpnConfig, vpnAddress)
        }
      }
    } catch (error) {
      LogUtil.error(`${MODULE_TAG} getStringArrayValueSync failed, error: ${error}.`);
    }

    this.initCertList();
    this.updateUI();
  }

  updateUI(): void {
    this.vpnAddress = VpnConfigModel.getInstance().getAddress(this.vpnConfig) ?? '';
    this.vpnPort = this.vpnConfig.ovpnPort ?? '';
    this.isShowSelectFile = (this.vpnConfig.ovpnConfigFilePath || this.vpnPort === '') ? true : false;
    // update proxy info
    if (this.vpnConfig.ovpnConfig) {
      let helper = new util.Base64Helper();
      let content = CommonUtils.uint8ArrayToString(helper.decodeSync(this.vpnConfig.ovpnConfig));
      let regex = /http-proxy\s+([^\s]+)\s+(\d+)/;
      let match = regex.exec(content);
      if (match && match.length >= 3) {
        this.vpnConfig.ovpnProxyHost = match[1];
        this.vpnConfig.ovpnProxyPort = match[2];
      }
      regex = /<http-proxy-user-pass>\s*([\s\S]+?)\s*(\r?\n|\r)\s*([\s\S]+?)\s*<\/http-proxy-user-pass>/;
      match = regex.exec(content);
      if (match && match.length >= 4) {
        this.vpnConfig.ovpnProxyUser = match[1];
        this.vpnConfig.ovpnProxyPass = match[3];
      }
    }
  }

  initCertList(): void {
    // init ca list
    this.caSheetTitles = [ResourceUtil.getStringSync($r('app.string.vpn_edit_cert_not_verify_server'))];
    // get ca list
    VpnConfigModel.getInstance().getCAList().then((list: VpnCertItem[]) => {
      if (list && list.length > 0) {
        list.forEach(cert => {
          this.caList = list;
          this.caSheetTitles.push(cert.certAlias);
          // reset selected id
          if (this.vpnConfig.ovpnCaCert?.concat(cert.certUri)) {
            this.caSheetSelectedId = list.indexOf(cert) + 1;
          }
        });
      }
    })

    // init user cert list
    this.userCertSheetTitles = [ResourceUtil.getStringSync($r('app.string.vpn_edit_cert_not_specified'))];
    // get user cert list
    VpnConfigModel.getInstance().getSystemAppCertList().then((list: VpnCertItem[]) => {
      if (!list || list.length <= 0) {
        return;
      }
      list.forEach(cert => {
        this.userCertList = list;
        this.userCertSheetTitles.push(cert.certAlias);
        // reset selected id
        if (this.vpnConfig.ovpnUserCert?.concat(cert.certUri)) {
          this.userCertSheetSelectedId = list.indexOf(cert) + 1;
        }
      });
    })
  }

  onNonNullableParamChange(): void {
    let isNonNullParamReady = true;
    if (!VpnConstant.REGEX_IP.test(this.vpnAddress) || !VpnConstant.REGEX_PORT.test(this.vpnPort)) {
      isNonNullParamReady = false;
    }
    if (this.ovpnProxyHost.length > 0 && !VpnConstant.REGEX_IP.test(this.ovpnProxyHost)) {
      isNonNullParamReady = false;
    }
    if (this.ovpnProxyPort.length > 0 && !VpnConstant.REGEX_PORT.test(this.ovpnProxyPort)) {
      isNonNullParamReady = false;
    }
    this.onSaveBtnEnableChange(isNonNullParamReady);
  }

  build() {
    Column({ space: 12 }) {
      SelectFile({
        title: $r('app.string.vpn_edit_ovpn_configfile'),
        fileName: this.vpnConfig.ovpnConfigFilePath,
        vpnConfig: this.vpnConfig,
        callback: (result: string[]) => {
          VpnConfigModel.getInstance().inflateConfigFromFileData(this.vpnConfig, result);
          this.updateUI();
        }
      }).visibility(this.isShowSelectFile ? Visibility.Visible : Visibility.None)

      TextWithInput({
        title: $r('app.string.vpn_edit_ovpn_serveraddress'),
        inputPlaceholder: $r('app.string.vpn_edit_unuse'),
        inputText: this.vpnAddress,
        inputType: VpnConstant.INPUT_TYPE_IP,
        textInputId: OPEN_VPN_SERVER_ADDRESS_ID,
        onChange: (value: string) => {
          this.vpnAddress = value.trim();
          VpnConfigModel.getInstance().setAddress(this.vpnConfig, this.vpnAddress);
          this.onNonNullableParamChange();
        }
      })

      TextWithInput({
        title: $r('app.string.vpn_edit_ovpn_port'),
        inputPlaceholder: $r('app.string.vpn_edit_unuse'),
        inputText: this.vpnPort,
        inputType: VpnConstant.INPUT_TYPE_PORT,
        textInputId: OPEN_VPN_SERVER_PORT_ID,
        onChange: (value: string) => {
          this.vpnPort = value.trim()
          this.vpnConfig.ovpnPort = this.vpnPort;
          this.onNonNullableParamChange();
        }
      })

      Selector({
        title: $r('app.string.vpn_edit_ovpn_protocol'),
        type: VpnConstant.SELECTOR_OVPN_PROTOCOL,
        selectorTextId: OPEN_VPN_PROTOCOL_ID,
        sheetTitles: this.ovpnProtocolSheetTitles,
        selectedId: this.vpnConfig.ovpnProtocol,
        onSelectedChange: (index: number) => {
          this.vpnConfig.ovpnProtocol = index;
        }
      })

      Row() {
        Text(this.ovpnAdvanceChecked ? $r('app.string.vpn_edit_advanced_expanded') : $r('app.string.vpn_edit_advanced'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.font_14'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .margin({ left: this.ovpnAdvanceChecked ? 8 : 0 })
        Image($r('app.media.ic_vpn_edit_expand'))
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_24'))
          .id(VPN_EDIT_ADVANCED_ID)
          .fillColor($r('sys.color.icon_primary'))
          .opacity($r('app.float.opacity_0_2'))
          .onClick(() => {
            this.ovpnAdvanceChecked = true;
            this.isShowSelectFile = false;
          })
          .visibility(this.ovpnAdvanceChecked ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height(40)
      .justifyContent(this.ovpnAdvanceChecked ? FlexAlign.Start : FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .visibility(this.vpnConfig.ovpnConfigFilePath ? Visibility.None : Visibility.Visible)

      Column({ space: 12 }) {
        Selector({
          title: $r('app.string.vpn_edit_auth_type'),
          type: VpnConstant.SELECTOR_OVPN_AUTH,
          selectorTextId: OPEN_VPN_AUTH_TYPE_ID,
          sheetTitles: this.ovpnAuthSheetTitles,
          selectedId: this.vpnConfig.ovpnAuthType,
          onSelectedChange: (selectedId: number) => {
            this.vpnConfig.ovpnAuthType = selectedId;
          }
        })

        Selector({
          title: $r('app.string.vpn_edit_ovpn_ca_cert_file'),
          type: VpnConstant.SELECTOR_CERT,
          sheetTitles: this.caSheetTitles,
          selectedId: this.caSheetSelectedId,
          onSelectedChange: (selectedId: number) => {
            if (selectedId === 0) {
              this.vpnConfig.ovpnCaCert = '';
              this.caSheetSelectedId = selectedId;
              return;
            }
            let id = selectedId - 1;
            if (id < 0 || id >= this.caList?.length) {
              LogUtil.warn(`${MODULE_TAG} onSelectedChange failed, selectedId=${selectedId}`);
              return;
            }
            LogUtil.info(`${MODULE_TAG} onSelectedChange vpn:${this.caList[id].certAlias}`);
            this.vpnConfig.ovpnCaCert = '<ca>\n' + this.caList[id].certUri + '\n</ca>';
            this.caSheetSelectedId = selectedId;
          }
        })

        Selector({
          title: $r('app.string.vpn_edit_ovpn_user_cert_file'),
          type: VpnConstant.SELECTOR_CERT,
          sheetTitles: this.userCertSheetTitles,
          selectedId: this.userCertSheetSelectedId,
          onSelectedChange: (selectedId: number) => {
            if (selectedId === 0) {
              this.vpnConfig.ovpnUserCert = '';
              this.userCertSheetSelectedId = selectedId;
              return;
            }
            let id = selectedId - 1;
            if (id < 0 || id >= this.userCertList?.length) {
              LogUtil.warn(`${MODULE_TAG} onSelectedChange failed, selectedId=${selectedId}`);
              return;
            }
            LogUtil.info(`${MODULE_TAG} onSelectedChange vpn:${this.userCertList[id].certAlias}`);
            this.vpnConfig.ovpnUserCert = '<cert>\n' + this.userCertList[id].certUri + '\n</cert>';
            this.userCertSheetSelectedId = selectedId;
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_PWD ?
        Visibility.Visible : Visibility.None);

        TextWithInput({
          title: $r('app.string.vpn_edit_ovpn_private_key_psd'),
          inputPlaceholder: '',
          inputText: this.vpnConfig.askpass,
          inputType: VpnConstant.INPUT_TYPE_PWD,
          textInputId: OPEN_VPN_PRIVATE_PWD_ID,
          onChange: (value: string) => {
            this.vpnConfig.askpass = value.trim();
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_PWD ?
        Visibility.Visible : Visibility.None);

        TextWithInput({
          title: $r('app.string.vpn_edit_ovpn_username'),
          inputPlaceholder: '',
          inputText: this.vpnConfig.userName,
          maxLength: VpnConstant.VPN_USER_NAME_MAX_LENGTH,
          onChange: (value: string) => {
            this.vpnConfig.userName = value.trim();
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_TLS ?
        Visibility.Visible : Visibility.None);

        TextWithInput({
          title: $r('app.string.vpn_edit_ovpn_password'),
          inputPlaceholder: '',
          inputText: this.vpnConfig.password,
          inputType: VpnConstant.INPUT_TYPE_PWD,
          maxLength: VpnConstant.VPN_PASSWORD_MAX_LENGTH,
          onChange: (value: string) => {
            this.vpnConfig.password = value.trim();
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_TLS ?
        Visibility.Visible : Visibility.None);

        Row({ space: 10 }) {
          Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).onChange((value) => {
            this.ovpnProxyChecked = value;
          }).id(OPEN_VPN_DISPLAY_PROXY_ID)
          Text($r('app.string.vpn_edit_proxy_advanced'))
        }.width('100%').margin({ left: 4 })

        Column({ space: 12 }) {
          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_host'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.vpnConfig.ovpnProxyHost,
            inputType: VpnConstant.INPUT_TYPE_IP,
            textInputId: OPEN_VPN_PROXY_HOST_ID,
            onChange: (value: string) => {
              this.ovpnProxyHost = value.trim();
              this.vpnConfig.ovpnProxyHost = this.ovpnProxyHost;
              this.onNonNullableParamChange();
            }
          })

          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_port'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.vpnConfig.ovpnProxyPort,
            inputType: VpnConstant.INPUT_TYPE_PORT,
            textInputId: OPEN_VPN_PROXY_PORT_ID,
            onChange: (value: string) => {
              this.ovpnProxyPort = value.trim();
              this.vpnConfig.ovpnProxyPort = this.ovpnProxyPort;
              this.onNonNullableParamChange();
            }
          })

          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_username'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.vpnConfig.ovpnProxyUser,
            textInputId: OPEN_VPN_PROXY_USERNAME_ID,
            onChange: (value: string) => {
              this.vpnConfig.ovpnProxyUser = value.trim();
            }
          })
          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_password'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.vpnConfig.ovpnProxyPass,
            inputType: VpnConstant.INPUT_TYPE_PWD,
            textInputId: OPEN_VPN_PROXY_PASSWORD_ID,
            onChange: (value: string) => {
              this.vpnConfig.ovpnProxyPass = value.trim();
            }
          })
        }.visibility(this.ovpnProxyChecked ? Visibility.Visible : Visibility.None)
      }.visibility(this.ovpnAdvanceChecked ? Visibility.Visible : Visibility.None)

      Row() {
        Text($r('app.string.vpn_edit_advanced_collapse'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('app.float.font_14'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
        Image($r('app.media.ic_vpn_edit_collapse')).width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_12'))
          .id(VPN_EDIT_COLLAPSE_ID)
          .onClick(() => {
            this.ovpnAdvanceChecked = false;
          })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .visibility(this.ovpnAdvanceChecked ? Visibility.Visible : Visibility.None)
    }
  }
}