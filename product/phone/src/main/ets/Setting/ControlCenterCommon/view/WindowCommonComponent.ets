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
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';

const MAX_FONT_SCALE: number = 1.5;
const PANEL_EMPTY_HEIGHT: string = '60%';

/**
 * 星闪和蓝牙控制中心二级页面-标题组件
 */
@Builder
export function titleComponentBuilder(icon: ResourceStr | PixelMap, title: ResourceStr, domId: string) {
  Column() {
    Column() {
      Image(icon)
        .fillColor($r('app.color.window_settings_icon_primary'))
        .advancedBlendMode(BlendModeUtil.getCenterBlender())
        .size({
          width: $r('app.float.wh_value_24'),
          height: $r('app.float.wh_value_24'),
        })
        .draggable(false)
    }
    .margin({
      bottom: $r('app.float.wh_value_8'),
    })

    Text(title)
      .fontFamily('HarmonyHeiTi')
      .advancedBlendMode(BlendModeUtil.getCenterBlender())
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('app.color.window_settings_font_primary'))
      .lineHeight($r('app.float.wh_value_26'))
      .height($r('app.float.wh_value_26'))
      .id(domId)
  }
  .width('100%')
  .padding({
    top: $r('app.float.wh_value_16'),
    bottom: $r('app.float.wh_value_16'),
  })
  .alignItems(HorizontalAlign.Center)
}

/**
 * 蓝牙外屏控制中心二级页面-标题组件
 */
@Builder
export function outerScreenTitleComponentBuilder(icon: ResourceStr | PixelMap, title: ResourceStr, domId: string) {
  Row() {
    Column() {
      Image(icon)
        .fillColor($r('app.color.window_settings_icon_primary'))
        .size({
          width: $r('app.float.wh_value_24'),
          height: $r('app.float.wh_value_24'),
        })
        .draggable(false)
    }
    .margin({
      bottom: $r('app.float.wh_value_8'),
      end: PADDING_8,
    })

    Text(title)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.ohos_id_text_size_headline8'))
      .fontColor($r('app.color.window_settings_font_primary'))
      .lineHeight($r('app.float.wh_value_26'))
      .height($r('app.float.wh_value_26'))
      .id(domId)
  }
  .width('100%')
  .padding({
    top: $r('app.float.wh_value_16'),
    bottom: $r('app.float.wh_value_16'),
  })
  .justifyContent(FlexAlign.Center)
}

/**
 * 星闪和蓝牙控制中心二级页面-更多设置按钮组件
 */
@Component
export struct MoreSettingButtonComponent {
  @State bgColor: ResourceColor = Color.Transparent;
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  onMoreSettingClick?: () => void;

  build() {
    Column() {
      Text($r('app.string.wifi_more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_16'))
        .fontColor(this.controlCenterColor)
        .lineHeight($r('app.float.font_21'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(MAX_FONT_SCALE)
    }
    .borderRadius($r('app.float.wh_value_20'))
    .backgroundColor(this.bgColor)
    .alignItems(HorizontalAlign.Center)
    .margin({
      top: $r('app.float.wh_value_6'),
      bottom: $r('app.float.wh_value_16'),
      left: $r('app.float.wh_value_16'),
      right: $r('app.float.wh_value_16'),
    })
    .padding({
      top: $r('app.float.wh_value_10'),
      bottom: $r('app.float.wh_value_10'),
    })
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event)
    })
    .onClick((event) => {
      this.onMoreSettingClick?.();
    })
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.ohos_id_color_hover');
    } else {
      this.bgColor = Color.Transparent;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (event && event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.ohos_id_color_click_effect');
    }
    if (event && event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (event && event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.ohos_id_color_click_effect');
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }
}

/**
 * 星闪和蓝牙控制中心二级页面-没有已配对设备场景
 */
@Component
export struct NoPairedDeviceComponent {
  build() {
    Column() {
      Image($r('app.media.ic_bluetooth_control_panel_empty'))
        .size({
          height: PANEL_EMPTY_HEIGHT,
        })
        .draggable(false)
        .advancedBlendMode(BlendModeUtil.getCenterBlender())

      Text($r('app.string.bluetooth_no_paired_devices'))
        .fontColor($r('app.color.window_settings_font_tertiary'))
        .fontSize($r('app.float.font_14'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({ minHeight: $r('app.float.wh_value_19') })
        .maxFontScale(MAX_FONT_SCALE)
        .margin({
          top: 8,
          bottom: 9,
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}