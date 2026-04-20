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

import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
/* instrument ignore file */
const TAG: string = 'HotspotWindowComponent: ';

const PANEL_EMPTY_HEIGHT: string = '60%';

const MAX_FONT_SCALE: number = 1.5;

/**
 * 个人热点二级页面-标题组件
 */
@Builder
export function hotspotWindowTitleBuilder(symbol: Resource, title: ResourceStr, domId: string) {
  Column() {
    Column() {
      SymbolGlyph(symbol)
        .size({
          width: $r('app.float.wh_value_24'),
          height: $r('app.float.wh_value_24'),
        })
        .fontSize($r('app.float.wh_value_24'))
        .fontColor([$r('sys.color.ohos_id_color_primary')])
        .advancedBlendMode(BlendModeUtil.getCenterBlender())
    }
    .margin({
      bottom: $r('app.float.wh_value_8'),
    })

    Text(title)
      .fontFamily('HarmonyHeiTi')
      .fontWeight(FontWeight.Medium)
      .advancedBlendMode(BlendModeUtil.getCenterBlender())
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

@Component
export struct connectDeviceItemWindowComponent {
  @Prop deviceName: ResourceStr;
  @Prop ipString: ResourceStr;
  @Prop macString: ResourceStr;
  @State itemBackgroundColor: ResourceColor = Color.Transparent;

  build() {
    ListItem() {
      Row() {
        Column() {
          SymbolGlyph($r('sys.symbol.hotspot'))
            .fontSize($r('app.float.wh_value_24'))
            .fontColor([$r('sys.color.ohos_id_color_primary')])
            .draggable(false)
            .advancedBlendMode(BlendModeUtil.getCenterBlender())
        }

        Column() {
          Text(this.deviceName)
            .fontColor($r('app.color.window_settings_font_secondary'))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight($r('app.float.font_21'))
            .maxFontScale(MAX_FONT_SCALE)
          Text(this.ipString)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('app.float.font_14'))
            .fontColor($r('app.color.window_settings_font_tertiary'))
            .fontWeight(FontWeight.Regular)
            .lineHeight($r('app.float.font_19'))
            .textAlign(TextAlign.Start)
            .maxFontScale(MAX_FONT_SCALE)
            .margin({
              top: $r('app.float.length_2'),
            })
          Text(this.macString)
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('app.float.font_14'))
            .fontColor($r('app.color.window_settings_font_tertiary'))
            .fontWeight(FontWeight.Regular)
            .lineHeight($r('app.float.font_19'))
            .textAlign(TextAlign.Start)
            .maxFontScale(MAX_FONT_SCALE)
            .margin({
              top: $r('app.float.length_2'),
            })
        }
        .layoutWeight(1)
        .margin({
          left: $r('app.float.wh_value_16'),
          right: $r('app.float.wh_value_16'),
        })
        .padding({
          top: $r('app.float.wh_value_17'),
          bottom: $r('app.float.wh_value_16'),
        })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .accessibilityGroup(true)
      .width('100%')
      .padding({
        left: $r('app.float.wh_value_8'),
        right: $r('app.float.wh_value_8'),
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.float.wh_value_16'))
      .backgroundColor(this.itemBackgroundColor)
      .onHover((isHover?: boolean) => {
        this.itemBackgroundColor = isHover ? $r('sys.color.interactive_hover') : Color.Transparent;
      })
    }
    .padding({
      left: $r('app.float.wh_value_8'),
      right: $r('app.float.wh_value_8'),
    })
  }
}

/**
 * 个人热点二级页面-更多设置按钮组件
 */
@Component
export struct MoreSettingButtonComponent {
  @State bgColor: ResourceColor = Color.Transparent;
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  onMoreSettingClick?: () => void;

  build() {
    Column() {
      Text($r('app.string.more_settings'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_15'))
        .fontColor(this.controlCenterColor)
        .lineHeight($r('app.float.font_21'))
        .width('100%')
        .textAlign(TextAlign.Center)
        .maxFontScale(2)
        .id('MoreSettingButton')
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
      bottom: $r('app.float.wh_value_9'),
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

@Component
export struct NoConnectedDeviceComponent {
  @State isHotspotOn: boolean = true;
  build() {
    Column() {
      Image($r('app.media.ic_bluetooth_control_panel_empty'))
        .size({
          height: PANEL_EMPTY_HEIGHT,
        })
        .draggable(false)
        .advancedBlendMode(BlendModeUtil.getCenterBlender())
      Text(this.isHotspotOn ? $r('app.string.hotspot_no_connected_devices') : $r('app.string.hotspot_turned_off'))
        .fontColor($r('app.color.window_settings_font_tertiary'))
        .fontSize($r('app.float.font_14'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .constraintSize({ minHeight: $r('app.float.wh_value_19') })
        .maxFontScale(MAX_FONT_SCALE)
        .margin({
          top: $r('app.float.wh_value_8'),
          bottom: $r('app.float.wh_value_9'),
        })
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}