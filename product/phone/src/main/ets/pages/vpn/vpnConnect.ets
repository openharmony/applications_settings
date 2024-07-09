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

import { BusinessError } from '@ohos.base';
import deviceInfo from '@ohos.deviceInfo';
import router from '@ohos.router';
import util from '@ohos.util';
import vpn from '@ohos.net.vpn';
import { VpnConnectModel } from '../../model/vpnImpl/VpnConnectModel';
import VpnConfig, { VpnListItem } from '../../model/vpnImpl/VpnConfig';
import { SwanCtlModel } from '../../model/vpnImpl/SwanCtlModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import { VpnConfigModel } from '../../model/vpnImpl/VpnConfigModel';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const deviceTypeInfo = deviceInfo.deviceType;
const MODULE_TAG: string = 'setting_vpn:VpnConnect:';

@Entry
@Component
export struct VpnConnect {
  @StorageLink('connectState') connectState: number = VpnConstant.VPN_STATE_NONE;
  @State vpnConfig: VpnConfig = new VpnConfig();
  @State vpnUserName: string = '';
  @State vpnPassword: string = '';
  @State isSetupBtnEnabled: boolean = false;

  async aboutToAppear() {
    let state: number | undefined = AppStorage.get(VpnConstant.STORAGE_KEY_CONNECT_STATE);
    if (state) {
      this.connectState = state;
    }
    let vpnItem: VpnListItem = router.getParams() as VpnListItem;
    if (vpnItem && vpnItem.vpnId) {
      LogUtil.info(MODULE_TAG + `vpnid = ${JSON.stringify(vpnItem.vpnId)}`)
      try {
        let data: vpn.SysVpnConfig = await vpn.getSysVpnConfig(vpnItem.vpnId);
        if (data) {
          this.vpnConfig = data as VpnConfig;
          if (this.vpnConfig.saveLogin) {
            this.vpnUserName = this.vpnConfig.userName ?? '';
            this.vpnPassword = this.vpnConfig.password ?? '';
          }
          this.setConnectBtnEnabled();
        } else {
          VpnConfigModel.getInstance().showToast($r('app.string.vpn_error_operation_failed'));
        }
      } catch (err) {
        let message = (err as BusinessError).message;
        VpnConfigModel.getInstance().showToast(
          ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
      }
    } else {
      LogUtil.error(MODULE_TAG + `getParams is error`)
    }
  }

  build() {
    Column() {
      HeadComponent({
        headName: $r('app.string.vpn_connect_title', this.vpnConfig.vpnName),
        isActive: true
      }).padding({ right: 35 })

      Column() {
        Column() {
          Text($r('app.string.vpn_connect_username'))
            .width('100%')
          TextInput({ text: this.vpnUserName })
            .padding({ left: 1 })
            .fontSize($r('app.float.font_16'))
            .maxLength(VpnConstant.VPN_USER_NAME_MAX_LENGTH)
            .backgroundColor('#00000000')
            .height(40)
            .onChange((value) => {
              value = value.replace(/\s+/g, '');
              this.vpnUserName = value.trim();
              this.setConnectBtnEnabled();
            })
          Divider()
            .color($r('sys.color.ohos_id_color_list_separator'))
          Text($r('app.string.vpn_connect_password'))
            .width('100%')
            .margin({ top: 15 })
          TextInput({ text: this.vpnPassword })
            .padding({ left: 1 })
            .type(InputType.Password)
            .maxLength(VpnConstant.VPN_PASSWORD_MAX_LENGTH)
            .fontSize($r('app.float.font_16'))
            .backgroundColor('#00000000')
            .height(40)
            .onChange((value) => {
              value = value.replace(/\s+/g, '');
              this.vpnPassword = value.trim();
              this.setConnectBtnEnabled();
            })
          Divider()
            .color($r('sys.color.ohos_id_color_list_separator'))

          Row({ space: 8 }) {
            Checkbox().select(this.vpnConfig.saveLogin ?? false).onChange((value) => {
              this.vpnConfig.saveLogin = value;
            }).shape(CheckBoxShape.ROUNDED_SQUARE)
            Text($r('app.string.vpn_connect_save'))
          }.width('100%').margin({ top: 15 })
        }

        Blank().layoutWeight(1)
        Row() {
          Button($r('app.string.cancel'))
            .fontColor('#0A59F7')
            .fontSize(16)
            .height(45)
            .fontWeight(FontWeight.Bold)
            .padding({ top: 10, left: 60, right: 60, bottom: 10 })
            .borderRadius($r('app.float.radius_20'))
            .backgroundColor('#E6E8E9')
            .layoutWeight(1)
            .onClick(() => {
              router.back();
            })
          Blank().width(30)
          Button($r('app.string.vpn_connect_confirm'))
            .fontColor(this.isSetupBtnEnabled ? '#0A59F7' : '#92B3F3')
            .fontSize(16)
            .height(45)
            .fontWeight(FontWeight.Bold)
            .padding({ top: 10, left: 60, right: 60, bottom: 10 })
            .borderRadius($r('app.float.radius_20'))
            .backgroundColor('#E6E8E9')
            .layoutWeight(1)
            .enabled(this.isSetupBtnEnabled)
            .onClick(() => {
              this.onSetupBtnClick();
            })
        }.margin({ bottom: 65 })
      }
      .padding($r('app.float.distance_4'))
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .padding({ left: ConfigData.GRID_CONTAINER_MARGIN_24, right: ConfigData.GRID_CONTAINER_MARGIN_24, bottom: 20 })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  async onSetupBtnClick() {
    LogUtil.info(MODULE_TAG + `onSetupBtnClick current connect = ${JSON.stringify(this.connectState)}`);
    if (this.connectState === VpnConstant.VPN_STATE_CONNECTED ||
        this.connectState === VpnConstant.VPN_STATE_CONNECTING) {
      this.showVpnChangeDialog();
      return;
    }
    if ((!this.vpnConfig.userName || !this.vpnConfig.password) ||
        this.vpnUserName !== this.vpnConfig.userName || this.vpnPassword !== this.vpnConfig.password) {
      this.vpnConfig.userName = this.vpnUserName;
      this.vpnConfig.password = this.vpnPassword;
      // name and pwd changed, need to rebuild config
      this.vpnConfig = SwanCtlModel.getInstance().buildConfig(this.vpnConfig);
      if (!this.vpnConfig.vpnId || this.vpnConfig.vpnId === '') {
        this.vpnConfig.vpnId = util.generateRandomUUID();
      }
      try {
        await vpn.addSysVpnConfig(this.vpnConfig);
        VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
        VpnConnectModel.getInstance().setUp(this.vpnConfig);
      } catch (err) {
        let message = (err as BusinessError).message;
        VpnConfigModel.getInstance().showToast(ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
      }
      router.back();
      return;
    }
    VpnConnectModel.getInstance().setUp(this.vpnConfig);
    router.back();
  }

  setConnectBtnEnabled() {
    if (this.vpnUserName === '' || this.vpnPassword === '') {
      this.isSetupBtnEnabled = false;
    } else {
      this.isSetupBtnEnabled = true;
    }
  }

  showVpnChangeDialog(): void {
    AlertDialog.show({
      title: $r('app.string.vpn_change_alert_title'),
      message: $r('app.string.vpn_change_alert_content'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info('dialog cancel callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.vpn_change_alert_confirm'),
        action: () => {
          VpnConnectModel.getInstance().setConnectState(VpnConstant.VPN_STATE_DISCONNECTING);
          VpnConnectModel.getInstance().setReplaceConnectVpn(this.vpnConfig);
          VpnConnectModel.getInstance().destroy((error: string) => {
            if (error) {
              LogUtil.info(MODULE_TAG + `vpn destroy failed, error:` + error);
            }
          });
          router.back();
        }
      },
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ?
      DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    })
  }
}



