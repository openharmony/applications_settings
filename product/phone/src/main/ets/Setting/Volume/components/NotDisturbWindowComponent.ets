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
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { NotDisturbMenuEntry } from '../view/NotDisturbMenuEntry';
import { NotDisturbWindowViewModel } from '../viewmodel/NotDisturbWindowViewModel';

const OPACITY_PERCENT_FULL: number = 1;
const ALPHA_DISABLED: Resource = $r('sys.float.alpha_tertiary');

/**
 * 控制中心免打扰列表item组件
 */
@Component
export struct NoDisturbWindowComponent {
  private controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @ObjectLink menu: NotDisturbMenuEntry;
  @Link notDisturbWindowViewModel: NotDisturbWindowViewModel;
  @State itemBackgroundColor: ResourceColor = Color.Transparent;

  build() {
    Row() {
      this.textBuilder();

      if (this.menu.isSelected) {
        Image($r('app.media.ic_connect_ok'))
          .fillColor(this.controlCenterColor)
          .size({
            width: $r('app.float.wh_value_18'),
            height: $r('app.float.wh_value_18'),
          })
      }
    }
    .accessibilityDescription(this.menu.isSelected ? $r('app.string.be_chosen') :
    $r('app.string.not_selected_click_tips'))
    .accessibilityLevel(this.menu.isEnabled ? AccessibilityLevelType.YES : AccessibilityLevelType.NO)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .opacity(this.menu.isEnabled ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .onClick(() => {
      this.notDisturbWindowViewModel.handleClickEvent(this.menu.key, this.menu.id);
    })
    .enabled(this.menu.isEnabled)
    .backgroundColor(this.itemBackgroundColor)
    .onHover((isHover?: boolean) => {
      this.itemBackgroundColor = isHover ? $r('sys.color.interactive_hover') : Color.Transparent;
    })
  }

  @Builder
  textBuilder() {
    Column() {
      Text(this.menu?.title)
        .fontColor(this.menu.isSelected ? this.controlCenterColor : $r('app.color.window_settings_font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({ minHeight: $r('app.float.wh_value_21') })
        .textAlign(TextAlign.Start)
        .maxFontScale(2)

      Text(this.menu.subTitle)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.window_settings_font_tertiary'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({ minHeight: $r('app.float.wh_value_21') })
        .textAlign(TextAlign.Start)
        .maxFontScale(2)
        .margin({
          top: $r('app.float.length_2'),
        })
    }
    .width('calc(100% - 66vp)')
    .layoutWeight(1)
    .margin({
      right: $r('app.float.wh_value_10'),
    })
    .padding({
      top: $r('app.float.wh_value_10'),
      bottom: $r('app.float.wh_value_10'),
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }
}