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

import NfcModel from '../model/moreConnectionsImpl/NfcModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';

const TAG = ConfigData.TAG + 'Nfc: ';

@Entry
@Component
struct Nfc {
  @StorageLink('isNfcEnabled') isNfcEnabled: boolean = false;
  @StorageLink('nfcImageWidth') nfcImageWidth: number = null;
  @StorageLink('nfcImageWidth') nfcImageHeight: number = null;
  private switchDebounceFlag = undefined;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.NFC'), isActive: true });

          Image($r("app.media.ic_nfc"))
            .width(this.nfcImageWidth + "px")
            .height(this.nfcImageHeight + "px")

          Text($r("app.string.nfcTips"))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r("app.float.font_14"))
            .lineHeight($r("app.float.lineHeight_19"))
            .fontColor($r("app.color.font_color_182431"))
            .margin({ bottom: $r("app.float.distance_36"), top: $r("app.float.distance_24"), left: $r("app.float.distance_12"), right: $r("app.float.distance_12") })
            .opacity($r("app.float.opacity_100_60"))
            .textAlign(TextAlign.Center)

          Row() {
            Text($r('app.string.NFC'))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontWeight(FontWeight.Medium)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.isNfcEnabled })
              .width('36vp')
              .height('20vp')
              .selectedColor($r("app.color.toggle_selected_color_007DFF"))
              .margin({ left: $r('app.float.wh_value_6') })
              .onChange((isOn: boolean) => {
                this.switchNfcActiveStatus(isOn);
              });
          }
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_56'))
          .backgroundColor($r("app.color.white_bg_color"))
          .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
          .alignItems(VerticalAlign.Center)
          .borderRadius($r('app.float.radius_24'))
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  switchNfcActiveStatus(isOn: boolean) {
    // make the ui change quickly
    this.isNfcEnabled = isOn;
    LogUtil.info(TAG + 'current enable status: ' + this.isNfcEnabled);

    // delay the nfc status change event
    if (this.switchDebounceFlag) {
      clearTimeout(this.switchDebounceFlag);
    }

    this.switchDebounceFlag = setTimeout(() => {
      if (this.isNfcEnabled) {
        let enableNFC = NfcModel.openNfc();
        LogUtil.info(TAG + 'enable nfc: ' + enableNFC);
      } else {
        let disableNFC = NfcModel.closeNfc();
        LogUtil.info(TAG + 'disable nfc: ' + disableNFC);
      }
      this.switchDebounceFlag = undefined;
    }, 1500);
  }

  aboutToAppear() {
    LogUtil.info(TAG + 'aboutToAppear in');
    if (!this.switchDebounceFlag) {
      NfcModel.registerNfcStatusObserver((code) => {
        LogUtil.info(TAG + 'NFC status code: ' + code);
      })
    }

    // init wifi active status
    this.isNfcEnabled = NfcModel.isNfcOpen();
    LogUtil.info(TAG + 'aboutToAppear out');
  }
}