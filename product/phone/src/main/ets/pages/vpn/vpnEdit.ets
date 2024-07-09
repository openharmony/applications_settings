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
import router from '@ohos.router';
import vpn from '@ohos.net.vpn';
import util from '@ohos.util';
import window from '@ohos.window';
import OpenVpnEdit from './openVpnEdit';
import IpsecVpnEdit from './ipsecVpnEdit';
import { TextWithInput, Selector, SELECTER_VPNTYPE, deviceTypeInfo } from './customComponent';
import { VpnTypeModel } from '../../model/vpnImpl/VpnTypeModel';
import { VpnConnectModel } from '../../model/vpnImpl/VpnConnectModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import { VpnConfigModel } from '../../model/vpnImpl/VpnConfigModel';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';
import VpnConfig, { OpenVpnConfig, IpsecVpnConfig } from '../../model/vpnImpl/VpnConfig';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';

const MODULE_TAG: string = 'setting_vpn:VpnEdit:';

@Entry
@Component
export struct VpnEdit {
  @State vpnConfig: VpnConfig = new VpnConfig();
  @State isSaveBtnEnabled: boolean = false;
  @State isDelBtnVisibility: Visibility = Visibility.None;
  protocolSheets: SheetInfo[] = [];

  aboutToAppear() {
    window.getLastWindow(getContext(this), (err, w) => {
      w.setWindowSystemBarProperties({
        statusBarColor: '#ffffff'
      })
    })
    let param = router.getParams();
    if (param) {
      this.vpnConfig = param as VpnConfig;
    }
    this.isDelBtnVisibility = this.vpnConfig.vpnName ? Visibility.Visible : Visibility.None;

    this.protocolSheets = VpnTypeModel.getInstance().getSupportVpnTypeStrs().map((str, index) => {
      let s: SheetInfo = {
        title: str,
        action: () => {
          this.vpnConfig.vpnType = (index < VpnTypeModel.getInstance().getSupportVpnTypes().length) ?
            VpnTypeModel.getInstance().getSupportVpnTypes()[index] : 0;
        }
      }
      return s;
    })
  }

  onSaveBtnEnableChange: Function = (enabled: boolean) => {
    this.isSaveBtnEnabled = enabled && this.vpnConfig.vpnName.length > 0;
  }

  async onSaveClick() {
    if (!this.vpnConfig.vpnName || this.vpnConfig.vpnName.length < 1) {
      VpnConfigModel.getInstance().showToast($r('app.string.vpn_error_invalid_param'));
      return;
    }
    // destroy connect when vpn connected
    if (VpnConnectModel.getInstance().isConnectedOrConnecting(this.vpnConfig.vpnId)) {
      VpnConfigModel.getInstance().showToast($r('app.string.vpn_error_disconnect_first'))
      return;
    }

    VpnConfigModel.getInstance().prepareAddSysVpnConfig(this.vpnConfig);
    if (!this.vpnConfig.vpnId || this.vpnConfig.vpnId === '') {
      this.vpnConfig.vpnId = util.generateRandomUUID();
    }
    try {
      await vpn.addSysVpnConfig(this.vpnConfig);
      VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
      this.backToListPage();
    } catch (err) {
      let message = (err as BusinessError).message;
      VpnConfigModel.getInstance().showToast(
        ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
    }
  }

  backToListPage() {
    router.back();
  }

  async onDeleteClick() {
    if (!this.vpnConfig) {
      LogUtil.error(MODULE_TAG + 'onDeleteClick failed, vpn config is error');
      return;
    }
    if (!this.vpnConfig.vpnId || this.vpnConfig.vpnId === '') {
      LogUtil.error(MODULE_TAG + 'onDeleteClick failed, vpnId is error');
      return;
    }
    try {
      await vpn.deleteSysVpnConfig(this.vpnConfig.vpnId);
      VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
      this.backToListPage();
    }catch (err){
      let message = (err as BusinessError).message;
      VpnConfigModel.getInstance().showToast(
        ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
    }
  }

  showDeleteDialog(): void {
    AlertDialog.show({
      message: $r('app.string.vpn_line_remove_alert_title', this.vpnConfig.vpnName),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info('dialog cancel callbacks');
        }
      },
      secondaryButton: {
        fontColor: $r('sys.color.ohos_id_color_warning'),
        value: $r('app.string.vpn_line_remove_alert_confirm'),
        action: () => {
          this.onDeleteClick();
        }
      },
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ?
      DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    })
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        RelativeContainer() {
          HeadComponent({ headName: $r('app.string.vpn_edit_title'), isActive: true }).alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          }).id('head')

          Scroll() {
            Column({ space: 10 }) {
              TextWithInput({
                title: $r('app.string.vpn_edit_alias'),
                inputPlaceholder: '',
                inputText: this.vpnConfig.vpnName,
                maxLength: VpnConstant.VPN_NAME_MAX_LENGTH,
                onChange: (value: string) => {
                  this.vpnConfig.vpnName = value.trim();
                  this.onSaveBtnEnableChange(this.vpnConfig.vpnName.length > 0 ? true : false);
                }
              })
              Text($r('app.string.vpn_line_disconnect_operation_remove'))
                .fontColor($r('sys.color.ohos_id_color_badge_red'))
                .fontWeight(FontWeight.Bold)
                .width(ConfigData.WH_100_100)
                .textAlign(TextAlign.Center)
                .onClick(() => {
                  if (VpnConnectModel.getInstance().isConnectedOrConnecting(this.vpnConfig.vpnId)) {
                    VpnConfigModel.getInstance().showToast($r('app.string.vpn_error_disconnect_first'))
                  } else {
                    this.showDeleteDialog();
                  }
                })
                .borderRadius($r('app.float.radius_16'))
                .backgroundColor('#ffffff')
                .width('100%')
                .height($r('app.float.wh_value_52'))
                .borderRadius($r('app.float.radius_16'))
                .padding({ left: 8, right: 8 })
                .visibility(this.isDelBtnVisibility)

              Selector({
                title: $r('app.string.vpn_edit_type'),
                vpnConfig: this.vpnConfig,
                type: SELECTER_VPNTYPE,
                sheetTitles: VpnTypeModel.getInstance().getSupportVpnTypeStrs(),
                sheetInfos: this.protocolSheets,
              }).enabled(this.isDelBtnVisibility !== Visibility.Visible)

              if (this.vpnConfig.vpnType === VpnTypeModel.TYPE_OPENVPN) {
                OpenVpnEdit({
                  vpnConfig: this.vpnConfig as OpenVpnConfig,
                  onSaveBtnEnableChange: this.onSaveBtnEnableChange,
                })
              } else {
                IpsecVpnEdit({
                  vpnConfig: this.vpnConfig as IpsecVpnConfig,
                  onSaveBtnEnableChange: this.onSaveBtnEnableChange,
                })
              }
              Blank().layoutWeight(1)
            }.alignItems(HorizontalAlign.Start).width(ConfigData.WH_100_100)
          }.alignRules({
            top: { anchor: 'head', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End },
            bottom: { anchor: 'bottom', align: VerticalAlign.Top }
          }).id('content')

          Row() {
            Button($r('app.string.cancel'))
              .fontColor('#0A59F7')
              .fontSize(16)
              .height(45)
              .layoutWeight(1)
              .fontWeight(FontWeight.Bold)
              .padding({ top: 10, left: 60, right: 60, bottom: 10 })
              .borderRadius($r('app.float.radius_20'))
              .backgroundColor('#E6E8E9')
              .onClick(() => {
                this.backToListPage();
              })
            Blank().width(30)
            Button($r('app.string.vpn_edit_save'))
              .fontColor(this.isSaveBtnEnabled ? '#0A59F7' : '#92B3F3')
              .fontSize(16)
              .height(45)
              .layoutWeight(1)
              .fontWeight(FontWeight.Bold)
              .padding({ top: 10, left: 60, right: 60, bottom: 10 })
              .borderRadius($r('app.float.radius_20'))
              .backgroundColor('#E6E8E9')
              .enabled(this.isSaveBtnEnabled)
              .background()
              .onClick(() => {
                this.onSaveClick();
              })
          }.margin(15).alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          }).id('bottom')

        }.width(ConfigData.WH_100_100).height(ConfigData.WH_100_100)
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}



