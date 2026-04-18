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

import vpn from '@ohos.net.vpn';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SwanCtlModel } from './model/SwanCtlModel';
import VpnConfig from './model/VpnConfig';
import VpnConstant from './model/VpnConstant';
import { VpnConnectModel } from './model/VpnConnectModel';
import { TextWithInput } from './CustomComponent';
import ConfigData from './ConfigData';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnConnect:';
const VPN_CONNECT_CHECKBOX_ID: string = 'vpn_connect_checkbox_id';
const VPN_CONNECT_PWD_ID: string = 'vpn_connect_pwd_id';
const VPN_CONNECT_USERNAME_ID: string = 'vpn_connect_username_id';

@Component
export struct VpnConnectView {
  vpnId: string = '';
  onConnectFinish: Function = () => {};
  @State vpnConfig: VpnConfig = new VpnConfig();
  @State vpnUserName: string = '';
  @State vpnPassword: string = '';
  @State isConnectBtnEnabled: boolean = false;
  @State isSaveLogin: boolean = false;
  isPc: boolean = DeviceUtil.isDevicePc();

  async aboutToAppear(): Promise<void> {
    if (this.vpnId) {
      LogUtil.info(`${MODULE_TAG} vpnid = ${this.vpnId}`)
      try {
        let data: vpn.SysVpnConfig = await vpn.getSysVpnConfig(this.vpnId);
        if (data) {
          this.vpnConfig = data as VpnConfig;
          if (this.vpnConfig.saveLogin) {
            this.vpnUserName = this.vpnConfig.userName ?? '';
            this.vpnPassword = this.vpnConfig.password ?? '';
            this.isSaveLogin = true;
          }
          this.updateConnectBtnEnabled();
        } else {
          LogUtil.error(`${MODULE_TAG} getSysVpnConfig failed, data is empty`);
        }
      } catch (err) {
        LogUtil.error(`${MODULE_TAG} getSysVpnConfig failed, err：${err?.message}`);
      }
    } else {
      LogUtil.error(`${MODULE_TAG} aboutToAppear vpnId is error`);
    }
  }

  build() {
    Column() {
      Column() {
        TextWithInput({
          title: $r('app.string.vpn_connect_username'),
          textInputId: VPN_CONNECT_USERNAME_ID,
          inputPlaceholder: $r('app.string.please_enter'),
          inputText: this.vpnUserName,
          maxLength: VpnConstant.VPN_USER_NAME_MAX_LENGTH,
          onChange: (value: string) => {
            value = value.replace(/\s+/g, '');
            this.vpnUserName = value.trim();
            this.updateConnectBtnEnabled();
          }
        })

        TextWithInput({
          title: $r('app.string.vpn_connect_password'),
          textInputId: VPN_CONNECT_PWD_ID,
          inputPlaceholder: $r('app.string.please_enter'),
          inputText: this.vpnPassword,
          inputType: VpnConstant.INPUT_TYPE_PWD,
          maxLength: VpnConstant.VPN_PASSWORD_MAX_LENGTH,
          onChange: (value: string) => {
            value = value.replace(/\s+/g, '');
            this.vpnPassword = value.trim();
            this.updateConnectBtnEnabled();
          }
        }).margin({ top: 12 })

        Row() {
          Checkbox()
            .id(VPN_CONNECT_CHECKBOX_ID)
            .shape(CheckBoxShape.CIRCLE)
            .select(this.isSaveLogin ?? false)
            .onChange((value) => {
              this.isSaveLogin = value;
            })
          Text($r('app.string.vpn_connect_save'))
            .fontColor($r('sys.color.font_primary'))
            .fontSize('16vp')
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
        }
        .width(ConfigData.WH_100_100)
        .height(40)
      }

      Button($r('app.string.vpn_connect_confirm'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize('sys.float.Body_L')
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .type(ButtonType.Normal)
        .borderRadius(this.isPc ? $r('sys.float.corner_radius_level4') :
        $r('sys.float.corner_radius_level10'))
        .height(40)
        .width(this.isPc ? '448vp' : '100%')
        .enabled(this.isConnectBtnEnabled)
        .margin({ top: 39 })
        .onClick(() => {
          this.handleConnectClick();
          this.onConnectFinish();
        })
    }
    .padding({
      left: 16,
      right: 16,
      bottom: this.isPc ? 16 : 48,
      top: 8
    })
    .width(ConfigData.WH_100_100)
    .height(this.isPc ? 'auto' : ConfigData.WH_100_100)
    .justifyContent(this.isPc ? FlexAlign.Start : FlexAlign.SpaceBetween)
  }

  async handleConnectClick(): Promise<void> {
    LogUtil.info(`${MODULE_TAG} handleConnectClick id : ${this.vpnConfig.vpnId}`);
    // clear state
    VpnConnectModel.getInstance().setConnectState(VpnConstant.VPN_STATE_NONE, this.vpnConfig.vpnId);
    // save username and password
    let isUserInfoModify: boolean =
      this.vpnUserName !== this.vpnConfig.userName || this.vpnPassword !== this.vpnConfig.password;
    let isSaveModify: boolean = this.isSaveLogin !== this.vpnConfig.saveLogin;
    if (isUserInfoModify || isSaveModify) {
      if (isUserInfoModify) {
        this.vpnConfig.userName = this.vpnUserName;
        this.vpnConfig.password = this.vpnPassword;
        // name and pwd changed, need to rebuild config
        SwanCtlModel.getInstance().buildConfig(this.vpnConfig);
      }
      if (isSaveModify) {
        this.vpnConfig.saveLogin = this.isSaveLogin;
      }
      try {
        await vpn.addSysVpnConfig(this.vpnConfig);
      } catch (err) {
        LogUtil.error(`${MODULE_TAG} addSysVpnConfig failed, err：${err?.message}`);
        return;
      }
    }

    // exec setup
    VpnConnectModel.getInstance().setUp(this.vpnConfig);
  }

  updateConnectBtnEnabled(): void {
    if (this.vpnUserName === '' || this.vpnPassword === '') {
      this.isConnectBtnEnabled = false;
    } else {
      this.isConnectBtnEnabled = true;
    }
  }
}