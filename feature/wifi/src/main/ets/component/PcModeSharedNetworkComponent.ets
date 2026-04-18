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
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK
} from '@ohos/settings.common/src/main/ets/event/types';
import { SharedNetworkMenu } from '../model/SharedNetworkPanelModel';

const TAG: string = 'PcModeSharedNetworkComponent: ';
const MAX_WIFI_TITLE_WIDTH: number = 270;
const POPUP_COLOR = '#33000000';

/**
 * 共享网络列表Item组件
 */
@Component
export struct PcModeSharedNetworkComponent {
  @State menu?: SharedNetworkMenu = undefined;
  @State bgColor: ResourceColor = Color.Transparent;
  @State isHovered: boolean = false;
  @State menuHoverIndex: number = -1;

  build() {
    Row() {
      this.stateIconBuilder();

      this.textBuilder();

      if (this.menu?.isShowConnected) {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize($r('app.float.width_24'))
          .fontWeight(FontWeight.Regular)
          .fontColor([$r('app.color.color_text_primary_activated')])
      }
    }
    .width('100%')
    .constraintSize({
      minHeight: $r('app.float.height_56'),
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('sys.float.padding_level10'),
      right: $r('sys.float.padding_level10'),
    })
    .margin({
      bottom: $r('sys.float.padding_level1'),
    })
    .borderRadius('12vp')
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
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontWeight(FontWeight.Regular)
    }
    .padding({
      left: $r('sys.float.padding_level4'),
      right: $r('sys.float.padding_level4'),
      top: $r('sys.float.padding_level4'),
      bottom: $r('sys.float.padding_level4'),
    })
  }

  @Builder
  stateIconBuilder() {
    Column() {
      Image(this.menu?.stateIcon)
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
      Text(this.menu?.title)
        .fontColor(this.menu?.isShowConnected ? $r('app.color.color_text_primary_activated') :
        $r('app.color.statusbar_blend_color'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(this.menu?.isShowConnected ? FontWeight.Bold : FontWeight.Medium)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Center)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
        .advancedBlendMode(this.menu?.isShowConnected ? undefined : BlendModeUtil.getBlender())

      Text(this.menu?.summary)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Body_M'))
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
    LogUtil.info(`${TAG} control enter shardNetwork item clicked: ${this.menu?.getLogKey()}`);
    if (this.menu) {
      EventBus.getInstance().emit(EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK, this.menu);
    }
  }

  private onHoverEvent(isHover?: boolean): void {
    if (isHover) {
      this.bgColor = $r('sys.color.interactive_hover');
      this.isHovered = isHover;
      this.menuHoverIndex = this.menu?.index as number;
    } else {
      this.bgColor = Color.Transparent;
      this.menuHoverIndex = -1;
    }
  }

  private onTouchEvent(event?: TouchEvent): void {
    if (!event) {
      LogUtil.showError(TAG, 'onTouchEvent, event is not available.');
      return;
    }
    if (event.type === TouchType.Down) {
      this.bgColor = $r('sys.color.interactive_click');
    }
    if (event.type === TouchType.Up) {
      this.bgColor = Color.Transparent;
    }
  }

  private onMouseEvent(event?: MouseEvent): void {
    if (!event) {
      LogUtil.showError(TAG, 'onMouseEvent, event is not available.');
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.bgColor = $r('sys.color.interactive_click');
      this.isHovered = false;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.bgColor = Color.Transparent;
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${TAG} aboutToAppear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${TAG} aboutToDisappear, ${this.menu?.getLogKey()}, ${this.menu?.menuType}`);
  }
}