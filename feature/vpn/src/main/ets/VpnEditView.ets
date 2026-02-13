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
import { vpn } from '@kit.NetworkKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import OpenVpnEdit from './OpenVpnEdit';
import IpsecVpnEdit from './IpsecVpnEdit';
import ConfigData from './ConfigData';
import { Selector, TextWithInput } from './CustomComponent';
import VpnConfig, { IpsecVpnConfig, OpenVpnConfig } from './model/VpnConfig';
import { VpnConnectModel } from './model/VpnConnectModel';
import { VpnConfigModel } from './model/VpnConfigModel';
import { VpnTypeModel } from './model/VpnTypeModel';
import VpnConstant from './model/VpnConstant';
import { AlertDialog } from '@kit.ArkUI';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnEdit:';
const ADD_VPN_USER_NAME_ID: string = 'add_vpn_name_id';

/**
 * VpnEditView
 *
 * @since 2024-06-15
 */
@Component
export struct VpnEditView {
  onSaveClickFinish: Function = () => {};
  onDelClickFinish: Function = () => {};
  @State vpnConfig: VpnConfig = new VpnConfig();
  @State isSaveBtnEnabled: boolean = false;
  @State isDelBtnVisible: boolean = false;
  isSubVpnEditEnabled: boolean = false;
  @State bgColor: ResourceColor = Color.Transparent;
  isPc: boolean = DeviceUtil.isDevicePc();
  onSaveBtnEnableChange: Function = (enabled: boolean) => {
    this.isSubVpnEditEnabled = enabled;
    this.isSaveBtnEnabled = this.isSubVpnEditEnabled && this.vpnConfig.vpnName.length > 0;
  }

  showDeleteController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.vpn_line_remove_alert_title', this.vpnConfig.vpnName),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(`${MODULE_TAG} dialog cancel callbacks`);
        },
      },
      secondaryButton: {
        role: ButtonRole.ERROR,
        value: $r('app.string.vpn_line_remove_alert_confirm'),
        action: () => {
          this.onDeleteClick();
        }
      },
    }),
  });

  showDeleteDialog(): void {
    this.showDeleteController.open();
  }

  async onDeleteClick(): Promise<void> {
    if (!this.vpnConfig) {
      LogUtil.error(`${MODULE_TAG} onDeleteClick failed, vpn config is error`);
      return;
    }
    if (!this.vpnConfig.vpnId || this.vpnConfig.vpnId === '') {
      LogUtil.error(`${MODULE_TAG} onDeleteClick failed, vpnId is error`);
      return;
    }
    try {
      await vpn.deleteSysVpnConfig(this.vpnConfig.vpnId);
      VpnConfigModel.getInstance().setNeedUpdateVpnList(true);
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} deleteSysVpnConfig failed, error: ${err?.message}`);
    }
    this.onDelClickFinish();
  }

  async onSaveClick(): Promise<void> {
    if (!this.vpnConfig.vpnName || this.vpnConfig.vpnName.length < 1) {
      LogUtil.error(`${MODULE_TAG} onSaveClick failed, invaild vpn name`);
      return;
    }
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
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} addSysVpnConfig failed, error: ${err?.message}`);
    }
    this.onSaveClickFinish();
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.interactive_hover');
    } else {
      this.bgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.interactive_pressed');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.interactive_pressed');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          TextWithInput({
            title: $r('app.string.vpn_edit_alias'),
            inputPlaceholder: $r('app.string.please_enter'),
            inputText: this.vpnConfig.vpnName,
            maxLength: VpnConstant.VPN_NAME_MAX_LENGTH,
            textInputId: ADD_VPN_USER_NAME_ID,
            onChange: ((val: string) => {
              this.vpnConfig.vpnName = val;
              this.isSaveBtnEnabled = this.isSubVpnEditEnabled && this.vpnConfig.vpnName.length > 0;
            })
          })

          Row() {
            Text($r('app.string.vpn_line_disconnect_operation_remove'))
              .fontColor($r('sys.color.warning'))
              .fontSize($r('app.float.font_16'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .backgroundColor(this.bgColor)
              .width('calc(100% - 8vp)')
              .height('calc(100% - 8vp)')
              .borderRadius(this.isPc ? $r('sys.float.corner_radius_level8') :
              $r('sys.float.corner_radius_level8'))
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                if (VpnConnectModel.getInstance().isConnectedOrConnecting(this.vpnConfig.vpnId)) {
                  VpnConfigModel.getInstance().showToast($r('app.string.vpn_error_disconnect_first'))
                } else {
                  this.showDeleteDialog();
                }
              })
              .onHover((isHover?: boolean) => {
                this.onHoverEvent(isHover);
              })
              .onTouch((event?: TouchEvent) => {
                this.onTouchEvent(event);
              })
              .onMouse((event?: MouseEvent): void => {
                this.onMouseEvent(event);
              })
          }.alignItems(VerticalAlign.Center)
           .justifyContent(FlexAlign.Center)
           .backgroundColor($r('sys.color.comp_background_list_card'))
           .width(ConfigData.WH_100_100)
           .height(this.isPc ? $r('app.float.height_48') : $r('app.float.height_56'))
           .borderRadius(this.isPc ? $r('sys.float.corner_radius_level8') :
            $r('sys.float.corner_radius_level10'))
           .visibility(this.isDelBtnVisible ? Visibility.Visible : Visibility.None)
          Selector({
            title: $r('app.string.vpn_edit_type'),
            sheetTitles: VpnTypeModel.getInstance().getSupportVpnTypeStrs(),
            selectedId: VpnTypeModel.getInstance().getSupportVpnTypes().indexOf(this.vpnConfig.vpnType),
            onSelectedChange: (id: number) => {
              this.vpnConfig.vpnType = (id < VpnTypeModel.getInstance().getSupportVpnTypes().length) ?
              VpnTypeModel.getInstance().getSupportVpnTypes()[id] : 0;
              LogUtil.info(`${MODULE_TAG} vpn type change to ${this.vpnConfig.vpnType}`);
            }
          }).enabled(!this.isDelBtnVisible)
            .width(ConfigData.WH_100_100)

          if (this.vpnConfig.vpnType == VpnTypeModel.TYPE_OPENVPN) {
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
        }
        .alignItems(HorizontalAlign.Start)
        .width(ConfigData.WH_100_100)
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })

      Column() {
        Button($r('app.string.vpn_edit_save'))
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
          .enabled(this.isSaveBtnEnabled)
          .margin({ top: 24, left: 16, right: 16 })
          .onClick(() => {
            this.onSaveClick();
          })
      }
      .padding({ left: this.isPc ? 24 : 16, right: this.isPc ? 24 : 16 })
    }
    .padding({ bottom: 16 })
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }
}