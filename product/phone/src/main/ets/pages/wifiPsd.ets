/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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
import wifi from '@ohos.wifi';
import router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import InputMethod from '@ohos.inputmethod';
import WifiModel from '../model/wifiImpl/WifiModel';
import { WifiScanInfo } from '../model/wifiImpl/WifiModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import ImageAnimatorComponent from '../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';

const deviceTypeInfo = deviceInfo.deviceType;
const miniPassWordSize = 8;
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
  private toConnected: boolean = false;
  @State @Watch("controlFailedDialog") ControlFailedDialog : boolean = false;

  private connectDialog: CustomDialogController = new CustomDialogController({
    builder: connectProgressDialog({
      ssid: this.tobeConnectedSSID,
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: false,
    customStyle: true
  });

  private failedDialog: CustomDialogController = new CustomDialogController({
    builder: connectFailedDialog({ControlFailedDialog:$ControlFailedDialog}),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: true,
    customStyle: true
  });

  controlFailedDialog() {
    if(this.ControlFailedDialog){
      this.failedDialog.close();
      this.ControlFailedDialog = false;
    }
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({
            icBackIsVisibility: true,
            headName: this.tobeConnectedSSID,
            isActive: true
          });

          TextInput({ placeholder: this.passwdHint })
            .type(InputType.Password)
            .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
            .caretColor("red")
            .placeholderFont({
              size: $r("app.float.font_16"),
              weight: $r("sys.string.ohos_id_text_font_family_regular"),
              family: "sans-serif", style: FontStyle.Normal
            })
            .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .backgroundColor($r('app.color.color_00000000_transparent'))
            .height($r('app.float.wh_value_48'))
            .borderRadius(0)
            .margin({ top: $r('app.float.wh_value_8') })
            .onFocus(() => {
              LogUtil.info(MODULE_TAG + "text input is focused");
              this.isFocused = true;
            })
            .onFocusMove(() => {
              LogUtil.info(MODULE_TAG + "text input is moved");
              this.isFocused = false;
            })
            .onChange((inputs: string) => {
              this.userInputs = inputs;
            })
            .onSubmit((enterKey) => {
              InputMethod.getInputMethodController().stopInput()
                .then((ret) => {
                  LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                })
            });

          Divider()
            .color($r("sys.color.ohos_id_color_primary"))
            .strokeWidth($r('app.float.wh_value_1'))
            .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
            .padding({
              left: $r('sys.float.ohos_id_default_padding_start'),
              right: $r('sys.float.ohos_id_default_padding_end')
            })

          // Button
          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Row() {
              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text($r('app.string.cancel'))
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontWeight(FontWeight.Medium)
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .height($r('app.float.wh_value_40'))
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .onClick(() => {
                router.back();
              });

              Column()
                .width( $r('app.float.distance_12'))
                .height($r('app.float.application_button_height'))

              Button({ type: ButtonType.Capsule, stateEffect: true }) {
                Text($r('app.string.wifiButtonConnect'))
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontWeight(FontWeight.Medium)
              }
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .height($r('app.float.wh_value_40'))
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .opacity(this.userInputs.length < miniPassWordSize ? $r('sys.float.ohos_fa_alpha_disabled') : 1)
              .onClick(this.userInputs.length < miniPassWordSize ?
                () => { LogUtil.info(MODULE_TAG + 'no text input in passwd page') } :
                () => {
                  WifiModel.setUserSelectedAp(this.tobeConnectedAp);
                  WifiModel.connectWiFi(this.userInputs);
                  this.toConnected = true;
                  this.connectDialog.open();
                });
            }
            .height(ConfigData.WH_100_100)
            .padding(this.isFocused === false ? { bottom: $r("app.float.wh_padding_136") } : { top: $r("app.float.wh_padding_212") })
            .alignItems(this.isFocused === false ? VerticalAlign.Bottom : VerticalAlign.Top)
          }
          .width(ConfigData.WH_100_100)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
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
    this.tobeConnectedAp = params.apInfo;
    this.tobeConnectedSSID = this.tobeConnectedAp.ssid;
  }

  onPageShow() {
    LogUtil.info(MODULE_TAG + 'on page show');
    this.isConnectedBefore = wifi.isConnected();

    if (this.isConnectedBefore) {
      LogUtil.info(MODULE_TAG + 'start task');
      this.startLinkedInfoTask();
    } else {
      LogUtil.info(MODULE_TAG + 'start observer');
      this.registerObserver();
    }
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
    LogUtil.info('settings wifiPsd onBackPress');
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
      if(!this.toConnected){
        return;
      }

      if (code === 0) {
        this.toConnected = false;
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

        if (result.connState === 6 && this.toConnected) {
          this.toConnected = false;
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
      Column() {
        Row() {
          Text(this.message)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Regular)
            .align(Alignment.Start)

          Blank()

          ImageAnimatorComponent({ imageWidth: $r('app.float.wh_value_24'),
            imageHeight: $r('app.float.wh_value_24') })
        }
        .alignItems(VerticalAlign.Center)
        .height($r("app.float.wh_value_48"))
        .width($r(ConfigData.WH_100_100))
        .margin($r("app.float.wh_value_24"))
      }
      .height($r("app.float.wh_value_96"))
      .borderRadius($r("app.float.radius_32"))
      .backgroundColor($r("app.color.white_bg_color"))
    }
    .width(deviceTypeInfo === 'phone' ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(deviceTypeInfo === 'phone' ? { left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12")} : {})
  }
}

@CustomDialog
struct connectFailedDialog {
  controller: CustomDialogController;
  @Link ControlFailedDialog: boolean;

  build() {
    Column() {
      Column() {
        Text($r("app.string.wifiTipsConnectAuthFailed"))
          .fontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r("app.float.wh_value_24") })
          .height($r("app.float.wh_value_21"))

        Row() {
          Text($r("app.string.wifiTipsGotIt"))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.ControlFailedDialog = true;
            })
        }
        .alignItems(VerticalAlign.Top)
        .margin({ top: $r("app.float.wh_value_8") })
        .padding({ top: $r("app.float.wh_value_9") })
        .height($r("app.float.wh_value_56"))
      }
      .height($r("app.float.wh_value_109"))
      .width(ConfigData.WH_100_100)
      .borderRadius($r("app.float.radius_32"))
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r("app.color.white_bg_color"))
    }
    .width(deviceTypeInfo === 'phone' ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(deviceTypeInfo === 'phone' ? { left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") } : {})
  }
}
