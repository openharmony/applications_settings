/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
// @ts-nocheck
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ImageAnimatorComponent from '../../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import WifiModel from '../model/wifiImpl/WifiModel';
import { WifiScanInfo } from '../model/wifiImpl/WifiModel';
import wifi from '@ohos.wifi';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import router from '@system.router'
import InputMethod from '@ohos.inputmethod';
import deviceInfo from '@ohos.deviceInfo'
const deviceTypeInfo = deviceInfo.deviceType

const MODULE_TAG = ConfigData.TAG + 'WifiModel.WifiPasswd -> ';

/**
 * wifi password setting page
 */
@Entry
@Component
struct WifiPsd {
  @State userInputs: string= '';
  @State passwdHint: string = '';
  @State tobeConnectedSSID: string = '';
  @State isFocused: boolean = false;
  private tobeConnectedAp: WifiScanInfo = null;
  private isConnectedBefore: boolean = false;
  private taskId: number = -1;
  @State isPhone: boolean = false
  private connectDialog: CustomDialogController = new CustomDialogController({
    builder: connectProgressDialog({
      ssid: this.tobeConnectedSSID,
    }),
    alignment: this.isPhone?DialogAlignment.Bottom:DialogAlignment.Center,
    offset: ({ dx: 0, dy: this.isPhone?'-16dp':0 }),
    autoCancel: false,
    customStyle: true
  });
  private failedDialog: CustomDialogController = new CustomDialogController({
    builder: connectFailedDialog({}),
    alignment: this.isPhone?DialogAlignment.Bottom:DialogAlignment.Center,
    offset: ({ dx: 0, dy: this.isPhone?'-16dp':0 }),
    autoCancel: true,
    customStyle: true
  });

  build() {
    Column() {
      GridContainer({ columns: 12, sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp' }) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            Row() {
              HeadComponent({
                icBackIsVisibility: true,
                headName: this.tobeConnectedSSID,
                isActive: true
              });
            }
            .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24') })

            TextInput({ placeholder: this.passwdHint })
              .type(InputType.Password)
              .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
              .caretColor("red")
              .placeholderFont({ size: $r("app.float.font_16"),
                weight: $r("sys.string.ohos_id_text_font_family_regular"),
                family: "sans-serif", style: FontStyle.Normal })
              .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .backgroundColor($r('app.color.color_00000000_transparent'))
              .height($r('app.float.wh_value_48'))
              .borderRadius(0)
              .padding({
                left: $r('sys.float.ohos_id_default_padding_start'),
              })
              .margin({
                top: $r('app.float.wh_value_8'),
                left: $r('sys.float.ohos_id_default_padding_start'),
                right: $r('sys.float.ohos_id_default_padding_end')
              })
              .onFocus(() => {
                LogUtil.info(MODULE_TAG + "text input is focused");
                this.isFocused = true;
              })
              .onFocusMove(() => {
                LogUtil.info(MODULE_TAG + "text input is 0000000000000000000000000000000000 moved");
                this.isFocused = false;
              })
              .onChange((inputs: string) => {
                this.userInputs = inputs;
              })
              .onSubmit((enterKey) => {
                InputMethod.getInputMethodController().stopInput().then((ret) => {
                  LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                })
              });
            Divider()
              .color($r("sys.color.ohos_id_color_primary"))
              .strokeWidth($r('app.float.wh_value_1'))
              .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
              .padding({
                left: $r('sys.float.ohos_id_max_padding_start'),
                right: $r('sys.float.ohos_id_max_padding_end')
              })
            Column() {
              Row() {
                Row() {
                  Button() {
                    Text($r('app.string.cancel'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                      .fontWeight(FontWeight.Medium)
                  }
                  .height($r('app.float.wh_value_40'))
                  .width($r('app.float.wh_value_263'))
                  .margin({ right: $r('app.float.wh_value_6') })
                  .align(Alignment.Center)
                  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                  .onClick(() => {
                    router.back();
                  });
                  Button() {
                    Text($r('app.string.wifiButtonConnect'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                      .fontWeight(FontWeight.Medium)
                  }
                  .height($r('app.float.wh_value_40'))
                  .width($r('app.float.wh_value_263'))
                  .margin({ left: $r('app.float.wh_value_6') })
                  .align(Alignment.Center)
                  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                  .opacity(this.userInputs.length === 0 ? $r('sys.float.ohos_fa_alpha_disabled') : 1)
                  .onClick(this.userInputs.length === 0 ?
                    () => {
                      LogUtil.info(MODULE_TAG + 'no text input in passwd page');
                    }
                                                        :
                    () => {
                      WifiModel.setUserSelectedAp(this.tobeConnectedAp);
                      WifiModel.connectWiFi(this.userInputs);
                      this.connectDialog.open();
                    });
                }
                .margin(this.isFocused === false ?
                  { bottom: $r("app.float.wh_value_24") } :
                  { top: $r("app.float.wh_padding_212") })
                .align(Alignment.Center)
                .alignItems(VerticalAlign.Center)
              }
              .padding({ bottom: $r("app.float.wh_padding_112") })
              .height(ConfigData.WH_100_100)
              .alignItems(this.isFocused === false ? VerticalAlign.Bottom : VerticalAlign.Top);
            }
            .width(ConfigData.WH_100_100)
            .height(ConfigData.WH_100_100)
            .alignItems(HorizontalAlign.Center);
          }
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .height(ConfigData.WH_100_100)
          .padding({ left: $r('app.float.padding_24'), right: $r('app.float.padding_24') })
          .alignItems(HorizontalAlign.Start)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor('#F1F3F5')
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  aboutToAppear(): void {
    LogUtil.info(MODULE_TAG + 'about to appear');
    let params = router.getParams();
    if (typeof params === 'undefined' || params === null) {
      LogUtil.info(MODULE_TAG + 'pass invalid params from other page');
      router.back({
        uri: 'pages/wifi',
      });
    }
    this.initTextInputHint();
    this.isConnectedBefore = wifi.isConnected();
    if (this.isConnectedBefore) {
      LogUtil.info(MODULE_TAG + 'start task');
      this.startLinkedInfoTask();
    } else {
      LogUtil.info(MODULE_TAG + 'start observer');
      this.registerObserver();
    }
    this.tobeConnectedAp = params.apInfo;
    this.tobeConnectedSSID = this.tobeConnectedAp.ssid;
    if (deviceTypeInfo === 'phone') {
      this.isPhone = true
    } else {
      this.isPhone = false
    }
  }

  onPageShow() {
    LogUtil.info(MODULE_TAG + 'on page show');
  }

  onPageHide(): void {
    LogUtil.info(MODULE_TAG + 'on page hide');
    this.connectDialog.close();
    this.failedDialog.close();
    if (this.isConnectedBefore) {
      this.clearLinkedInfoTask();
    } else {
      this.unregisterObserver();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(MODULE_TAG + 'about to disappear');
  }

  onBackPress() {
    LogUtil.info(MODULE_TAG + 'on back press');
    router.back({
      uri: 'pages/wifi',
    });
  }

  initTextInputHint() {
    ResourceUtil.getString($r("app.string.wifiPassword")).then(value => {
      this.passwdHint = value;
    });
  }

  registerObserver() {
    LogUtil.info(MODULE_TAG + 'start to register observer');
    WifiModel.registerWiFiConnectionObserver((code: Number) => {
      LogUtil.info(MODULE_TAG + 'wifi connection code : ' + code);
      // 0: disconnected, 1: connected
      if (code === 0) {
        this.connectDialog.close()
        this.failedDialog.open()
        WifiModel.removeDeviceConfig(this.tobeConnectedAp);
      }
      if (code === 1) {
        this.connectDialog.close();
        router.back({
          uri: 'pages/wifi',
        });
      }
      WifiModel.refreshApScanResults();
    });
  }

  unregisterObserver() {
    LogUtil.info(MODULE_TAG + 'start to unregister observer');
    WifiModel.unregisterWiFiConnectionObserver();
  }

  startLinkedInfoTask() {
    LogUtil.info(MODULE_TAG + 'start the get linked info task');
    this.taskId = setInterval(() => {
      wifi.getLinkedInfo((err, result) => {
        if (err) {
          LogUtil.info(MODULE_TAG + 'get linked info failed');
          return;
        }
        // 1: Connecting, 4: Connected, 6: Disconnected
        if (result.ssid === this.tobeConnectedSSID && result.connState === 4) {
          this.connectDialog.close();
          router.back({
            uri: 'pages/wifi',
          });
          WifiModel.refreshApScanResults();
        }
        if (result.connState === 6) {
          this.connectDialog.close()
          this.failedDialog.open()
          WifiModel.removeDeviceConfig(this.tobeConnectedAp);
          WifiModel.refreshApScanResults();
        }
      });
    }, 2000);
  }

  clearLinkedInfoTask() {
    if (this.taskId !== -1) {
      LogUtil.info(MODULE_TAG + 'clear the get linked info task');
      clearInterval(this.taskId);
      this.taskId = -1;
    }
  }
}

@CustomDialog
struct connectProgressDialog {
  controller: CustomDialogController;
  @Prop ssid: string;
  @State message: String= ""

  aboutToAppear() {
    this.message = $r("app.string.wifiTipsConnecting", this.ssid)
  }

  build() {
    Column() {
      Row() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(this.message)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Regular)
            .align(Alignment.Start)
          Column() {
            ImageAnimatorComponent({ imageWidth: $r('app.float.wh_value_24'),
              imageHeight: $r('app.float.wh_value_24') })
          }
        }
        .borderColor($r("app.color.white_bg_color"))
      }
      .alignItems(VerticalAlign.Center)
      .height($r("app.float.wh_value_48"))
      .width($r("app.float.wh_value_362"))
      .margin({ top: $r("app.float.wh_value_24"), bottom: $r("app.float.wh_value_24"),
        left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })
    }
    .width($r("app.float.wh_value_410"))
    .height($r("app.float.wh_value_96"))
    .borderRadius($r("app.float.radius_32"))
    .alignItems(HorizontalAlign.End)
    .backgroundColor($r("app.color.white_bg_color"))
  }
}

@CustomDialog
struct connectFailedDialog {
  controller: CustomDialogController;

  build() {
    Column() {
      Row() {
        Text($r("app.string.wifiTipsConnectAuthFailed"))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .align(Alignment.Start)
      }
      .alignItems(VerticalAlign.Center)
      .margin({ top: $r("app.float.wh_value_24") })
      .height($r("app.float.wh_value_21"))

      Row() {
        Text($r("app.string.wifiTipsGotIt"))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            router.back({
              uri: 'pages/wifi',
            });
          })
      }
      .alignItems(VerticalAlign.Top)
      .margin({ top: $r("app.float.wh_value_8") })
      .padding({ top: $r("app.float.wh_value_9") })
      .height($r("app.float.wh_value_56"))
    }
    .width($r("app.float.wh_value_410"))
    .height($r("app.float.wh_value_109"))
    .borderRadius($r("app.float.radius_32"))
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.white_bg_color"))
  }
}