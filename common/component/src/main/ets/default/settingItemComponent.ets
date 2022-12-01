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

import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import SettingListModel from '../../../../../../product/phone/src/main/ets/model/settingListImpl/SettingListModel';
import prompt from "@ohos.prompt"

@Component
export struct SettingItemComponent {
  private targetPage: string;
  private settingTitle: string | Resource;
  @Link settingEndText: any;
  private settingIcon: string | Resource;
  @State isTouched: boolean = false;

  onPageShow() {
    console.info(`CCCC onPageShow: ${this.targetPage}`)
  }

  aboutToAppear(): void {
    console.info(`CCCC aboutToAppear: ${this.targetPage}`)
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Image(this.settingIcon)
          .width($r("app.float.wh_value_24"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_8"),
            top: $r("app.float.distance_15"),
            bottom: $r("app.float.distance_17")
          })

        Text(this.settingTitle)
          .fontSize($r("app.float.font_16"))
          .lineHeight($r("app.float.lineHeight_22"))
          .fontWeight(FontWeight.Medium)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .align(Alignment.Start)
          .margin({
            left: $r("app.float.distance_16"),
            top: $r("app.float.distance_17"),
            bottom: $r("app.float.distance_17")
          })
      }
      .align(Alignment.Start)
      .height(ConfigData.WH_100_100)

      Row() {
        Text(this.settingEndText)
          .fontSize($r("app.float.font_14"))
          .lineHeight($r("app.float.lineHeight_19"))
          .align(Alignment.End)
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .margin({ top: $r("app.float.distance_19"), bottom: $r("app.float.distance_18") });

        Image('/res/image/ic_settings_arrow.svg')
          .width($r("app.float.wh_value_12"))
          .height($r("app.float.wh_value_24"))
          .margin({
            left: $r("app.float.distance_4"),
            right: $r("app.float.distance_8"),
            top: $r("app.float.distance_16"),
            bottom: $r("app.float.distance_16")
          })
          .fillColor($r("sys.color.ohos_id_color_fourth"))
      }
      .align(Alignment.End)
      .height(ConfigData.WH_100_100);
    }
    .width(ConfigData.WH_100_100)
    .height($r("app.float.wh_value_56"))
    .borderRadius($r("app.float.radius_20"))
    .linearGradient(this.isTouched ? {
                                       angle: 90,
                                       direction: GradientDirection.Right,
                                       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                     } : {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                         })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
    .onClick(() => {
      SettingListModel.onSettingItemClick(this.targetPage);
    })
  }
}