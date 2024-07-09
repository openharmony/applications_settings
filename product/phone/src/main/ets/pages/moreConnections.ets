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

import display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';
import NfcModel from '../model/moreConnectionsImpl/NfcModel';
import parameter from '@ohos.systemparameter';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import {
  SubEntryComponent,
  SubEntryComponentWithEndText
} from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import { VpnTypeModel } from '../model/vpnImpl/VpnTypeModel';

const TAG = ConfigData.TAG + 'MoreConnections: ';
const deviceTypeInfo = deviceInfo.deviceType;

/**
 * MoreConnections
 */
@Entry
@Component
struct MoreConnections {
  @StorageLink('nfcStatus') @Watch("nfcStatusChange") nfcStatus: boolean = false;
  @StorageLink('nfcStatusInfo') nfcStatusInfo: Resource = $r("app.string.disabled");
  private maxScreenWidth: number = 0;
  private maxScreenHeight: number = 0;
  private nfcImageWidth: number = 0;
  private nfcImageHeight: number = 0;
  private nfcSupport: string = 'false';

  nfcStatusChange() {
    AppStorage.SetOrCreate("nfcStatusInfo", this.nfcStatus ? $r("app.string.enabled") : $r("app.string.disabled"))
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.moreConnectionsTab'), isActive: true });
          Column() {
            List() {
              // NFC
              if (this.nfcSupport === 'true') {
                ListItem() {
                  SubEntryComponentWithEndText({
                    targetPage: 'pages/nfc',
                    title: $r('app.string.NFC'),
                    endText: $nfcStatusInfo
                  })
                }
              }
              // vpn
              if (VpnTypeModel.getInstance().isSupportVpn()) {
                ListItem() {
                  SubEntryComponent({
                    targetPage: 'pages/vpn/vpnList',
                    title: $r("app.string.VPN"),
                  })
                }
              }
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_15'),
              endMargin: $r('app.float.wh_value_15') })
          }
          .borderRadius($r("app.float.radius_16"))
          .backgroundColor($r("app.color.white_bg_color"))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r("app.float.distance_12") })
          .padding({
            top: $r("app.float.distance_4"),
            bottom: $r("app.float.distance_4")
          })
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

  aboutToAppear() {
    this.nfcSupport = parameter.getSync('const.SystemCapability.Communication.NFC.Core', 'false');
    LogUtil.info(TAG + `nfcSupport ${this.nfcSupport}`);

    if (this.nfcSupport === 'true') {
      this.nfcInit();
    }
  }

  nfcInit(){
    LogUtil.info(TAG + 'aboutToAppear in');

    try {
      this.nfcStatus = !!NfcModel.isNfcOpen();
      LogUtil.info(TAG + 'check whether NFC is open: ' + this.nfcStatus);
      AppStorage.SetOrCreate('nfcStatus', this.nfcStatus);
    } catch (err) {
      LogUtil.error(TAG + 'check nfcStatus api failed');
    }

    NfcModel.registerNfcStatusObserver((code: boolean) => {
      LogUtil.info(TAG + 'NFC state code: ' + code);
    })

    // get screen max width and max height to show nfc image width and height
    display.getDefaultDisplay((err, data) => {
      if (err.code) {
        LogUtil.error(TAG + 'Failed to obtain the default display object. Code:  ' + JSON.stringify(err));
        return;
      }
      LogUtil.info(TAG + 'Succeeded in obtaining the default display object. Data:' + JSON.stringify(data));

      // screen max width
      this.maxScreenWidth = data.width;
      // screen max height
      this.maxScreenHeight = data.height;

      if (deviceTypeInfo === 'phone') {
        if (this.maxScreenWidth < this.maxScreenHeight / 2) {
          this.nfcImageWidth = this.maxScreenWidth * 0.8;
          this.nfcImageHeight = this.maxScreenWidth * 0.8;
        } else {
          this.nfcImageWidth = (this.maxScreenHeight / 2) * 0.8;
          this.nfcImageHeight = (this.maxScreenHeight / 2) * 0.8;
        }
      } else {
        if (this.maxScreenHeight > this.maxScreenWidth / 2) {
          this.nfcImageWidth = (this.maxScreenWidth / 2) * 0.7;
          this.nfcImageHeight = (this.maxScreenWidth / 2) * 0.7;
        } else {
          this.nfcImageWidth = this.maxScreenHeight * 0.7;
          this.nfcImageHeight = this.maxScreenHeight * 0.7;
        }
      }
      AppStorage.SetOrCreate('nfcImageWidth', this.nfcImageWidth);
      AppStorage.SetOrCreate('nfcImageHeight', this.nfcImageHeight);
    })

    LogUtil.info(TAG + 'aboutToAppear out');
  }
}