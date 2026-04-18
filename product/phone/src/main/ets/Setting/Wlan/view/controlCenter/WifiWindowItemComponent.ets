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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ApMenu } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';

const TAG: string = 'WifiWindowItemComponent: ';

/**
 * 控制中心wlan列表item组件
 */
@Component
export struct WifiWindowItemComponent {
  private controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @State menu?: ApMenu = undefined;
  @State isHover: boolean = false;

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
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .accessibilityGroup(true)
    .accessibilityDescription((this.menu?.accessibilityDescription === ' ' && this.menu?.isShowConnected) ? ' ' : '')
    .onClick(() => {
      LogUtil.info(`${TAG} control enter wlan item clicked: ${this.menu?.getLogKey()}`);
      if (this.menu) {
        EventBus.getInstance().emit('EVENT_ID_CONTROL_CENTER_WLAN_CLICK_EVENTS', this.menu);
      }
    })
    .onHover((isHover?: boolean) => {
      this.isHover = isHover ?? false;
    })
  }

  @Builder
  stateIconBuilder() {
    Column() {
      Image(this.menu?.stateIcon)
        .fillColor($r('sys.color.icon_secondary'))
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
      Text(this.menu?.title)
        .fontColor(this.menu?.isShowConnected ? this.controlCenterColor : $r('app.color.window_settings_font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .lineHeight($r('app.float.font_22'))
        .textAlign(TextAlign.Start)

      Text(this.menu?.summary)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_M'))
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
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor(this.isHover ? $r('sys.color.interactive_hover') : $r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
  }
}