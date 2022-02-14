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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import router from '@system.router'

const MODULE_TAG = ConfigData.TAG + '.WifiPasswd -> ';

/**
 * wifi password setting page
 */
@Entry
@Component
struct WifiPsd {
  @State text: string= '';
  @State passwdPlaceholder: string = '';
  apInfo: any = null;
  isConnected: boolean = false;

  build() {
    Column() {
      HeadComponent({
        icBackIsVisibility: true,
        headName: this.apInfo.ssid,
        isActive: true
      });

      Column() {
        Row() {
          Text($r('app.string.wifiMAC'))
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
          Text(':')
            .margin({
              left: $r('app.float.wh_value_15'),
              right: $r('app.float.wh_value_15')
            });
          Text(this.apInfo.bssid)
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
        }
        .margin({
            left: $r('app.float.wh_value_15'),
            top: $r('app.float.wh_value_20'),
            right: $r('app.float.wh_value_15')});

        Row() {
          Text($r('app.string.signalLevel'))
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
          Text(':')
            .margin({
              left: $r('app.float.wh_value_15'),
              right: $r('app.float.wh_value_15')
            });
          Text(this.apInfo.rssi.toString())
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
        }
        .margin({
          left: $r('app.float.wh_value_15'),
          top: $r('app.float.wh_value_20'),
          right: $r('app.float.wh_value_15')});

        Row() {
          Text($r('app.string.signalBand'))
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
          Text(':')
            .margin({
              left: $r('app.float.wh_value_15'),
              right: $r('app.float.wh_value_15')
            });
          Text(this.apInfo.band.toString())
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
        }
        .margin({
          left: $r('app.float.wh_value_15'),
          top: $r('app.float.wh_value_20'),
          right: $r('app.float.wh_value_15')})

        Row() {
          Text($r('app.string.encryptMethod'))
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
          Text(':')
            .margin({
              left: $r('app.float.wh_value_15'),
              right: $r('app.float.wh_value_15')
            });
          Text(this.apInfo.securityType.toString())
            .fontSize($r('app.float.font_28'))
            .fontColor(Color.Black)
            .textAlign(TextAlign.Start);
        }
        .margin({
          left: $r('app.float.wh_value_15'),
          top: $r('app.float.wh_value_20'),
          right: $r('app.float.wh_value_15')})
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)
      .width(ConfigData.WH_100_100)
      .margin({ top: $r('app.float.wh_value_20') });

      TextInput({ placeholder: this.passwdPlaceholder })
        .type(InputType.Password)
        .placeholderColor(Color.Blue)
        .placeholderFont({ size: ConfigData.font_20, weight: 2, family: "sans-serif", style: FontStyle.Normal })
        .caretColor(Color.Blue)
        .backgroundColor(Color.White)
        .height($r('app.float.wh_value_70'))
        .margin({
          top:$r('app.float.wh_value_20'),
          left: $r('app.float.wh_value_15'),
          right: $r('app.float.wh_value_15')
        })
        .borderRadius($r('app.float.wh_value_15'))
        .visibility(this.isConnected === true ? Visibility.None : Visibility.Visible)
        .onChange((inputs: string) => {
          this.text = inputs;
        });

      Row() {
        Button() {
          Text($r('app.string.cancel'))
            .fontSize($r('app.float.font_24'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r('app.float.wh_value_160'))
        .align(Alignment.Center)
        .margin({left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15')})
        .onClick(() => {
          router.back();
        });
        Button() {
          Text($r('app.string.confirm'))
            .fontSize($r('app.float.font_24'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r('app.float.wh_value_160'))
        .align(Alignment.Center)
        .margin({left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15')})
        .visibility(this.isConnected === true ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          router.back({
            uri: 'pages/wifi',
            params: {
              opType: 'connect',
              password: this.text
            }
          });
        });
        Button() {
          Text($r('app.string.disconnect'))
            .fontSize($r('app.float.font_24'))
            .fontColor(Color.Blue)
        }
        .backgroundColor($r('app.color.color_E3E3E3_grey'))
        .width($r('app.float.wh_value_160'))
        .align(Alignment.Center)
        .margin({left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15')})
        .visibility(this.isConnected === false ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          router.back({
            uri: 'pages/wifi',
            params: {opType: 'disconnect'}
          });
        });
      }
      .alignItems(VerticalAlign.Center)
      .width(ConfigData.WH_100_100)
      .margin({ top: $r('app.float.wh_value_20')})
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White);
  }

  aboutToAppear(): void {
    let params = router.getParams();
    LogUtil.info(MODULE_TAG + 'settings wifiPsd aboutToAppear params : ' + JSON.stringify(params));
    this.apInfo = params.apInfo;
    this.isConnected = params.isConnected;
    ResourceUtil.getString($r("app.string.wifiPassword")).then(value => {
      this.passwdPlaceholder = value;
    });
  }

  onBackPress() {
    router.back();
  }
}
