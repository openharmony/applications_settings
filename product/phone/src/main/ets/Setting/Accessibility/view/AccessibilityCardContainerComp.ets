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
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  AccessibilityCardMaterialManager,
  BackButtonMaterialModifierManager
} from './manager/AccessibilityCardMaterialManager'

const DELAY_TIME: number = 500;

const TAG: string = 'AccessibilityCardContainerComp: ';

@Builder
function dummyFunction() {
};

/**
 * 辅助阅读卡片组件
 */
@Component
export struct AccessibilityCardContainerComp {
  private isBackArrowVisible?: boolean = true;
  @BuilderParam bodyContent: () => void = dummyFunction;
  @State mHeadName: Resource = $r('app.string.uncompleted');
  @Prop mHeadNameStr: string | null = null;
  @State isArrowEnable: boolean = true;
  onButtonClick?: () => void;

  build() {
    Column() {
      GridRow({
        columns: { sm: 4, md: 8, lg: 12 },
        gutter: { x: { sm: 16, md: 16, lg: 24 } },
        direction: GridRowDirection.Row,
      }) {
        GridCol({ span: { sm: 4, md: 6, lg: 6 }, offset: { sm: 0, md: 1, lg: 3 } }) {
          Column() {
            Column() {
              // 返回箭头
              Button() {
                SymbolGlyph($r('sys.symbol.chevron_backward'))
                  .height($r('app.float.wh_value_24'))
                  .width($r('app.float.wh_value_24'))
                  .enabled(this.isArrowEnable)
                  .fontColor([$r('sys.color.ohos_id_color_titlebar_icon')])
                  .fontSize($r('app.float.wh_value_24'))
                  .draggable(false)
              }
              .id('img_headcomponent_back')
              .attributeModifier(new BackButtonMaterialModifierManager($r('sys.color.ohos_id_color_button_normal')))
              .height($r('app.float.height_40'))
              .width($r('app.float.height_40'))
              .borderRadius($r('app.float.length_20'))
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
            .padding($r('sys.float.padding_level8'))
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
            .margin({
              bottom: (DeviceUtil.isNextSuperFoldProduct() && ResourceUtil.getStringSync(this.mHeadName) ===
              ResourceUtil.getStringSync($r('app.string.zoom_gesture'))) ? $r('app.float.margin_16') :
              $r('app.float.margin_48')
            })
            .width('100%')
            .padding({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16') })

            // 主体
            if (this.bodyContent) {
              Column() {
                this.bodyContent();
              }
              .layoutWeight(1)
            }
          }
          .attributeModifier(new AccessibilityCardMaterialManager())
          .borderRadius($r('app.float.border_radius_32'))
          .width('100%')
          .height('100%')
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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    AccessibilityUtils.requestFocusAccessibilityWithBundleName('img_headcomponent_back');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}