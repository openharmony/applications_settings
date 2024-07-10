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
import vpn from '@ohos.net.vpn';
import router from '@ohos.router';
import { VpnConnectModel } from '../../model/vpnImpl/VpnConnectModel';
import VpnConfig, { VpnListItem } from '../../model/vpnImpl/VpnConfig';
import { VpnConfigModel } from '../../model/vpnImpl/VpnConfigModel';
import VpnConstant from '../../model/vpnImpl/VpnConstant';
import { ResourceUtils } from '../../model/accessibilityImpl/resourceUtils';
import ComponentConfig from '../../../../../../../common/component/src/main/ets/default/ComponentConfig';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const MODULE_TAG: string = 'setting_vpn:VpnLine:';
const deviceTypeInfo = deviceInfo.deviceType;

/**
 * item custom component
 */
@Entry
@Component
export default struct VpnLine {
  @StorageLink(VpnConstant.STORAGE_KEY_CONNECT_STATE) @Watch('onConnectStateChange') connectState: number =
    VpnConstant.VPN_STATE_NONE;
  @State connectStateLabel: string | Resource = '';
  @State vpnListItem: VpnListItem | undefined = undefined;
  @State titleFontColor: Resource = $r('sys.color.ohos_id_color_text_primary');
  @State isTouched: boolean = false;
  @State heights: Resource = $r('app.float.wh_value_72');
  @State fontSize: Resource = $r('sys.float.ohos_id_text_size_body1');
  @State valueFontSize: Resource = $r('sys.float.ohos_id_text_size_body2');
  private isEnabled: boolean = true;
  @State editPopupVisibility: boolean = false

  showDisconnectDialog(): void {
    AlertDialog.show({
      message: $r('app.string.vpn_line_disconnect_alert_title', this.vpnListItem!.vpnName),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info('dialog cancel callbacks');
        }
      },
      secondaryButton: {
        fontColor: $r('sys.color.ohos_id_color_warning'),
        value: $r('app.string.vpn_line_disconnect_alert_confirm'),
        action: () => {
          VpnConnectModel.getInstance().setConnectState(VpnConstant.VPN_STATE_DISCONNECTING);
          VpnConnectModel.getInstance().destroy((error: string) => {
            if (error) {
              LogUtil.info(MODULE_TAG + `vpn destroy failed, error:` + error);
            }
          });
        }
      },
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ?
      DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    })
  }

  aboutToAppear(): void {
    let state: number | undefined = AppStorage.get(VpnConstant.STORAGE_KEY_CONNECT_STATE);
    if (state) {
      this.connectState = state;
      if (this.connectState === VpnConstant.VPN_STATE_CONNECTED &&
        this.vpnListItem!.vpnId === VpnConnectModel.getInstance().getConnectedVpnId()) {
        this.connectStateLabel = $r('app.string.vpn_state_connec_success');
      }
    }
  }

  async onEditBtnClick() {
    if (VpnConnectModel.getInstance().isConnecting(this.vpnListItem!.vpnId)) {
      this.showDisconnectDialog();
      return;
    }
    try {
      let data: vpn.SysVpnConfig = await vpn.getSysVpnConfig(this.vpnListItem?.vpnId);
      if (data) {
        router.pushUrl({
          url: 'pages/vpn/vpnEdit',
          params: data as VpnConfig
        });
      }
    } catch (err) {
      let message = (err as BusinessError).message;
      VpnConfigModel.getInstance().showToast(ResourceUtils.getStringSync($r('app.string.vpn_error_operation_failed')) + ': ' + message);
    }
  }

  onListItemClick() {
    if (VpnConnectModel.getInstance().isConnectedOrConnecting(this.vpnListItem!.vpnId)) {
      this.showDisconnectDialog();
    } else {
      router.pushUrl({
        url: 'pages/vpn/vpnConnect',
        params: this.vpnListItem
      });
    }
  }

  onConnectStateChange(): void {
    if (this.vpnListItem!.vpnId === VpnConnectModel.getInstance().getConnectedVpnId()) {
      LogUtil.info(MODULE_TAG + 'onConnectStateChange state=' + this.connectState);
      switch (this.connectState) {
        case VpnConstant.VPN_STATE_CONNECTING:
          this.connectStateLabel = $r('app.string.vpn_state_connect_ing');
          return;
        case VpnConstant.VPN_STATE_CONNECTED:
          this.connectStateLabel = $r('app.string.vpn_state_connec_success');
          return;
        case VpnConstant.VPN_STATE_DISCONNECTING:
          this.connectStateLabel = $r('app.string.vpn_state_disconnecting');
          return;
        case VpnConstant.VPN_STATE_DISCONNECTED:
          this.connectStateLabel = $r('app.string.vpn_state_disconnected');
          return;
        case VpnConstant.VPN_STATE_CONNECT_FAILED:
          this.connectStateLabel = $r('app.string.vpn_state_connec_failed');
          return;
        default:
          this.connectStateLabel = '';
          return;
      }
    }
    this.connectStateLabel = '';
  }

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_vpn'))
          .width(30)
          .height(16)
          .margin({
            right: $r('app.float.wh_value_16')
          })
        Column() {
          Text(this.vpnListItem?.vpnName ?? '')
            .fontColor(this.isEnabled ? this.titleFontColor : $r('sys.color.ohos_id_color_primary'))
            .fontSize(this.fontSize)
            .fontWeight(FontWeight.Medium)
            .align(Alignment.Start)
            .maxLines(ComponentConfig.MAX_LINES_1)
            .width(ComponentConfig.WH_100_100)
            .ellipsisMode(EllipsisMode.END)
            .padding({ right: 50 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.connectStateLabel)
            .fontColor($r('sys.color.ohos_id_color_mask_light'))
            .fontSize(this.valueFontSize)
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Regular)
            .maxLines(ComponentConfig.MAX_LINES_1)
            .width(ComponentConfig.WH_100_100)
            .ellipsisMode(EllipsisMode.END)
            .padding({ right: 50 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 8 })
            .visibility(this.connectStateLabel.toString().length > 0 ? Visibility.Visible : Visibility.None)
        }
        .alignItems(HorizontalAlign.Start)
        .width('80%')

        Row() {
          Image($r('app.media.ic_public_detail'))
            .width(24)
            .height(24)
        }
        .width($r('app.float.wh_value_50'))
        .height(ComponentConfig.WH_100_100)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({
          right: $r('app.float.wh_value_16')
        })
        .onClick(() => {
          this.onEditBtnClick();
        })
      }
      .flexShrink(0)
      .alignItems(VerticalAlign.Center)
      .align(Alignment.Start)

      Blank()
    }
    .width(ComponentConfig.WH_100_100)
    .padding({
      left: $r('sys.float.ohos_id_card_margin_end'),
      right: $r('sys.float.ohos_id_card_margin_end'),
      top: $r('sys.float.ohos_id_elements_margin_vertical_m'),
      bottom: $r('sys.float.ohos_id_elements_margin_vertical_m')
    })
    .alignItems(VerticalAlign.Center)
    .height('62vp')
    .borderRadius($r('app.float.radius_16'))
    .linearGradient(this.isTouched ? {
      angle: 90,
      direction: GradientDirection.Right,
      colors: [[$r('app.color.DCEAF9'), 0.0], [$r('app.color.FAFAFA'), 1.0]]
    } : {
      angle: 90,
      direction: GradientDirection.Right,
      colors: [[$r('sys.color.ohos_id_color_foreground_contrary'), 1],
        [$r('sys.color.ohos_id_color_foreground_contrary'), 1]]
    })
    .onTouch((event?: TouchEvent | undefined) => {
      if (event?.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event?.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
    .onClick(() => {
      this.onListItemClick();
    })
  }
}
