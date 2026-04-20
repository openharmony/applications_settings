/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

/* instrument ignore file */
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const DELAY_TIME: number = 500;

const TAG: string = 'CardContainerView';

@Builder
function dummyFunction() {
};

/**
 * 5.0新样式片卡片组件
 */
@Component
export struct CardContainerView {
  private isBackArrowVisible?: boolean = true;
  @BuilderParam bodyContent: () => void = dummyFunction;
  @State mHeadName: Resource = $r('app.string.uncompleted');
  @Prop mHeadNameStr: string | null = null;
  @State isArrowEnable: boolean = true;
  onButtonClick?: () => void;

  @Styles
  normalStyles(): void {
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .opacity(1)
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .opacity(1)
  }

  build() {
    Column() {
      GridRow({ columns: { sm: 4, md: 8, lg: 12 },
        gutter: {x: { sm: 16, md: 16, lg: 24 } },
        direction: GridRowDirection.Row,
      }) {
        GridCol({ span: { sm: 4, md: 6, lg: 6 }, offset: { sm: 0, md: 1, lg: 3 } }) {
          Column() {
            Column() {
              // 返回箭头
              Column() {
                Image($r('app.media.ic_circle_back'))
                  .height($r('app.float.wh_value_24'))
                  .width($r('app.float.wh_value_24'))
                  .enabled(this.isArrowEnable)
                  .fillColor($r('sys.color.ohos_id_color_titlebar_icon'))
                  .matchTextDirection(true)
                  .draggable(false)
              }
              .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles,
              })
              .id('img_headcomponent_back')
              .height($r('app.float.height_40'))
              .width($r('app.float.height_40'))
              .borderRadius($r('app.float.length_20'))
              .justifyContent(FlexAlign.Center)
              .accessibilityText($r('app.string.back_to_parent_menu'))
              .accessibilityRole(AccessibilityRoleType.BUTTON)
              .onClick(() => {
                if (!(typeof this.onButtonClick === 'function')) {
                  LogUtil.info(`${TAG} no avaliable click function for isArrowEnable: ${this.isArrowEnable}`);
                  return;
                }
                LogUtil.info(`${TAG} aboutToAppear with isArrowEnable: ${this.isArrowEnable}`);
                if (this.isArrowEnable) {
                  this.isArrowEnable = false;
                  this.onButtonClick();
                  setTimeout(() => {
                    this.isArrowEnable = true;
                  }, DELAY_TIME);
                }
              })
            }
            .padding('16vp')
            .width('100%')
            .visibility(this.isBackArrowVisible ? Visibility.Visible : Visibility.Hidden)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)

            Column() {
              // 标题
              Text(this.mHeadNameStr ?? this.mHeadName)
                .id('text_headcomponent_title')
                .fontWeight(600)
                .fontSize($r('app.float.height_36'))
                .maxFontSize($r('app.float.height_36'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .maxLines(2)
                .lineHeight($r('app.float.length_48'))
                .textAlign(TextAlign.Center)
                .width('100%')

            }
            .margin({ bottom: $r('app.float.margin_48') })
            .width('100%')
            .padding({left: $r('app.float.margin_16'), right: $r('app.float.margin_16') })

            // 主体
            if (this.bodyContent) {
              Column() {
                this.bodyContent();
              }
              .layoutWeight(1)
            }
          }
          .borderColor($r('app.color.card_border_color'))
          .borderWidth(1)
          .borderRadius($r('app.float.border_radius_32'))
          .borderStyle(BorderStyle.Solid)
          .backdropBlur(150)
          .width('100%')
          .height('100%')
          .shadow({
            radius: $r('app.float.width_40'),
            offsetX: 0,
            offsetY: 0,
            color: $r('app.color.card_shadow_color'),
          })
          .backgroundColor($r('app.color.card_bg_color'))
          .padding({ bottom: $r('app.float.margin_16') })
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      top: $r('app.float.height_56'),
      left: $r('app.float.margin_16'),
      right: $r('app.float.margin_16'),
      bottom: $r('app.float.wh_value_132'),
    })
  }
}