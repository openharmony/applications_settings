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
import ComponentConfig from './ComponentConfig';

/**
 * Subheader layout.
 * It's suggested to use it when subheader is needed.
 */
@Component
export struct SubHeader {
  @State titleContent: any = '';

  build() {
    Row() {
      Text(this.titleContent)
        .fontSize($r('app.float.font_14'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .width(ComponentConfig.WH_100_100)
    }
    .height($r("app.float.wh_value_48"))
    .alignItems(VerticalAlign.Bottom)
    .padding({
      bottom: $r('app.float.distance_9_5'),
      top: $r('app.float.distance_11_5'),
      left: $r('sys.float.ohos_id_card_margin_start'),
      right: $r("sys.float.ohos_id_card_margin_end")
    })
  }
}

/**
 * Single title text with round corner.
 */
@Component
export struct TitleText {
  private title: string | Resource;
  private color: ResourceColor = $r('app.color.font_color_182431');
  private visible: Visibility = Visibility.Visible;
  private clickEvent: (event?: ClickEvent) => void;
  @State isTouched: boolean = false;

  build() {
    Row() {
      Row() {
        Text(this.title)
          .fontSize($r("app.float.font_16"))
          .fontColor(this.color)
          .fontWeight(500)
          .textAlign(TextAlign.Start)
          .padding($r('app.float.wh_value_4'))
      }
      .height($r("app.float.wh_value_56"))
      .width(ComponentConfig.WH_100_100)
      .padding({
        left: $r('sys.float.ohos_id_card_margin_start'),
        right: $r('sys.float.ohos_id_card_margin_end')})
      .borderRadius($r("app.float.radius_24"))
      .linearGradient(this.isTouched ? {
                                         angle: 90,
                                         direction: GradientDirection.Right,
                                         colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                       } : {
                                             angle: 90,
                                             direction: GradientDirection.Right,
                                             colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                           })
      .onClick(event => this.clickEvent(event))
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event.type === TouchType.Up) {
          this.isTouched = false;
        }
      })
    }
    .width(ComponentConfig.WH_100_100)
    .margin({ top: $r("app.float.distance_12") })
    .padding($r("app.float.distance_4"))
    .borderRadius($r("app.float.radius_24"))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))

  }
}

/**
 * Text title with end text layout with harmony round style used in list item.
 * Note that this does not contains the white padding when is touched.
 * If you want to use it in single touch layout, wrap it with extra container component.
 */
@Component
export struct TextComponentWithEndText {
  private title: string | Resource;
  private clickEvent: (event?: ClickEvent) => void;
  @State endText: string = "";
  @State isTouched: boolean = false;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text(this.title)
          .fontSize($r('app.float.font_16'))
          .fontColor($r('app.color.font_color_182431'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Start);
      }

      Row() {
        Text(this.endText)
          .fontSize($r('app.float.font_14'))
          .fontColor($r('app.color.font_color_182431'))
          .margin({ right: $r('app.float.distance_4') })
          .textAlign(TextAlign.End);
        Image('/res/image/ic_settings_arrow.svg')
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .fillColor($r("sys.color.ohos_id_color_primary"))
          .opacity($r("app.float.opacity_0_2"))
      }
    }
    .padding({
      left: $r('sys.float.ohos_id_card_margin_start'),
      right: $r('sys.float.ohos_id_card_margin_end')
    })
    .height($r('app.float.wh_value_48'))
    .width(ComponentConfig.WH_100_100)
    .borderRadius($r('app.float.radius_24'))
    .onClick(event => this.clickEvent(event))
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
    });
  }
}