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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import { VolumeModeWindowController } from '../controller/VolumeModeWindowController';
/* instrument ignore file */
const TAG: string = 'SoundModeWindowComponent: ';
const MAX_FONT_SCALE: number = 1.5;

/**
 * 控制中心--声音二级页面-标题组件
 */
@Builder
export function soundModeWindowTitleBuilder(symbol: Resource, title: ResourceStr, domId: string) {
  Column() {
    Column() {
      SymbolGlyph(symbol)
        .fontColor([$r('sys.color.ohos_id_color_primary')])
        .draggable(false)
        .fontSize($r('app.float.wh_value_24'))
        .fontWeight(FontWeight.Medium)
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
      .maxFontScale(MAX_FONT_SCALE)
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
 * 控制中心--声音二级页面-item组件构建
 */
@Component
export struct SoundModeItemsComponent {
  @Prop controlCenterColor: ResourceColor = $r('app.color.control_center_sub_panel_color');
  @Prop icon: Resource;
  @Prop title: ResourceStr;
  @Prop ringMode: number;
  @State controller?: VolumeModeWindowController = undefined;

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  build() {
    ListItem() {
      Row() {
        Column() {
          SymbolGlyph(this.icon)
            .fontColor([$r('sys.color.ohos_id_color_primary')])
            .fontSize($r('app.float.wh_value_24'))
            .draggable(false)
            .advancedBlendMode(BlendModeUtil.getCenterBlender())
        }

        Column() {
          Text(this.title)
            .fontColor(this.controller?.audioRingMode === this.ringMode ? this.controlCenterColor :
            $r('app.color.window_settings_font_secondary'))
            .fontSize($r('app.float.font_16'))
            .fontWeight(FontWeight.Medium)
            .fontFamily('HarmonyHeiTi')
            .lineHeight($r('app.float.font_21'))
            .maxFontScale(MAX_FONT_SCALE)
        }
        .layoutWeight(1)
        .margin({
          left: $r('app.float.wh_value_16'),
          right: $r('app.float.wh_value_16'),
        })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)

        if (this.controller?.audioRingMode === this.ringMode) {
          Column() {
            Image($r('app.media.ic_connect_ok'))
              .fillColor(this.controlCenterColor)
              .size({
                width: $r('app.float.wh_value_18'),
                height: $r('app.float.wh_value_18'),
              })
              .draggable(false)
          }
        }
      }
      .accessibilitySelected(this.controller?.audioRingMode === this.ringMode)
      .accessibilityDescription(`${ResourceUtil.getStringSync(this.controller?.audioRingMode === this.ringMode ?
        ' ' : '')}`)
      .width('100%')
      .height($r('app.float.wh_value_56'))
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('app.float.wh_value_16'))
      .padding({
        left: $r('app.float.wh_value_8'),
        right: $r('app.float.wh_value_8'),
      })
      .stateStyles({
        normal: {
          .backgroundColor($r('app.color.color_default_white'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
        pressed: {
          .backgroundColor($r('sys.color.interactive_click'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
      })
      .onClick(() => {
        this.handleClickEvent?.(this.ringMode);
      })
    }.padding({
      left: $r('app.float.wh_value_8'),
      right: $r('app.float.wh_value_8'),
    })
  }

  private handleClickEvent(selectMode: number): void {
    LogUtil.info(`${TAG}handleClickEvent: ringMode:  ${selectMode}`);
    this.controller?.setAudioRingMode(selectMode);
  }
}

/**
 * 控制中心二级页面-更多设置按钮组件
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
        .fontSize($r('app.float.font_16'))
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