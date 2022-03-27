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
import ImageAnimatorComponent from '../../../../../../../common/component/src/main/ets/default/imageAnimatorComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import AppManagementModel from '../model/appManagementImpl/AppManagementModel';
import DoubleLineComponent from '../../../../../../../common/component/src/main/ets/default/doubleLineComponent.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Router from '@system.router';

/**
 * application list
 */
@Entry
@Component
struct AppManagement {
  @StorageLink('appManagementList') appList: any[]= [];

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
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
            HeadComponent({ headName: $r('app.string.appManagement'), isActive: true });
            Column() {
              ImageAnimatorComponent({ imageWidth: $r('app.float.wh_value_80'),
                imageHeight: $r('app.float.wh_value_80'), whtl: $r('app.float.wh_value_80') });
            }
            .zIndex(1)
            .visibility(this.appList.length > 0 ? Visibility.None : Visibility.Visible)
            .align(Alignment.Center)
            .padding({ top: ConfigData.WH_35_100 })
            .width(ConfigData.WH_100_100)
            .height(ConfigData.WH_100_100);

            Row() {
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
              .divider({
                strokeWidth: 1,
                color: $r('app.color.color_E3E3E3_grey'),
                startMargin: $r('app.float.wh_value_65'),
                endMargin: $r('sys.float.ohos_id_card_margin_end')
              })
              .margin({ bottom: $r('app.float.wh_value_70') })
              .visibility(this.appList.length > 0 ? Visibility.Visible : Visibility.None)
              .zIndex(0);
            }
            .borderRadius($r("app.float.radius_24"))
            .backgroundColor($r("app.color.white_bg_color"))
            .padding($r('app.float.distance_4'))
          }
          .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end'), top:$r('app.float.distance_12') })
          .align(Alignment.Center)
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

  private aboutToAppear(): void{
    LogUtil.info('settings AppManagement aboutToAppear in');
    AppManagementModel.setAppManagementListener();
    LogUtil.info('settings AppManagement aboutToAppear  appList:' + JSON.stringify(this.appList));
  }

  onBackPress() {
    LogUtil.info('settings AppManagement onBackPress in');
    Router.back();
    LogUtil.info('settings AppManagement onBackPress out');
  }

  private aboutToDisappear(): void{
    LogUtil.info('settings AppManagement aboutToDisappear in');
    AppStorage.Delete('appManagementList');
    LogUtil.info('settings AppManagement aboutToDisappear out');
  }
}