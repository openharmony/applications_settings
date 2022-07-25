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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import {SubEntryComponentWithEndText} from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import NfcModel from '../model/moreConnectionsImpl/NfcModel';
import display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';

const TAG = ConfigData.TAG + 'MoreConnections: ';
const deviceTypeInfo = deviceInfo.deviceType;

/**
 * MoreConnections
 */
@Entry
@Component
struct MoreConnections {
  @State columnMargin: string = '24vp';
  @State nfcEnable: string = '';
  @StorageLink('nfcStatus') nfcStatus: boolean = NfcModel.isNfcOpen();
  private maxScreenWidth;
  private maxScreenHeight;
  private nfcImageWidth;
  private nfcImageHeight;

  build() {
    Column() {
      GridContainer({columns: 12, sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row() {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            HeadComponent({ headName: $r('app.string.moreConnectionsTab'), isActive: true })
            Column({space: this.columnMargin}){
              SubEntryComponentWithEndText({targetPage:'pages/nfc', title: $r('app.string.NFC'), endText: this.nfcStatus ? $r("app.string.enabled") : $r("app.string.disabled")})
            }
            .margin({ top: $r("app.float.distance_8") })
            .width(ConfigData.WH_100_100)
          }
          .margin({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end') })
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
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
          });
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

  aboutToAppear(){
    LogUtil.info(TAG + 'aboutToAppear in');
    ResourceUtil.getString($r('app.float.distance_24')).then(value => this.columnMargin = value);

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
      }
      else {
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
      LogUtil.info('cq=====' + this.nfcImageWidth + typeof(this.maxScreenHeight));
    })

    LogUtil.info(TAG + 'aboutToAppear out');
  }
}