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

import AboutDeviceModel from '../model/aboutDeviceImpl/AboutDeviceModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubEntryComponentWithEndText } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';

/**
 * about phone
 */
@Entry
@Component
struct AboutDevice {
  @StorageLink("systemName") systemName: string = AboutDeviceModel.getSystemName();
  private deviceInfo: any = '';
  private aboutDeviceList: any[] = [];

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.aboutTab'), isActive: true })

          SubEntryComponentWithEndText({
            targetPage: "pages/deviceName",
            title: $r("app.string.deviceName"),
            endText: $systemName
          })
            .width(ConfigData.WH_100_100)
            .margin({ bottom: $r("app.float.distance_12"), top: $r("app.float.distance_8") })

          List() {
            ForEach(this.aboutDeviceList, (item) => {
              ListItem() {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Text(item.settingTitle)
                    .fontSize($r("app.float.font_16"))
                    .lineHeight($r("app.float.wh_value_22"))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .padding({ top: $r('app.float.distance_12'), bottom: $r('app.float.distance_12') })
                    .textAlign(TextAlign.Start);

                  Text(item.settingValue)
                    .fontSize($r("app.float.font_16"))
                    .lineHeight($r("app.float.wh_value_22"))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .padding({ top: $r('app.float.distance_12'), bottom: $r('app.float.distance_12') })
                    .textAlign(TextAlign.End);
                }
                .width(ConfigData.WH_100_100)
              }
            })
          }
          .divider({ strokeWidth: $r('app.float.divider_wh'), color: $r('sys.color.ohos_id_color_list_separator') })
          .padding({
            left: $r('sys.float.ohos_id_card_margin_start'),
            right: $r('sys.float.ohos_id_card_margin_start'),
            top: $r('app.float.distance_4'),
            bottom: $r('app.float.distance_4')
          })
          .borderRadius($r('app.float.distance_24'))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
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

  private getDeviceInfo(): void {
    for (let key in this.aboutDeviceList) {
      let value = this.aboutDeviceList[key].settingAlias;

      if ('model' === value) {
        this.aboutDeviceList[key].settingValue = this.deviceInfo.productModel;
        this.aboutDeviceList[key].settingTitle = $r('app.string.model');
      };

      if ('companyInfo' === value) {
        this.aboutDeviceList[key].settingValue = this.deviceInfo.manufacture;
        this.aboutDeviceList[key].settingTitle = $r('app.string.companyInfo');
      };

      if ('deviceId' === value) {
        this.aboutDeviceList[key].settingValue = this.deviceInfo.serial;
        this.aboutDeviceList[key].settingTitle = $r('app.string.deviceId');
      };

      if ('softwareVersion' === value) {
        this.aboutDeviceList[key].settingValue = this.deviceInfo.displayVersion;
        this.aboutDeviceList[key].settingTitle = $r('app.string.softwareVersion');
      };
    }
  }

  aboutToAppear(): void {
    LogUtil.info(ConfigData.TAG + 'settings get device info come in');

    this.deviceInfo = AboutDeviceModel.setOnAboutDeviceListener();
    this.aboutDeviceList = AboutDeviceModel.getAboutDeviceInfoListener();
    this.getDeviceInfo();
    LogUtil.info(ConfigData.TAG + 'settings get device info' +
    JSON.stringify(AboutDeviceModel.setOnAboutDeviceListener()));

    LogUtil.info(ConfigData.TAG + 'settings get device info end in');
  }

  onPageShow() {
    AppStorage.SetOrCreate("systemName", AboutDeviceModel.getSystemName())
  }
}
