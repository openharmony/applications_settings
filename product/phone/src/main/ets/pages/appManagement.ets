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

import Router from '@system.router';
import AppManagementModel from '../model/appManagementImpl/AppManagementModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import DoubleLineComponent from '../../../../../../common/component/src/main/ets/default/doubleLineComponent';
import ImageAnimatorComponent from '../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';

/**
 * application list
 */
@Entry
@Component
struct AppManagement {
  @StorageLink('appManagementList') appList: any[] = [];
  private whtl: string = '80vp';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.appManagement'), isActive: true });

          if (this.appList.length <= 0) {
            ImageAnimatorComponent({
              imageWidth: $r('app.float.wh_value_80'),
              imageHeight: $r('app.float.wh_value_80'), whtl: this.whtl
            })
              .margin({ top: $r("app.float.distance_8") })
              .zIndex(1)
              .align(Alignment.Center)
              .padding({ top: ConfigData.WH_35_100 })
              .width(ConfigData.WH_100_100)
              .height(ConfigData.WH_100_100);
          }

          Column() {
            List() {
              ForEach(this.appList, (item) => {
                ListItem() {
                  DoubleLineComponent({
                    settingIcon: item.settingIcon,
                    settingTitle: item.settingTitle + '',
                    settingSummary: item.settingSummary,
                    settingValue: item.settingValue,
                    settingArrow: item.settingArrow,
                    settingArrowStyle: '',
                    settingUri: item.settingUri,
                    fontSize: $r('sys.float.ohos_id_text_size_body1'),
                    valueFontSize: $r('sys.float.ohos_id_text_size_body2')
                  });
                }
                .onClick(() => {
                  Router.push({ uri: item.settingUri, params: item });
                })
                .height($r('app.float.wh_value_72'));
              }, item => JSON.stringify(item));
            }
            .borderRadius($r("app.float.radius_24"))
            .divider({
              strokeWidth: 1,
              color: $r('app.color.color_E3E3E3_grey'),
              startMargin: $r('app.float.wh_value_65'),
              endMargin: $r('sys.float.ohos_id_card_margin_end')
            })
            .visibility(this.appList.length > 0 ? Visibility.Visible : Visibility.None)
            .zIndex(0);
          }
          .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .padding($r('app.float.distance_4'))
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

  aboutToAppear(): void{
    LogUtil.info('settings AppManagement aboutToAppear in');

    AppStorage.SetOrCreate('appManagementList', []);
    AppManagementModel.setAppManagementListener();
    ResourceUtil.getString($r('app.float.wh_value_80')).then(value => this.whtl = value);
    LogUtil.info('settings AppManagement aboutToAppear  appList:' + JSON.stringify(this.appList));

    LogUtil.info('settings AppManagement aboutToAppear out');
  }

  aboutToDisappear(): void{
    LogUtil.info('settings AppManagement aboutToDisappear in');
    AppStorage.Delete('appManagementList');
    LogUtil.info('settings AppManagement aboutToDisappear out');
  }
}