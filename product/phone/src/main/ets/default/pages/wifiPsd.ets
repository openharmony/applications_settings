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
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ImageAnimatorComponent from '../../../../../../../common/component/src/main/ets/default/imageAnimatorComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import WifiModel from '../model/wifiImpl/WifiModel';
import {WifiScanInfo} from '../model/wifiImpl/WifiModel';
import wifi from '@ohos.wifi';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import router from '@system.router'
import InputMethod from '@ohos.inputmethod';

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

  private connectDialog: CustomDialogController = new CustomDialogController({
    builder: connectProgressDialog({
      ssid: $tobeConnectedSSID,
    }),
    autoCancel: false,
    customStyle: true
  });

  private failedDialog: CustomDialogController = new CustomDialogController({
    builder: connectFailedDialog({}),
    autoCancel: true,
    customStyle: true
  });

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'})
      {
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
            HeadComponent({
              icBackIsVisibility: true,
              headName: this.tobeConnectedSSID,
              isActive: true
            });

            TextInput({ placeholder: this.passwdHint })
              .type(InputType.Password)
              .placeholderColor($r("app.color.color_D8D8D8_grey"))
              .placeholderFont({ size: $r("app.float.font_16"),
                weight: $r("sys.string.ohos_id_text_font_family_regular"),
                family: "sans-serif", style: FontStyle.Normal })
              .caretColor(Color.Blue)
              .backgroundColor(Color.White)
              .height($r('app.float.wh_value_48'))
              .borderRadius($r("app.float.radius_24"))
              .margin({
                top:$r('app.float.wh_value_8'),
                left: $r('app.float.wh_value_12'),
                right: $r('app.float.wh_value_12')
              })
              .onFocus(() => {
                LogUtil.info(MODULE_TAG + "text input is focused");
                this.isFocused = true;
              })
              .onFocusMove(() => {
                LogUtil.info(MODULE_TAG + "text input is focus moved");
                this.isFocused = false;
              })
              .onChange((inputs: string) => {
                this.userInputs = inputs;
              })
              .onSubmit((enterKey) => {
                InputMethod.getInputMethodController().stopInput().then((ret) => {
                  LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                });
              });

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
                  .margin({right: $r('app.float.wh_value_6')})
                  .align(Alignment.Center)
                  .backgroundColor($r('app.color.color_E3E3E3_grey'))
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
                  .margin({left: $r('app.float.wh_value_6')})
                  .align(Alignment.Center)
                  .backgroundColor($r('app.color.color_E3E3E3_grey'))
                  .opacity(this.userInputs.length === 0 ? 0.5 : 1)
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
                  {bottom: $r("app.float.wh_value_24")} :
                  {top: $r("app.float.wh_value_212")})
                .align(Alignment.Center)
                .alignItems(VerticalAlign.Center)
              }
              .height(ConfigData.WH_100_100)
              .padding({bottom: $r("app.float.wh_value_118")})
              .alignItems(this.isFocused === false ? VerticalAlign.Bottom : VerticalAlign.Top);
            }
            .width(ConfigData.WH_100_100)
            .height(ConfigData.WH_100_100)
            .alignItems(HorizontalAlign.Center);
          }
          .height(ConfigData.WH_100_100)
          .padding({left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
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
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
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
  @Link ssid: string;
  private message: string = $r("app.string.wifiTipsConnecting", this.ssid);

  build() {
    Column() {
      Row() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center}) {
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
      .margin({top: $r("app.float.wh_value_24"), bottom: $r("app.float.wh_value_24"),
        left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24")})
    }
    .width($r("app.float.wh_value_410"))
    .height($r("app.float.wh_value_96"))
    .borderRadius($r("app.float.radius_32"))
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.white_bg_color"))
  }
}

@CustomDialog
struct connectFailedDialog {
  controller: CustomDialogController;

  build() {
    Column() {
      Row() {
        Text($r("app.string.wifiTipsConnectFailed"))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .align(Alignment.Start)
      }
      .alignItems(VerticalAlign.Center)
      .margin({top: $r("app.float.wh_value_24")})
      .height($r("app.float.wh_value_21"))
      Row() {
        Text($r("app.string.wifiTipsGotIt"))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Start)
        .onClick(() => {
          router.back({
            uri: 'pages/wifi',
          });
        })
      }
      .alignItems(VerticalAlign.Center)
      .margin({top: $r("app.float.wh_value_8")})
      .height($r("app.float.wh_value_56"))
    }
    .width($r("app.float.wh_value_410"))
    .height($r("app.float.wh_value_109"))
    .borderRadius($r("app.float.radius_32"))
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r("app.color.white_bg_color"))
  }
}
