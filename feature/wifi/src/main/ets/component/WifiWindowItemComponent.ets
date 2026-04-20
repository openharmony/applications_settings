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
import measure from '@ohos.measure';
import BlendModeUtil from '@ohos/settings.commonUikit/src/main/ets/utils/BlendModeUtil';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';

const TAG: string = 'PcWifiWindowItemComponent: ';
const MAX_WIFI_TITLE_WIDTH: number = 270;
const POPUP_COLOR = '#33000000';

/**
 * PC控制中心wlan列表item组件
 */
@Component
export struct WifiWindowItemComponent {
  @State menu?: SettingsBaseMenu = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State bgColor: ResourceColor = Color.Transparent;
  @State isHovered: boolean = false;
  @State menuHoverIndex: number = -1;

  build() {
    Row() {
      this.stateIconBuilder()

      this.textBuilder()

      if (this.menu?.isShowConnected) {
        Column() {
          Image($r('app.media.ic_public_ok_filled'))
            .fillColor($r('app.color.color_text_primary_activated'))
            .size({
              width: $r('app.float.wh_value_24'),
              height: $r('app.float.wh_value_24'),
            })
        }
      }
    }
    .width('100%')
    .constraintSize({
      minHeight: $r('app.float.height_56'),
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('app.float.padding_20'),
      right: $r('app.float.padding_20'),
    })
    .margin({
      bottom: $r('app.float.margin_2'),
    })
    .borderRadius($r('sys.float.corner_radius_level6'))
    .backgroundColor(this.bgColor)
    .onHover((isHover?: boolean) => {
      this.onHoverEvent(isHover);
    })
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .onBlur(() => {
      this.bgColor = Color.Transparent;
    })
    .onTouch((event?: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .onMouse((event?: MouseEvent): void => {
      this.onMouseEvent(event)
    })
    .onClick(() => {
      this.onClickEvent();
    })
    .bindPopup((this.isHovered && this.menuHoverIndex === this.menu?.index &&
      this.calcShowTipsWidth() >= MAX_WIFI_TITLE_WIDTH), {
      builder: this.showTipsBuilder(),
      popupColor: POPUP_COLOR,
      mask: false,
      placement: Placement.Top,
      targetSpace: $r('sys.float.padding_level2'),
      enableArrow: false,
      autoCancel: true,
      radius: $r('sys.float.corner_radius_level4'),
      shadow: ShadowStyle.OUTER_DEFAULT_SM,
      backgroundBlurStyle: BlurStyle.COMPONENT_REGULAR,
    })
  }

  @Builder
  showTipsBuilder() {
    Row() {
      Text(this.menu?.title)
        .id('wifi_tip')
        .wordBreak(WordBreak.BREAK_ALL)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({overflow: TextOverflow.Ellipsis})
        .fontWeight(FontWeight.Regular)
    }
    .padding({
      left:  $r('sys.float.padding_level4'),
      right:  $r('sys.float.padding_level4'),
      top:  $r('sys.float.padding_level4'),
      bottom:  $r('sys.float.padding_level4'),
    })
  }

  @Builder
  stateIconBuilder() {
    Column() {
      Image(this.uiRefresher.refreshId ? this.menu?.stateIcon : this.menu?.stateIcon)
        .fillColor($r('app.color.statusbar_blend_color'))
        .advancedBlendMode(BlendModeUtil.getBlender())
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
        .fontColor(this.menu?.isShowConnected ? $r('app.color.color_text_primary_activated') : $r('app.color.statusbar_blend_color'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .fontWeight(this.menu?.isShowConnected ? FontWeight.Bold : FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
        .advancedBlendMode(this.menu?.isShowConnected ? undefined : BlendModeUtil.getBlender())

      Text(this.uiRefresher.refreshId ? this.menu?.summary : this.menu?.summary)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('app.color.statusbar_blend_color'))
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .advancedBlendMode(BlendModeUtil.getBlenderTertiary())
        .margin({
          top: $r('app.float.length_2'),
        })
    }
    .width('calc(100% - 66vp)')
    .layoutWeight(1)
    .margin({
      left: $r('app.float.wh_value_12'),
      right: $r('app.float.margin_8'),
    })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
  }

  private calcShowTipsWidth(): number {
    let textWidth: number = Math.round(px2vp(measure.measureTextSize({
      textContent: ResourceUtil.getStringSync(this.menu?.title),
      fontSize: $r('sys.float.Body_L'),
      fontWeight: FontWeight.Regular,
      overflow: TextOverflow.Ellipsis
    }).width as number));
    LogUtil.debug(`${TAG} calcShowTipsWidth textWidth ${textWidth}`);
    return textWidth;
  }

  private onClickEvent(): void {
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    LogUtil.warn(`${TAG} do not get controller, onClick error`);
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.ohos_id_color_hover');
      this.isHovered = isHover;
      this.menuHoverIndex = this.menu?.index as number;
    } else {
      this.bgColor = Color.Transparent;
      this.menuHoverIndex = -1;
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
      this.isHovered = false;
    } else if (event && event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} aboutToAppear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} aboutToDisappear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
    this.controller?.aboutToDisappear();
  }
}