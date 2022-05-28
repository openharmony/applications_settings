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

import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import ViewModel from '../model/locationServicesImpl/LocationViewModel'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

/**
 * LocationServices
 */
@Entry
@Component
struct LocationServices {
  @StorageLink('LocationServiceStatus') locationServiceStatus: boolean = false;

  aboutToAppear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to appear');
    ViewModel.initViewModel();
  }

  aboutToDisappear(): void {
    LogUtil.info(ConfigData.TAG + 'location service about to disappear');
  }

  build() {
    Column() {
      GridContainer({
        columns: 12,
        sizeType: SizeType.Auto,
        gutter: vp2px(1) === 2 ? '12vp' : '0vp',
        margin: vp2px(1) === 2 ? '24vp' : '0vp'
      }) {
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
            HeadComponent({ headName: $r('app.string.locationServicesTab'), isActive: true });
            Flex({
              direction: FlexDirection.Row,
              justifyContent: FlexAlign.SpaceBetween,
              alignItems: ItemAlign.Center
            }) {
              Row() {
                Text($r('app.string.positionInformation'))
                  .fontColor($r("app.color.font_color_182431"))
                  .fontStyle(FontStyle.Normal)
                  .fontSize($r("app.float.location_font_size"))
                  .margin({
                    left: $r('app.float.distance_24'),
                    top: $r('app.float.distance_8'),
                    bottom: $r('app.float.distance_8')
                  })
              }

              Toggle({ type: ToggleType.Switch, isOn: this.locationServiceStatus })
                .margin({ right: $r('app.float.wh_value_6') })
                .width('36vp')
                .height('20vp')
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  LogUtil.info(ConfigData.TAG + 'location service status is :' + this.locationServiceStatus);
                  if (this.locationServiceStatus === true) {
                    ViewModel.disableLocation();
                  } else {
                    ViewModel.enableLocation();
                  }
                });
            }
            .margin({ top: $r("app.float.distance_8") })
            .height($r('app.float.wh_value_56'))
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
          }
          .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
          .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24') })
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
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
}