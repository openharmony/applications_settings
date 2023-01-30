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

import { ScreenModeModel } from '../model/displayAndBrightnessImpl/display/ScreenMode';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import { BaseData } from '../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';

/**
 * ScreenMode setting
 */
@Entry
@Component
struct ScreenMode {
  @StorageLink('supportedScreenModes') supportedScreenModes: [] = [];
  @State screenModeModel: ScreenModeModel = new ScreenModeModel();
  private TAG = ConfigData.TAG + 'ScreenMode ';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.screenResolution'), isActive: true });

          Text($r('app.string.screenResolutionWarning'))
            .fontSize($r("sys.float.ohos_id_text_size_body2"))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .margin({ top: $r('app.float.distance_24'), bottom: $r('app.float.distance_24') })
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_12') })
            .width(ConfigData.WH_100_100)

          List() {
            ForEach(this.supportedScreenModes, (item: BaseData,index?:number) => {
              ListItem() {
                Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                  Text(`${this.screenModeModel.getScreenModeWidth(item)} x ${this.screenModeModel.getScreenModeHeight(item)}`)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r("app.float.font_16"))
                    .lineHeight($r("app.float.lineHeight_22"))
                    .fontWeight(FontWeight.Medium)
                    .margin({ top: $r('app.float.distance_8'), bottom: $r("app.float.distance_8") })
                    .textAlign(TextAlign.Start);

                  Radio({ value: this.TAG, group: '' })
                    .height($r("app.float.wh_value_24"))
                    .width($r("app.float.wh_value_24"))
                    .enabled(true)
                    .checked(this.screenModeModel.isSysScreenMode(item))
                    .margin({ top: $r("app.float.distance_12"), bottom: $r("app.float.distance_12"), right: $r("app.float.distance_12")})
                    .onClick(() => {
                      LogUtil.info('settings RadioListComponent : onChange: settingValue = ' + item.settingValue);
                      this.screenModeModel.setSysScreenMode(index);
                    })
                }
                .height($r('app.float.wh_value_48'))
                .width(ConfigData.WH_100_100)
              }
            }, item => JSON.stringify(item));
          }
          .padding({
            left: $r('app.float.wh_value_12'),
            right: $r('app.float.wh_value_4'),
            top: $r('app.float.distance_4'),
            bottom: $r('app.float.distance_4')
          })
          .divider({ strokeWidth: $r('app.float.divider_wh'), color: $r("app.color.color_E3E3E3_grey") })
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
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

  @Log
  aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.screenModeModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.screenModeModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}