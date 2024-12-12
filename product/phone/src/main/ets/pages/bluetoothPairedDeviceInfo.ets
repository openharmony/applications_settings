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

import Router, { ParamsInterface } from '@system.router';
import BluetoothDevice from '../model/bluetoothImpl/BluetoothDevice';
import BluetoothDeviceController from '../controller/bluetooth/BluetoothDeviceController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import constant from '@ohos.bluetooth.constant';
import { BusinessError } from '@kit.BasicServicesKit';
import connection from '@ohos.bluetooth.connection';
import ProfileComponent from '../../../../../../common/component/src/main/ets/default/profileComponent';
import deviceInfo from '@ohos.deviceInfo';
import { LengthMetrics } from '@ohos.arkui.node';
import map from '@ohos.bluetooth.map';
import pbap from '@ohos.bluetooth.pbap';
import { SymbolGlyphModifier } from '@kit.ArkUI';

// let param;
enum ProfileId {
  A2DP = constant.ProfileId.PROFILE_A2DP_SOURCE,
  HFP = constant.ProfileId.PROFILE_HANDSFREE_AUDIO_GATEWAY,
  HID = constant.ProfileId.PROFILE_HID_HOST
}

enum AccessAuthorization {
  UNKNOWN = 0,
  ALLOWED = 1,
  REJECTED = 2,
}

export enum ShareType {
  SHARE_NAME_AND_PHONE_NUMBER = 0,
  SHARE_ALL = 1,
  SHARE_NOTHING = 2,
}

let deviceId: string = '';

/**
 * BluetoothPairedDeviceInfo
 */
@Entry
@Component
struct BluetoothPairedDeviceInfo {
  @State bluetoothDevice: BluetoothDevice = new BluetoothDevice();
  @State isTouched: boolean = false;
  @State localUuIds: constant.ProfileUuids[] = [];
  @State a2dpState: boolean = false;
  @State hfpState: boolean = false;
  @State hidState: boolean = false;
  @State mapState: boolean = false;
  @State mapEnable: boolean = true;
  @State isEnable: boolean = true;
  @State shareType: number = ShareType.SHARE_NOTHING;
  @State a2dpDescription: string | ResourceStr = '';
  @State hfpDescription: string | ResourceStr = '';
  @State hidDescription: string | ResourceStr = '';
  @State mapDescription: string | ResourceStr = '';
  @State listLength: number = 0;
  @State deviceType: string = '';
  @State shareTypeName: ResourceStr = '';
  @State selectIconModifier: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontSize('24vp');
  public mapProfile = map.createMapMseProfile();
  public pbapProfile = pbap.createPbapServerProfile();
  private controller: BluetoothDeviceController = new BluetoothDeviceController()

  private setShareType(name: ResourceStr): void {
    try {
      this.shareTypeName = name;
      LogUtil.info(`setShareType ${this.shareType} successful`)
      this.pbapProfile.setShareType(deviceId, this.shareType).then(() => {
        LogUtil.info(`setShareType ${this.shareType} successful`)
      })
    } catch (err) {
      LogUtil.error(`errCode: ${err.code} , errMessage: ${err.message}`)
    }
  }

  private initState(): void {
    let a2dpState = this.controller.getProfileState(deviceId, ProfileId.A2DP);
    let hfpState = this.controller.getProfileState(deviceId, ProfileId.HFP);
    let hidState = this.controller.getProfileState(deviceId, ProfileId.HID);
    this.a2dpState = a2dpState?.isOn
    this.a2dpDescription = a2dpState?.description
    this.hfpState = hfpState?.isOn
    this.hfpDescription = hfpState?.description
    this.hidState = hidState?.isOn
    this.hidDescription = hidState?.description
    this.isEnable = a2dpState.isEnable && hfpState.isEnable && hidState.isEnable;
    switch (this.shareType) {
      case ShareType.SHARE_NAME_AND_PHONE_NUMBER:
        this.shareTypeName = $r('app.string.bluetooth_name_and_numbers_only')
        break;
      case ShareType.SHARE_ALL:
        this.shareTypeName = $r('app.string.bluetooth_fulls_details')
        break;
      case ShareType.SHARE_NOTHING:
        this.shareTypeName = $r('app.string.bluetooth_not_share')
      default:
        break;
    }
  }

  aboutToAppear() {
    let param = Router.getParams();
    this.bluetoothDevice = JSON.parse((param as ParamsInterface).bluetoothDevice.toString());
    deviceId = this.bluetoothDevice.deviceId;
    this.pbapProfile.getShareType(deviceId).then((type) => {
      LogUtil.info(`getShareType: ${type}`)
      this.shareType = type;
    })
    this.localUuIds = [];
    this.initState();
    this.getUuid();
    this.getListLength();
    this.deviceType = deviceInfo.deviceType;
    LogUtil.info('this.deviceType = ' + this.deviceType)
  }

  getUuid(): void {
    try {
      connection.getRemoteProfileUuids(deviceId, (err: BusinessError, data: Array<connection.ProfileUuids>) => {
        this.localUuIds = data;
        this.getListLength();
        console.info('getRemoteProfileUuids, err: ' + JSON.stringify(err) + ', data: ' + JSON.stringify(data));
      });
    } catch (err) {
      console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
    }
  }

  private getListLength(): void {
    if ((this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_HFP_AG)) ||
      (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_HFP_HF))) {
      this.listLength++;
    }
    if (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_A2DP_SINK)) {
      this.listLength++;
    }
    if (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_HID)) {
      this.listLength++;
    }
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: this.bluetoothDevice?.deviceName, isActive: true });
          if (this.listLength >= 1 || this.deviceType === 'default' || this.deviceType === 'phone') {
            List() {
              if (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_HFP_HF)) {
                ListItem() {
                  ProfileComponent({
                    isOn: this.hfpState,
                    isEnable: this.isEnable,
                    desp: this.hfpDescription,
                    profileId: ProfileId.HFP,
                    profileText: $r("app.string.call_audio"),
                    onChange: (isOn: boolean) => {
                      if (!isOn) {
                        this.controller.disconnectProfile(deviceId, ProfileId.HFP)
                      } else {
                        this.controller.connectProfile(deviceId, ProfileId.HFP)
                      }
                    }
                  })
                }
              }

              if (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_A2DP_SINK)) {
                ListItem() {
                  ProfileComponent({
                    isOn: this.a2dpState,
                    isEnable: this.isEnable,
                    desp: this.a2dpDescription,
                    profileText: $r("app.string.media_audio"),
                    profileId: ProfileId.A2DP,
                    onChange: (isOn: boolean) => {
                      if (!isOn) {
                        this.controller.disconnectProfile(deviceId, ProfileId.A2DP)
                      } else {
                        this.controller.connectProfile(deviceId, ProfileId.A2DP)
                      }
                    }
                  })
                }
              }

              if (this.localUuIds.includes(constant.ProfileUuids.PROFILE_UUID_HID)) {
                ListItem() {
                  ProfileComponent({
                    isOn: this.hidState,
                    isEnable: this.isEnable,
                    desp: this.hidDescription,
                    profileText: $r("app.string.input_device"),
                    profileId: ProfileId.HID,
                    onChange: (isOn: boolean) => {
                      if (!isOn) {
                        this.controller.disconnectProfile(deviceId, ProfileId.HID)
                      } else {
                        this.controller.connectProfile(deviceId, ProfileId.HID)
                      }
                    }
                  })
                }
              }

              if (this.deviceType === 'default' || this.deviceType === 'phone') {
                ListItem() {
                  Flex({
                    wrap: FlexWrap.NoWrap,
                    justifyContent: FlexAlign.SpaceBetween,
                    alignItems: ItemAlign.Center
                  }) {
                    Row() {
                      Text($r('app.string.bluetooth_sharing_and_call_history'))
                        .fontColor($r('sys.color.font_primary'))
                        .fontSize($r('sys.float.Body_L'))
                        .fontWeight(FontWeight.Medium)
                        .fontFamily('HarmonyHeiTi')
                        .align(Alignment.Center)
                        .constraintSize({
                          minHeight: 21
                        })
                    }
                    .flexGrow(0)
                    .flexShrink(0)
                    .align(Alignment.Start)

                    Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
                      Column() {
                        Text(this.shareTypeName)
                          .fontColor($r('sys.color.font_secondary'))
                          .fontSize($r('sys.float.Body_M'))
                          .fontFamily('HarmonyHeiTi')
                          .fontWeight(FontWeight.Regular)
                          .constraintSize({
                            minHeight: 19
                          })
                          .margin({
                            start: LengthMetrics.vp(2),
                            end: LengthMetrics.vp(2)
                          })
                      }
                      .flexGrow(1)
                      .alignItems(HorizontalAlign.End)
                      .justifyContent(FlexAlign.Center)

                      SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                        .fontColor([$r('sys.color.icon_tertiary')])
                        .draggable(false)
                        .size({ width: 24, height: 24 })
                        .margin({ start: LengthMetrics.vp(8) })
                    }
                    .padding({ start: LengthMetrics.vp(16) })
                    .bindMenu(this.SubMenu())
                  }
                  .width('100%')
                  .padding({
                    start: LengthMetrics.vp(8),
                    end: LengthMetrics.vp(8),
                    top: LengthMetrics.vp(12),
                    bottom: LengthMetrics.vp(12)
                  })
                }

                ListItem() {
                  ProfileComponent({
                    isOn: this.mapState,
                    isEnable: this.mapEnable,
                    desp: this.mapDescription,
                    profileText: $r("app.string.bluetooth_read_info_auth"),
                    onChange: (isOn: boolean) => {
                      if (isOn) {
                        try {
                          this.mapProfile?.setMessageAccessAuthorization(deviceId, AccessAuthorization.ALLOWED)
                            .then(() => {
                              LogUtil.info(`accessAuthorization: ${AccessAuthorization.ALLOWED}`)
                            })
                        } catch (err) {
                          LogUtil.error(`'setMessageAccessAuthorization' code: ${err?.code} ,message: ${err?.message}`)
                        }
                      } else {
                        try {
                          this.mapProfile?.setMessageAccessAuthorization(deviceId, AccessAuthorization.REJECTED)
                            .then(() => {
                              LogUtil.info(`accessAuthorization: ${AccessAuthorization.REJECTED}`)
                            })
                        } catch (err) {
                          LogUtil.error(`'setMessageAccessAuthorization' code: ${err?.code} ,message: ${err?.message}`)
                        }
                      }
                    }
                  })
                }
              }
            }
            .borderRadius($r('app.float.wh_value_28'))
            .margin({
              top: $r("app.float.distance_8"),
              left: $r("app.float.distance_12"),
              right: $r("app.float.distance_12")
            })
            .borderRadius($r('app.float.wh_value_28'))
            .padding($r("app.float.distance_4"))
            .backgroundColor($r("app.color.white_bg_color"))
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('app.color.color_E3E3E3_grey'),
              startMargin: $r('app.float.wh_value_10'),
              endMargin: $r('app.float.wh_value_10')
            })
          }

          Blank()

          Button() {
            Text($r("app.string.cancelPairing"))
              .fontSize($r('app.float.application_button_subtitle_size'))
              .fontColor($r("app.color.font_color_007DFF"))
          }
          .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
          .width($r("app.float.component_button_width"))
          .height($r("app.float.wh_value_40"))
          .align(Alignment.Center)
          .onClick(() => {
            LogUtil.log(ConfigData.TAG + "unpair onClick");
            if (this.bluetoothDevice) {
              if (this.controller.unpair(this.bluetoothDevice.deviceId)) {
                Router.back();
              }
            }
          })
          .margin({ bottom: $r('app.float.distance_24'), top: $r("app.float.distance_8") });
        }
        .height(ConfigData.WH_100_100)
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Builder
  SubMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.bluetooth_name_and_numbers_only'),
        symbolEndIcon: this.shareType === ShareType.SHARE_NAME_AND_PHONE_NUMBER ? this.selectIconModifier : null
      })
        .height(48)
        .selected(this.shareType === ShareType.SHARE_NAME_AND_PHONE_NUMBER)
        .onChange((selected: boolean) => {
          if (selected) {
            this.shareType = ShareType.SHARE_NAME_AND_PHONE_NUMBER;
            this.setShareType($r('app.string.bluetooth_name_and_numbers_only'));
          }
        })
      MenuItem({
        content: $r('app.string.bluetooth_fulls_details'),
        symbolEndIcon: this.shareType === ShareType.SHARE_ALL ? this.selectIconModifier : null
      })
        .height(48)
        .selected(this.shareType === ShareType.SHARE_ALL)
        .onChange((selected: boolean) => {
          if (selected) {
            this.shareType = ShareType.SHARE_ALL;
            this.setShareType($r('app.string.bluetooth_fulls_details'));
          }
        })
      MenuItem({
        content: $r('app.string.bluetooth_not_share'),
        symbolEndIcon: this.shareType === ShareType.SHARE_NOTHING ? this.selectIconModifier : null
      })
        .height(48)
        .selected(this.shareType === ShareType.SHARE_NOTHING)
        .onChange((selected: boolean) => {
          if (selected) {
            this.shareType = ShareType.SHARE_NOTHING;
            this.setShareType($r('app.string.bluetooth_not_share'));
          }
        })
    }
    .width('50%')
    .menuItemDivider({
      color: $r('app.color.color_E3E3E3_grey'),
      strokeWidth: LengthMetrics.vp(0.5),
      startMargin: LengthMetrics.vp(12),
      endMargin: LengthMetrics.vp(12)
    })
  }
}
