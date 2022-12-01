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
import ComponentConfig from './ComponentConfig';

/**
 * item custom component
 */
@Component
export default struct DoubleLineComponent {
  @State settingIcon: string = "";
  @State settingTitle: string = "";
  @State settingSummary: string = "";
  @State settingValue: string = "";
  @State settingArrow: any = '';
  @State settingArrowStyle: string = "";
  @State settingUri: string = "";
  @State titleFontColor: any = $r('sys.color.ohos_id_color_text_primary');
  private isEnabled: boolean = true;
  private onArrowClick?: () => void;
  @State isTouched: boolean = false;
  @State heights: any = $r('app.float.wh_value_72');
  @State image_wh: any = $r('app.float.wh_value_40');
  @State fontSize: any = $r('sys.float.ohos_id_text_size_body1');
  @State valueFontSize: any = $r('sys.float.ohos_id_text_size_body2');

  build() {
    Row() {
      Row() {
        Image(this.settingIcon)
          .width(this.image_wh)
          .height(this.image_wh)
          .margin({ right: $r('app.float.wh_value_16') })
          .objectFit(ImageFit.Contain);

        Column() {
          Text(this.settingTitle)
            .fontColor(this.isEnabled ? this.titleFontColor : $r("sys.color.ohos_id_color_primary"))
            .fontSize(this.fontSize)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            Text($r('app.string.version'))
              .fontColor($r('sys.color.ohos_id_color_mask_light'))
              .fontSize(this.valueFontSize)
              .textAlign(TextAlign.Start)
              .fontWeight(FontWeight.Regular)
              .maxLines(ComponentConfig.MAX_LINES_1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .visibility('pages/applicationInfo' === this.settingUri ? Visibility.Visible : Visibility.None)
              .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') })
            Text(this.settingSummary)
              .fontColor($r('sys.color.ohos_id_color_mask_light'))
              .fontSize(this.valueFontSize)
              .fontWeight(FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .maxLines(ComponentConfig.MAX_LINES_1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .visibility('pages/applicationInfo' === this.settingUri ? Visibility.Visible : Visibility.None)
              .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') })
          }
        }
        .alignItems(HorizontalAlign.Start);
      }
      .flexShrink(0)
      .alignItems(VerticalAlign.Center)
      .align(Alignment.Start)

      Blank()

      Row() {
        Text(this.settingValue)
          .fontSize(this.valueFontSize)
          .fontColor($r('sys.color.ohos_fa_text_secondary'))
          .fontWeight('sans-serif')
          .height($r('app.float.wh_value_40'))
          .margin({ left: $r('sys.float.ohos_id_elements_margin_horizontal_l') })
          .align(Alignment.End);

        Stack({ alignContent: Alignment.End }) {
          Image(this.settingArrow)
            .width(this.settingArrowStyle === '' ? $r('app.float.wh_value_12') : $r('app.float.wh_value_40'))
            .height($r('app.float.wh_value_24'))
        }
        .width($r('app.float.wh_value_48'))
        .height($r('app.float.wh_value_48'))
        .margin({ left: $r('app.float.wh_value_4') })
        .visibility('' === this.settingArrow ? Visibility.None : Visibility.Visible)
        .onClick(this.onArrowClick);
      }
      .align(Alignment.End);
    }
    .height(this.heights)
    .width(ComponentConfig.WH_100_100)
    .padding({
      left: $r('sys.float.ohos_id_card_margin_end'),
      right: $r('sys.float.ohos_id_card_margin_end'),
      top: $r('sys.float.ohos_id_elements_margin_vertical_m'),
      bottom: $r('sys.float.ohos_id_elements_margin_vertical_m')
    })
    .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
    .linearGradient((this.isEnabled && this.isTouched) ? {
                                                         angle: 90,
                                                         direction: GradientDirection.Right,
                                                         colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                                       } : {
                                                             angle: 90,
                                                             direction: GradientDirection.Right,
                                                             colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                                           })
    .alignItems(VerticalAlign.Center)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    })
  }
}