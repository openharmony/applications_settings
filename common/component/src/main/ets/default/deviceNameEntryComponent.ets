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
import ConfigData from '../../../../../utils/src/main/ets/default/baseUtil/ConfigData';

/**
 * item custom component
 */
@Component
export default struct DeviceNameEntryComponent {
  @State isShow: Boolean = true;
  @State settingIcon: string = "";
  @State endTextIsShow: Boolean= true;
  private settingTitle: string | Resource;
  @State settingSummary: any = '';
  @Link settingValue: string;
  @State settingArrow: any = '';
  @State settingArrowStyle: string = "";
  private settingUri: string;
  @State titleFontColor: any = $r('sys.color.ohos_id_color_text_primary');
  private isEnabled: boolean = true
  private onArrowClick?: () => void;
  @State isTouched: boolean = false;
  private heights ?= $r('app.float.wh_value_70');
  private image_wh ?= $r('app.float.wh_value_50');
  private fontSize ?= $r('sys.float.ohos_id_text_size_body1');
  private valueFontSize ?= $r('sys.float.ohos_id_text_size_body2');

  build() {
    Row() {
      Row() {
        Image(this.settingIcon)
          .width(this.image_wh)
          .height(this.image_wh)
          .margin({ right: $r('app.float.wh_10') })
          .visibility('' === this.settingIcon ? Visibility.None : Visibility.Visible)
          .objectFit(ImageFit.Contain)
          .fillColor($r("sys.color.ohos_id_color_primary"))
        Column() {
          Text(this.settingTitle)
            .fontColor(this.isEnabled ? this.titleFontColor : $r("sys.color.ohos_id_color_primary"))
            .fontSize(this.fontSize)
            .textAlign(TextAlign.Start)
            .maxLines(ComponentConfig.MAX_LINES_3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(500)
          Row() {
            Text($r('app.string.version'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .textAlign(TextAlign.Start)
              .maxLines(ComponentConfig.MAX_LINES_1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .visibility('pages/applicationInfo' === this.settingUri ? Visibility.Visible : Visibility.None)
              .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') });

            Text(this.settingSummary)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight('sans-serif')
              .textAlign(TextAlign.Start)
              .maxLines(ComponentConfig.MAX_LINES_1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .visibility('' === this.settingSummary || undefined === this.settingSummary ? Visibility.None : Visibility.Visible)
              .margin({ top: $r('sys.float.ohos_id_text_margin_vertical') });
          }
        }
        .alignItems(HorizontalAlign.Start);
      }
      .flexShrink(0)
      .alignItems(VerticalAlign.Center)
      .align(Alignment.Start)
      .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)

      Row() {
        Text(this.settingValue)
          .fontSize(this.valueFontSize)
          .fontColor($r("sys.color.ohos_id_color_primary"))
          .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
          .fontWeight('HwChinese-medium')
          .height($r('app.float.wh_value_40'))
          .margin({ left: $r('sys.float.ohos_id_elements_margin_horizontal_l'), right: $r('app.float.wh_value_4') })
          .align(Alignment.End)

        if (!this.settingArrowStyle && this.settingArrow) {
          Image(this.settingArrow)
            .visibility('' === this.settingArrow ? Visibility.None : Visibility.Visible)
            .width($r("app.float.wh_value_12"))
            .height($r("app.float.wh_value_24"))
            .margin({ right: $r('app.float.wh_value_8') })
            .fillColor($r("sys.color.ohos_id_color_primary"))
            .opacity($r("app.float.opacity_0_2"))
        } else if (this.settingArrow) {
          Image(this.settingArrow)
            .visibility('' === this.settingArrow ? Visibility.None : Visibility.Visible)
            .fillColor($r("sys.color.ohos_id_color_primary"))
            .width($r('app.float.wh_value_24'))
            .height($r('app.float.wh_value_24'))
            .margin({ right: $r('app.float.wh_value_12') })
            .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
            .onClick(this.onArrowClick)

        }
      }
      .alignItems(VerticalAlign.Center)
      .align(Alignment.End);
    }
    .opacity(this.isEnabled?1:$r('sys.float.ohos_id_alpha_disabled'))
    .height(this.heights)
    .width(ComponentConfig.WH_100_100)
    .padding({ left: $r('sys.float.ohos_id_card_margin_start') })
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