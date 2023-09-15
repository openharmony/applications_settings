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
import prompt from '@ohos.prompt'
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import SettingListModel from '../../../../../../product/phone/src/main/ets/model/settingListImpl/SettingListModel';
import ComponentConfig from './ComponentConfig';

@Component
export struct ServiceItemComponent {
  @State touched: boolean = false;
  private targetPage: string = '';
  private serviceTitle: string | Resource = '';
  private serviceEndText: string = '';
  private serviceIcon: string | Resource = '';

  onPageShow() {
    console.info(`onPageShow: ${this.targetPage}`)
  }

  aboutToAppear(): void {
    console.info(`aboutToAppear: ${this.targetPage}`)
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Image(this.serviceIcon)
          .width($r('app.float.wh_value_24'))
          .height($r('app.float.wh_value_24'))
          .margin({
            left: $r('app.float.distance_8'),
            top: $r('app.float.distance_15'),
            bottom: $r('app.float.distance_17')
          })

        Text(this.serviceTitle)
          .fontSize($r('app.float.font_16'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .maxLines(ComponentConfig.MAX_LINES_3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('90%')
          .margin({
            left: $r('app.float.distance_16')
          })
          .textAlign(TextAlign.Start);
      }
      .align(Alignment.Start)
      .height(ConfigData.WH_100_100)
      .width('70%')

      Row() {
        Text(this.serviceEndText)
          .fontSize($r('app.float.font_14'))
          .lineHeight($r('app.float.lineHeight_19'))
          .align(Alignment.End)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ top: $r('app.float.distance_19'), bottom: $r('app.float.distance_18') });

        Image('/res/image/ic_settings_arrow.svg')
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .margin({
            left: $r('app.float.distance_4'),
            right: $r('app.float.distance_8'),
            top: $r('app.float.distance_16'),
            bottom: $r('app.float.distance_16')
          })
          .fillColor($r('sys.color.ohos_id_color_fourth'))
      }
      .align(Alignment.End)
      .height(ConfigData.WH_100_100);
    }
    .width(ConfigData.WH_100_100)
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_20'))
    .linearGradient(this.touched ? {
      angle: 90,
      direction: GradientDirection.Right,
      colors: [[$r('app.color.DCEAF9'), 0.0], [$r('app.color.FAFAFA'), 1.0]]
    } : {
      angle: 90,
      direction: GradientDirection.Right,
      colors: [[$r('sys.color.ohos_id_color_foreground_contrary'), 1], [$r('sys.color.ohos_id_color_foreground_contrary'), 1]]
    })
    .onTouch((event?: TouchEvent) => {
      if (event?.type === TouchType.Down) {
        this.touched = true;
      }
      if (event?.type === TouchType.Up) {
        this.touched = false;
      }
    })
  }
}