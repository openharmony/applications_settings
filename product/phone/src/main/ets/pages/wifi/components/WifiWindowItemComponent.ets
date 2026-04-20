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

import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'WifiWindowItemComponent: ';

/**
 * 控制中心wlan列表item组件
 */
@Component
export struct WifiWindowItemComponent {
  private controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State itemBackgroundColor: ResourceColor = Color.Transparent;

  build() {
    Row() {
      this.stateIconBuilder()

      this.textBuilder()

      if (this.menu?.isShowConnected) {
        Column() {
          Image($r('app.media.ic_connect_ok'))
            .fillColor(this.controlCenterColor)
            .size({
              width: $r('app.float.wh_value_18'),
              height: $r('app.float.wh_value_18'),
            })
        }
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .padding({
      left: $r('app.float.wh_value_20'),
      right: $r('app.float.wh_value_20'),
    })
    .backgroundColor(this.itemBackgroundColor)
    .onHover((isHover?: boolean) => {
      this.itemBackgroundColor = isHover ? $r('sys.color.interactive_hover') : Color.Transparent;
    })
    .onClick(() => {
      if (this.controller && this.controller.onMenuClick()) {
        return;
      }
      LogUtil.warn(`${TAG} do not get controller, onClick error`);
    })
  }

  @Builder
  stateIconBuilder() {
    Column() {
      Image(this.uiRefresher.refreshId ? this.menu?.stateIcon : this.menu?.stateIcon)
        .fillColor($r('sys.color.ohos_id_color_secondary'))
        .draggable(false)
        .size({
          width: $r('app.float.wh_value_24'),
          height: $r('app.float.wh_value_24')
        })
    }
  }

  @Builder
  textBuilder() {
    Column() {
      Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
        .fontColor(this.menu?.isShowConnected ? this.controlCenterColor : $r('app.color.window_settings_font_secondary'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .lineHeight($r('app.float.font_22'))
        .textAlign(TextAlign.Start)

      Text(this.uiRefresher.refreshId ? this.menu?.summary : this.menu?.summary)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('app.color.window_settings_font_tertiary'))
        .fontWeight(FontWeight.Regular)
        .lineHeight($r('app.float.font_20'))
        .textAlign(TextAlign.Start)
        .margin({
          top: $r('app.float.length_2'),
        })
    }
    .width('calc(100% - 66vp)')
    .layoutWeight(1)
    .margin({
      left: $r('app.float.wh_value_12'),
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
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} aboutToAppear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}