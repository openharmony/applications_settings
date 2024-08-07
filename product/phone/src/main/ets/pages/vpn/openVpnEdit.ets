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

import ResourceManager from '@ohos.resourceManager';
import {
  TextWithInput,
  Selector,
  SelectFile,
  SELECTER_OVPN_PROTOCOL,
  SELECTER_OVPN_AUTH,
  SELECTER_CERT,
  INPUT_TYPE_IP,
  INPUT_TYPE_PORT,
  INPUT_TYPE_PWD
} from './customComponent';
import { OpenVpnConfig } from '../../model/vpnImpl/VpnConfig';
import { VpnConfigModel, VpnCertItem } from '../../model/vpnImpl/VpnConfigModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { GlobalContext } from '../../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalContext';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';

@Component
export default struct OpenVpnEdit {
  onSaveBtnEnableChange: Function = (enabled: boolean) => {};
  @State vpnConfig: OpenVpnConfig = new OpenVpnConfig();
  @State vpnAddress: string = '';
  @State vpnPort: string = '';
  @State ovpnAdvanceChecked: boolean = false;
  @State ovpnProxyChecked: boolean = false;
  @State ovpnProxyHost: string = '';
  @State ovpnProxyPort: string = '';
  @State caSheetTitles: string[] = [];
  @State caSheetInfos: SheetInfo[] = [];
  @State caSheetSelectedId: number = 0;
  @State userCertSheetTitles: string[] = [];
  @State userCertSheetInfos: SheetInfo[] = [];
  @State userCertSheetSelectedId: number = 0;

  ovpnProtocolSheetTitles: string[] = [];
  ovpnProtocolSheets: SheetInfo[] = [];
  ovpnAuthSheetTitles: string[] = [];
  ovpnAuthSheets: SheetInfo[] = [];

  aboutToAppear() {
    try {
      let context = GlobalContext.getContext().getObject(GlobalContext.globalKeySettingsAbilityContext) as Context;
      let resMgr: ResourceManager.ResourceManager = context.resourceManager;
      this.vpnConfig.ovpnProtocol = this.vpnConfig.ovpnProtocol ?? 0;
      this.ovpnProtocolSheetTitles = resMgr.getStringArrayValueSync($r('app.strarray.ovpn_protocol').id);
      this.ovpnProtocolSheets = this.ovpnProtocolSheetTitles.map((title, index) => {
        let sheetInfo: SheetInfo = {
          title: title,
          action: () => {
            this.vpnConfig.ovpnProtocol = index;
          }
        }
        return sheetInfo;
      })
      this.vpnConfig.ovpnAuthType = this.vpnConfig.ovpnAuthType ?? 0;
      this.ovpnAuthSheetTitles = resMgr.getStringArrayValueSync($r('app.strarray.ovpn_auth_type').id);
      this.ovpnAuthSheets = this.ovpnAuthSheetTitles.map((title, index) => {
        let sheetInfo: SheetInfo = {
          title: title,
          action: () => {
            this.vpnConfig.ovpnAuthType = index;
          }
        }
        return sheetInfo;
      })
    } catch (error) {
      LogUtil.error(`getStringArrayValueSync failed, error: ${JSON.stringify(error)}.`);
    }

    this.initCertList();
    this.updateUI();
  }

  updateUI() {
    this.vpnAddress = VpnConfigModel.getInstance().getAddress(this.vpnConfig) ?? '';
    this.vpnPort = this.vpnConfig.ovpnPort ?? '';
  }

  initCertList() {
    // init ca list
    this.caSheetTitles = [ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_verify_server'))];
    this.caSheetInfos = [{
      title: ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_verify_server')),
      action: () => {
        this.vpnConfig.ovpnCaCert = '';
        this.caSheetSelectedId = 0;
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
            this.vpnConfig.ovpnCaCert = '<ca>\n' + cert.certUri + '\n</ca>';
            this.caSheetSelectedId = list.indexOf(cert) + 1;
          }
        })
        // reset selected id
        if (this.vpnConfig.ovpnCaCert?.concat(cert.certUri)) {
          this.caSheetSelectedId = list.indexOf(cert) + 1;
        }
      });
    })

    // init user cert list
    this.userCertSheetTitles = [ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_specified'))];
    this.userCertSheetInfos = [{
      title: ResourceUtils.getStringSync($r('app.string.vpn_edit_cert_not_specified')),
      action: () => {
        this.vpnConfig.ovpnUserCert = '';
        this.userCertSheetSelectedId = 0;
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
            this.vpnConfig.ovpnUserCert = '<cert>\n' + cert.certUri + '\n</cert>';
            this.userCertSheetSelectedId = list.indexOf(cert) + 1;
          }
        })
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
    Column() {
      SelectFile({
        title: $r('app.string.vpn_edit_ovpn_configfile'),
        fileName: this.vpnConfig.ovpnConfigFilePath,
        vpnConfig: this.vpnConfig,
        callback: (result: string[]) => {
          VpnConfigModel.getInstance().inflateConfigFromFileData(this.vpnConfig, result);
          this.updateUI();
        }
      });

      TextWithInput({
        title: $r('app.string.vpn_edit_ovpn_serveraddress'),
        inputPlaceholder: '',
        inputText: this.vpnAddress,
        inputType: INPUT_TYPE_IP,
        onChange: (value: string) => {
          this.vpnAddress = value.trim();
          VpnConfigModel.getInstance().setAddress(this.vpnConfig, this.vpnAddress);
          this.onNonNullableParamChange();
        }
      }).margin({ top: 5 })

      TextWithInput({
        title: $r('app.string.vpn_edit_ovpn_port'),
        inputPlaceholder: '',
        inputText: this.vpnPort,
        inputType: INPUT_TYPE_PORT,
        onChange: (value: string) => {
          this.vpnPort = value.trim()
          this.vpnConfig.ovpnPort = this.vpnPort;
          this.onNonNullableParamChange();
        }
      })

      Selector({
        title: $r('app.string.vpn_edit_ovpn_protocol'),
        vpnConfig: this.vpnConfig,
        type: SELECTER_OVPN_PROTOCOL,
        sheetTitles: this.ovpnProtocolSheetTitles,
        sheetInfos: this.ovpnProtocolSheets
      }).margin({ top: 10, bottom: 10 });

      Row({ space: 10 }) {
        Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).onChange((value) => {
          this.ovpnAdvanceChecked = value;
        })
        Text($r('app.string.vpn_edit_advanced'))
      }.width('100%').margin({ left: 4, bottom: 10 })

      Column({ space: 10 }) {
        Selector({
          title: $r('app.string.vpn_edit_auth_type'),
          vpnConfig: this.vpnConfig,
          type: SELECTER_OVPN_AUTH,
          sheetTitles: this.ovpnAuthSheetTitles,
          sheetInfos: this.ovpnAuthSheets
        })

        Selector({
          title: $r('app.string.vpn_edit_ovpn_ca_cert_file'),
          vpnConfig: this.vpnConfig,
          type: SELECTER_CERT,
          sheetTitles: this.caSheetTitles,
          sheetInfos: this.caSheetInfos,
          certSelectedId: this.caSheetSelectedId
        })

        Selector({
          title: $r('app.string.vpn_edit_ovpn_user_cert_file'),
          vpnConfig: this.vpnConfig,
          type: SELECTER_CERT,
          sheetTitles: this.userCertSheetTitles,
          sheetInfos: this.userCertSheetInfos,
          certSelectedId: this.userCertSheetSelectedId
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_PWD ?
          Visibility.Visible : Visibility.None);

        SelectFile({
          title: $r('app.string.vpn_edit_ovpn_private_key'),
          fileName: this.vpnConfig.ovpnPrivateKeyFilePath,
          vpnConfig: this.vpnConfig,
          callback: (result: string[]) => {
            this.vpnConfig.ovpnPrivateKeyFilePath = result[0];
            this.vpnConfig.ovpnPrivateKey = '<key>\n' + result[1] + '\n</key>';
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_PWD ?
          Visibility.Visible : Visibility.None);

        TextWithInput({
          title: $r('app.string.vpn_edit_ovpn_private_key_psd'),
          inputPlaceholder: '',
          inputText: this.vpnConfig.askpass,
          inputType: INPUT_TYPE_PWD,
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
          inputType: INPUT_TYPE_PWD,
          maxLength: VpnConstant.VPN_PASSWORD_MAX_LENGTH,
          onChange: (value: string) => {
            this.vpnConfig.password = value.trim();
          }
        }).visibility(this.vpnConfig.ovpnAuthType !== VpnConstant.OVPN_AUTH_TYPE_TLS ?
          Visibility.Visible : Visibility.None);

        Row({ space: 10 }) {
          Checkbox().shape(CheckBoxShape.ROUNDED_SQUARE).onChange((value) => {
            this.ovpnProxyChecked = value;
          })
          Text($r('app.string.vpn_edit_proxy_advanced'))
        }.width('100%').margin({ left: 4 })

        Column({ space: 10 }) {
          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_host'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.ovpnProxyHost,
            inputType: INPUT_TYPE_IP,
            onChange: (value: string) => {
              this.ovpnProxyHost = value.trim();
              this.vpnConfig.ovpnProxyHost = this.ovpnProxyHost;
              this.onNonNullableParamChange();
            }
          })

          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_port'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.ovpnProxyPort,
            inputType: INPUT_TYPE_PORT,
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
            onChange: (value: string) => {
              this.vpnConfig.ovpnProxyUser = value.trim();
            }
          })
          TextWithInput({
            title: $r('app.string.vpn_edit_ovpn_proxy_password'),
            inputPlaceholder: $r('app.string.vpn_edit_unuse'),
            inputText: this.vpnConfig.ovpnProxyPass,
            inputType: INPUT_TYPE_PWD,
            onChange: (value: string) => {
              this.vpnConfig.ovpnProxyPass = value.trim();
            }
          })
        }.visibility(this.ovpnProxyChecked ? Visibility.Visible : Visibility.None)
      }.visibility(this.ovpnAdvanceChecked ? Visibility.Visible : Visibility.None)
    }
  }
}