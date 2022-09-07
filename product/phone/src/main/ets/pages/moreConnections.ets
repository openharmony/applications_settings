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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubEntryComponentWithEndText } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import { OuterLayoutComponentWithParam } from '../../../../../../common/component/src/main/ets/default/outerLayoutComponent';

const TAG = ConfigData.TAG + 'MoreConnections: ';
const deviceTypeInfo = deviceInfo.deviceType;

/**
 * MoreConnections
 */
@Entry
@Component
struct MoreConnections {
  @StorageLink('nfcStatus') nfcStatus: boolean = false;
  private maxScreenWidth;
  private maxScreenHeight;
  private nfcImageWidth;
  private nfcImageHeight;

  @Builder mMoreConnections(nfcStatus) {
    Column() {
      HeadComponent({ headName: $r('app.string.moreConnectionsTab'), isActive: true });

      Column(){
        SubEntryComponentWithEndText({ targetPage:'pages/nfc', title: $r('app.string.NFC'), endText: nfcStatus ? $r("app.string.enabled") : $r("app.string.disabled") })
      }
      .margin({ top: $r("app.float.distance_8") })
    }
  }

  build() {
    Column(){
      OuterLayoutComponentWithParam({
        mContentComponentWithParam: this.mMoreConnections(this.nfcStatus)
      })
    }
  }

  aboutToAppear(){
    LogUtil.info(TAG + 'aboutToAppear in');

    try {
      this.nfcStatus = !!NfcModel.isNfcOpen();
      LogUtil.info(TAG + 'check whether NFC is open: ' + this.nfcStatus);
      AppStorage.SetOrCreate('nfcStatus', this.nfcStatus);
    } catch (err) {
      LogUtil.error(TAG + 'check nfcStatus api failed');
    }

    NfcModel.registerNfcStatusObserver((code) => {
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
    })

    LogUtil.info(TAG + 'aboutToAppear out');
  }
}