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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import VpnConfig, { VpnListItem } from './model/VpnConfig';
import VpnConstant from './model/VpnConstant';
import { VpnConnectModel } from './model/VpnConnectModel';
import ConfigData from './ConfigData';
import { VpnConnectView } from './VpnConnectView';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { AlertDialog } from '@kit.ArkUI';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

/* instrument ignore file */
const MODULE_TAG: string = 'VpnLine:';
const VPN_LIST_DETAIL_ID: string = 'vpn_list_detail_id';
const VPN_LIST_KEY_ID: string = 'vpn_list_key_id';

/**
 * vpn list item
 *
 * @since 2024-06-15
 */
@Component
export default struct VpnLine {
  @StorageLink(VpnConstant.STORAGE_KEY_CONNECT_STATE) @Watch('onConnectStateChange') connectState: number =
    VpnConstant.VPN_STATE_NONE;
  @State connectStateLabel: string = '';
  @State vpnListItem: VpnListItem | undefined = undefined;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isVpnConnectBindSheetShow: boolean = false;
  @State bgColor: ResourceColor = Color.Transparent;
  isPc: boolean = DeviceUtil.isDevicePc();
  isLtr: boolean = LanguageUtils.isLtrDirection();

  disconnectDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: $r('app.string.vpn_line_disconnect_alert_title'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(`${MODULE_TAG} dialog cancel callbacks`);
        },
      },
      secondaryButton: {
        role: ButtonRole.ERROR,
        value: $r('app.string.vpn_line_disconnect_alert_confirm'),
        action: () => {
          VpnConnectModel.getInstance().setConnectState(VpnConstant.VPN_STATE_DISCONNECTING);
          VpnConnectModel.getInstance().destroy((error: string) => {
            if (error) {
              LogUtil.error(`${MODULE_TAG} vpn destroy failed, error : ${error}`);
            }
          });
        }
      },
    }),
  });

  showVpnChangeController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.vpn_change_alert_title'),
      content: $r('app.string.vpn_change_alert_content'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(`${MODULE_TAG} dialog cancel callbacks`);
        },
      },
      secondaryButton: {
        role: ButtonRole.ERROR,
        value: $r('app.string.vpn_change_alert_confirm'),
        action: () => {
          VpnConnectModel.getInstance().setConnectState(VpnConstant.VPN_STATE_DISCONNECTING);
          VpnConnectModel.getInstance().destroy((error: string) => {
            if (error) {
              LogUtil.error(`${MODULE_TAG} vpn destroy failed, error : ${error}`);
            }
          });
          this.isVpnConnectBindSheetShow = true;
        }
      },
    }),
  });

  aboutToAppear(): void {
    let state: number | undefined = AppStorage.get(VpnConstant.STORAGE_KEY_CONNECT_STATE);
    if (state) {
      this.connectState = state;
      this.setConnectStateLabel();
    }
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  async onEditBtnClick(): Promise<void> {
    if (VpnConnectModel.getInstance().isConnecting(this.vpnListItem!.vpnId)) {
      this.showDisconnectDialog();
      return;
    }
    try {
      let data: vpn.SysVpnConfig = await vpn.getSysVpnConfig(this.vpnListItem?.vpnId);
      if (data) {
        let vpnConfig = data as VpnConfig;
        let pushParams = new PushParam(vpnConfig);
        this.pushName(NavEntryKey.VPN_EDIT_ENTRY, pushParams);
      }
    } catch (err) {
      LogUtil.error(`${MODULE_TAG} getSysVpnConfig failed, err: ${err?.message}`);
    }
  }

  onConnectStateChange(): void {
    if (this.connectState === VpnConstant.VPN_STATE_NONE) {
      // clear state
      this.connectStateLabel = '';
      return;
    }
    LogUtil.info(`${MODULE_TAG} onConnectStateChange state = ${this.connectState}`);
    this.setConnectStateLabel();
  }

  setConnectStateLabel(): void {
    if (this.vpnListItem!.vpnId === VpnConnectModel.getInstance().getConnectedVpnId()) {
      switch (this.connectState) {
        case VpnConstant.VPN_STATE_CONNECTING:
          this.connectStateLabel = ResourceUtil.getStringSync($r('app.string.vpn_state_connect_ing'));
          break;
        case VpnConstant.VPN_STATE_CONNECTED:
          this.connectStateLabel = ResourceUtil.getStringSync($r('app.string.vpn_state_connec_success'));
          break;
        case VpnConstant.VPN_STATE_DISCONNECTING:
          this.connectStateLabel = ResourceUtil.getStringSync($r('app.string.vpn_state_disconnecting'));
          break;
        case VpnConstant.VPN_STATE_DISCONNECTED:
          this.connectStateLabel = ResourceUtil.getStringSync($r('app.string.vpn_state_disconnected'));
          break;
        case VpnConstant.VPN_STATE_CONNECT_FAILED:
          this.connectStateLabel = ResourceUtil.getStringSync($r('app.string.vpn_state_connec_failed'));
          break;
        default:
          this.connectStateLabel = '';
          break;
      }
    }
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  build() {
    Row() {
      Image($r('app.media.ic_vpn_list_key'))
        .fillColor($r('sys.color.icon_primary'))
        .width(24)
        .height(24)
        .id(VPN_LIST_KEY_ID)
        .margin({ left: this.isLtr ? 0 : $r('app.float.margin_16'),
            right:  this.isLtr ? $r('app.float.margin_16') : 0})
        .draggable(false)
      Column() {
        Text(this.vpnListItem?.vpnName ?? '')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start)
          .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
          .align(Alignment.Start)
          .maxLines(ConfigData.MAX_LINES_1)
          .width(ConfigData.WH_100_100)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.connectStateLabel)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .textAlign(TextAlign.Start)
          .direction(this.isLtr ? Direction.Ltr : Direction.Rtl)
          .fontWeight(FontWeight.Regular)
          .maxLines(ConfigData.MAX_LINES_1)
          .width(ConfigData.WH_100_100)
          .ellipsisMode(EllipsisMode.END)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
          .visibility(this.connectStateLabel.length > 0 ? Visibility.Visible : Visibility.None)
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .height(this.isPc ? (this.connectStateLabel.length > 0 ? 56 : 40) :
        (this.connectStateLabel.length > 0 ? 66 : 56))

      Image($r('app.media.ic_public_detail'))
        .fillColor($r('sys.color.icon_primary'))
        .width(24)
        .height(24)
        .id(VPN_LIST_DETAIL_ID)
        .draggable(false)
        .onClick(() => {
          this.onEditBtnClick();
        })
    }
    .padding({ left: 8, right: 8 })
    .width(ConfigData.WH_100_100)
    .height(this.connectStateLabel.length > 0 ? 66 : 56)
    .alignItems(VerticalAlign.Center)
    .borderRadius(this.isPc ? $r('sys.float.corner_radius_level8') :
    $r('sys.float.corner_radius_level8'))
    .backgroundColor(this.bgColor)
    .onHover((isHover: boolean) => {
      if (isHover) {
        this.bgColor = $r('sys.color.interactive_hover');
      } else {
        this.bgColor = Color.Transparent;
      }
    })
    .onMouse((event: MouseEvent) => {
      if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
        this.bgColor = $r('sys.color.interactive_pressed');
      } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
        this.bgColor = Color.Transparent;
      }
    })
    .onTouch((event: TouchEvent)=>{
      if (event && event.type === TouchType.Down) {
        this.bgColor = $r('sys.color.interactive_pressed');
      }
      if (event && (event.type === TouchType.Up || event.type === TouchType.Cancel)) {
        this.bgColor = Color.Transparent;
      }
    })
    .onClick(() => {
      if (this.connectState === VpnConstant.VPN_STATE_CONNECTED ||
        this.connectState === VpnConstant.VPN_STATE_CONNECTING) {
        if (this.vpnListItem!.vpnId === VpnConnectModel.getInstance().getConnectedVpnId()) {
          this.showDisconnectDialog();
        } else {
          this.showVpnChangeDialog();
        }
        return;
      }
      this.isVpnConnectBindSheetShow = true;
    })
    .bindSheet(this.isVpnConnectBindSheetShow, this.VpnConnectBindSheet(), {
      height: this.isPc ? SheetSize.FIT_CONTENT : SheetSize.LARGE,
      preferType: this.isPc ? SheetType.CENTER : SheetType.BOTTOM,
      showClose: true,
      dragBar: false,
      title: { title: $r('app.string.vpn_connect_title', this.vpnListItem?.vpnName) },
      onWillDisappear: () => {
        this.isVpnConnectBindSheetShow = false
        PasswordUtil.setPrivacyMode(false);
      },
      onWillAppear: () => {
        PasswordUtil.setPrivacyMode(true);
      }
    })
  }

  @Builder
  VpnConnectBindSheet() {
    Column() {
      VpnConnectView({
        vpnId: this.vpnListItem?.vpnId,
        onConnectFinish: () => {
          this.isVpnConnectBindSheetShow = false;
        }
      })
    }
    .width(ConfigData.WH_100_100)
  }

  showDisconnectDialog(): void {
    this.disconnectDialogController.open();
  }

  showVpnChangeDialog(): void {
    this.showVpnChangeController.open();
  }
}