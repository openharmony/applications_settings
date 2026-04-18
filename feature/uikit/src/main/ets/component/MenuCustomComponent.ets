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

import { LengthMetrics } from '@ohos.arkui.node';
import deviceInfo from '@ohos.deviceInfo';
import promptAction from '@ohos.promptAction';
import Router from '@ohos.router';
import { CustomUiInfo } from '@ohos/mpchart/src/main/ets/components/data/customUiData';
import { EventType } from '@ohos/mpchart/src/main/ets/components/listener/EventControl';
import LineChart from '@ohos/mpchart/src/main/ets/components/chartcomponents/LineChart';
import LineChartModel from '@ohos/mpchart/src/main/ets/components/charts/LineChartModel';
import { PowerInfo } from '@ohos/settings.common/src/main/ets/batteryManager/BatteryManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { Controller, PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  MenuController,
  SliderMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  BaseEntryMenu,
  BaseSliderMenu,
  EntryMenuStyle,
  ImageMenuStyle,
  SliderMenuStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import {
  BaseStyle,
  TextStyle as CustomTextStyle,
  ImageStyle,
  Style
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { TextClickPosition } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  DefaultSliderMenuStyle,
  HomeEntryMenuStyle,
  NavigationEntryMenuStyle,
  PageTitleTextStyle,
  StepSliderMenuStyle
} from '../menus/Menu';
import { CheckboxEntryComponent } from './BaseComponent';
/* instrument ignore file */
const EDGE_ANTI_ALIASING = deviceInfo.productModel.includes('HYM') ? 0.5 : 0;
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';

@Extend(Image)
function imageStyle(imageStyle?: ImageStyle) {
  .width(imageStyle?.size?.width as Length)
  .height(imageStyle?.size?.height as Length)
  .constraintSize(imageStyle?.constraintSize)
  .padding(imageStyle?.padding ?? 0)
  .margin(imageStyle?.margin ?? 0)
  .layoutWeight(imageStyle?.layoutWeight ?? 0)
  .objectFit(imageStyle?.imageFit ?? ImageFit.Contain)
  .draggable(false)
}

@Component
export struct NavigationCheckboxMenuComponent {
  tag: string = 'NavigationCheckboxMenuComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style | NavigationEntryMenuStyle = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;

  @Styles
  normalStyles() {
    .borderColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .borderColor($r('sys.color.ohos_toggle_bg_transparent'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  @Styles
  focusStyle() {
    .borderColor($r('sys.color.ohos_id_color_focused_outline'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    Column() {
      CheckboxEntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        showSelectedBackColor: false,
        pathInfos: this.pathInfos
      });
    }
    .accessibilityGroup(true)
    .onClick(() => {
      this.onEntryClick();
    })
    .margin((this.style as HomeEntryMenuStyle)?.marginStatus)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
      focused: this.focusStyle,
    })
  }

  clear() {
    this.pathInfos?.clear();
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu?.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu?.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu?.targetPageUrl,
      });
    }
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.style = this.menu?.style;
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}


@Component
export struct DateZoneComponent {
  tag: string = 'DateZoneComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State start: string | ResourceStr = ''; // 首位
  @State middle: string | ResourceStr = ''; // 可点击的文本
  @State end: string | ResourceStr = ''; // 末尾
  @State clickTextPosition: string = ''; // 文本状态标注
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      Row() {
        Text() {
          Span(this.start)
            .fontSize($r('app.float.font_14'))
            .fontColor(this.clickTextPosition === TextClickPosition.START ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_20') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)
          Span(this.middle)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_20') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.MIDDLE) {
                this.onEntryClick();
              }
            }
            )
          Span(this.end)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.END) ?
            $r('sys.color.ohos_id_color_text_hyperlink') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_20') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
        }
        .constraintSize({ minHeight: $r('app.float.length_20') })
      }.padding({ left: $r('app.float.wh_value_12'), top: $r('app.float.padding_8'), })
    }
  }

  pushName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      this.pushName(this.menu.key as string, this.menu?.navRouterParam ?? null);
    }
  }

  private transFormResource(resource: Resource): void {
    let result = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = $r('app.string.location_services');
          this.middle = result.slice(0, i);
          this.end = result.slice(i + 2, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + 2, result.length);
          this.end = $r('app.string.location_services');
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = $r('app.string.location_services');
          this.end = result.slice(i + 2, result.length);
        }
        return
      }
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style;
    let res = $r('app.string.location_time_zone');
    this.transFormResource(res);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiPrecisionComponent {
  tag: string = 'WifiPrecisionComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: BaseStyle = undefined;
  controller?: Controller = undefined;
  @State start: string | ResourceStr = ''; // 首位
  @State middle: string | ResourceStr = ''; // 可点击的文本
  @State end: string | ResourceStr = ''; // 末尾
  @State clickTextPosition: string = ''; // 文本状态标注
  @State uiRefresher: UiRefresher = new UiRefresher();
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    Column() {
      Row() {
        Text() {
          Span(this.start)
            .fontSize($r('app.float.length_14'))
            .fontColor(this.clickTextPosition === TextClickPosition.START ? $r('app.color.color_0A59F7_blue') :
            $r('sys.color.ohos_id_color_text_hint'))
            .lineHeight($r('app.float.length_19'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.START) {
                this.onEntryClick();
              }
            })
          Span(this.middle)
            .fontSize($r('app.float.length_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
            $r('app.color.color_0A59F7_blue') : $r('sys.color.ohos_id_color_text_hint'))
            .lineHeight($r('app.float.length_19'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.MIDDLE) {
                this.onEntryClick();
              }
            })
          Span(this.end)
            .fontSize($r('app.float.length_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.END) ?
            $r('app.color.color_0A59F7_blue') : $r('sys.color.ohos_id_color_text_hint'))
            .lineHeight($r('app.float.length_19'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
            .onClick(() => {
              if (this.clickTextPosition === TextClickPosition.END) {
                this.onEntryClick();
              }
            })
        }
      }
      .size({ width: '100%' })
      .padding({ top: DeviceUtil.isDevicePc() ? '12vp' : '0vp', left: $r('app.float.wh_value_12') })
      .margin(this.style?.margin)
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .size({ width: '100%' })
  }

  pushName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  private onEntryClick(): void {
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu && this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      this.pushName(this.menu.key as string, this.menu?.navRouterParam ?? null);
    }
  }

  private transFormResource(resource: Resource): void {
    let result = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = $r('app.string.wifi_precision_title');
          this.middle = result.slice(0, i);
          this.end = result.slice(i + 2, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + 2, result.length);
          this.end = $r('app.string.wifi_precision_title');
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = $r('app.string.wifi_precision_title');
          this.end = result.slice(i + 2, result.length);
        }
        return
      }
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as BaseStyle;
    let res = $r('app.string.wifi_precision_text');
    this.transFormResource(res);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WifiHilinkComponent {
  public tag: string = 'WifiHiLinkComponent : ';
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: BaseStyle = undefined;
  controller?: Controller = undefined;
  // 首位文本
  @State start: string | ResourceStr = '';
  // 中间可点击的文本
  @State middle: string | ResourceStr = '';
  // 末尾文本
  @State end: string | ResourceStr = '';
  // 文本状态标注
  @State clickTextPosition: string = '';
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    if (this.menu?.isNeedShowIcon as boolean) {
      Row() {
        Text() {
          Span(this.start)
            .fontSize($r('app.float.font_14'))
            .fontColor(this.clickTextPosition === TextClickPosition.START ?
            $r('sys.color.ohos_id_color_text_primary_activated') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)

          Span(this.middle)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
            $r('sys.color.ohos_id_color_text_primary_activated') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)

          Span(this.end)
            .fontSize($r('app.float.font_14'))
            .fontColor((this.clickTextPosition === TextClickPosition.END) ?
            $r('sys.color.ohos_id_color_text_primary_activated') : $r('sys.color.ohos_id_color_text_hint'))
            .constraintSize({ minHeight: $r('app.float.length_19') })
            .fontFamily('HarmonyHeiTi')
            .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
        }
      }
      .size({ width: '100%' })
      .padding({
        top: DeviceUtil.isDevicePc() ? $r('sys.float.padding_level6') : $r('sys.float.padding_level0'),
        left: $r('sys.float.padding_level10'),
        right: $r('sys.float.padding_level10')
      })
      .margin(this.style?.margin)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    }
  }

  private transFormResource(resource: Resource): void {
    let result = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = 'H';
          this.middle = result.slice(0, i);
          this.end = result.slice(i + 2, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + 2, result.length);
          this.end = 'H';
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = 'H';
          this.end = result.slice(i + 2, result.length);
        }
        return;
      }
    }
  }

  aboutToAppear(): void {
    this.style = this.menu?.style as BaseStyle;
    this.transFormResource($r('app.string.wifi_hlink_description'));
    this.controller = this.menu?.getControllerInstance(this.uiRefresher);
  }

  aboutToDisappear(): void {
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct RingToneImageComponent {
  tag: string = 'ImageMenuComponent : ';
  menu?: SettingsBaseMenu;
  style: ImageMenuStyle | null = null;
  @State controller?: MenuController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();

  @Builder
  OverlayNode() {
    Column() {
      Row() {
        Text(this.menu?.title as string)
          .fontSize(20)
          .fontColor(Color.White)
          .fontFamily('HarmonyHeiTi')
          .textAlign(TextAlign.Start)
      }.margin({ bottom: 2 })

      Text(this.menu?.state as string)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.6)')
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Start)
    }.alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      Stack() {
        Column() {
          Image(this.getMenu().icon)
            .visibility(this.getMenu().icon ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.iconImage)
            .objectFit(ImageFit.Cover)
            .overlay(this.OverlayNode(), { align: Alignment.TopStart, offset: { x: 12, y: 12 } })
            .fillColor($r('sys.color.ohos_id_color_secondary'))
            .borderRadius($r('app.float.length_16'))
            .onClick(() => {
              try {
                promptAction.showToast({ message: this.getMenu().summary as string });
              } catch (e) {
                LogUtil.error(`showToast args error`);
              }
            })
            .syncLoad(true)
        }
      }
      .alignContent(Alignment.Center)
      .size(this.getStyle()?.rootContainer?.size)
      .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
      .padding(this.getStyle()?.rootContainer?.padding ?? 0)
      .margin(this.getStyle()?.rootContainer?.margin ?? 0)
      .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius(this.getStyle()?.rootContainer?.borderRadius as Length)
      .backgroundColor(this.getStyle()?.rootContainer?.backgroundColor)
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStyle(): ImageMenuStyle {
    return this.getMenu().style as ImageMenuStyle;
  }

  aboutToAppear(): void {
    if (this.menu) {
      if (this.menu.style instanceof ImageMenuStyle) {
        this.style = this.menu.style;
      }
    }
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Extend(Text)
function textStyle(textStyle?: CustomTextStyle) {
  .width(textStyle?.size?.width as Length)
  .height(textStyle?.size?.height as Length)
  .constraintSize(textStyle?.constraintSize)
  .padding(textStyle?.padding ?? 0)
  .margin(textStyle?.margin ?? 0)
  .layoutWeight(textStyle?.layoutWeight ?? 0)
  .fontColor(textStyle?.fontColor)
  .fontSize(textStyle?.font?.size as Length)
  .fontWeight(textStyle?.font?.weight)
  .fontFamily(textStyle?.font?.family as string | Resource)
  .fontStyle(textStyle?.font?.style)
  .textAlign(textStyle?.textAlign ?? TextAlign.Start)
  .textOverflow({ overflow: textStyle?.overflow ?? TextOverflow.Ellipsis })
  .maxLines(textStyle?.maxLines)
  .align(textStyle?.align)
  .backgroundColor(textStyle?.backgroundColor)
  .borderRadius(textStyle?.borderRadius as Length)
  .minFontSize((textStyle as PageTitleTextStyle)?.font?.minFontSize ?? textStyle?.font?.size as Length)
  .maxFontSize((textStyle as PageTitleTextStyle)?.font?.maxFontSize as ResourceStr ?? textStyle?.font?.size as Length)
  .opacity(textStyle?.opacity ?? 1)
  .lineHeight(textStyle?.lineHeight)
  .wordBreak(textStyle?.wordBreak)
}

@Component
export struct NavCarMenuComponent {
  tag: string = 'NavCarMenuComponent : ';
  menu?: BaseEntryMenu;
  style: EntryMenuStyle | null = null;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State controller?: MenuController = undefined; // 根据不同业务生成不同控制器，不设置具体值
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State pathInfos: NavPathStack | null = null;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius('8vp')
  }

  build() {
    Column() {
      Stack() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
            .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.title as PageTitleTextStyle)
            .id(`entry_title_${this.menu?.key}`)
            .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
            .maxLines(this.style?.textStyle?.maxLines ?? 99)
            .textOverflow({
              overflow: this.style?.textStyle?.overflow ?? TextOverflow.None
            })
            .size(this.style?.textStyle?.size);
          if (this.menu?.stateIcon) {
            Image(this.menu?.stateIcon)
              .hoverEffect(this.controller?.onStateIconClick ? HoverEffect.Highlight : null)
              .onClick(this.controller?.onStateIconClick as (event?: ClickEvent) => void)
              .id(`entry_image_${this.menu?.key}`)
              .stateStyles({
                normal: this.normalStateIconStyles,
                pressed: this.pressedStateIconStyles,
              })
              .visibility((this.menu?.stateIcon) ? Visibility.Visible : Visibility.None)
              .imageStyle(this.style?.stateIcon)
              .fillColor(this.style?.stateIcon?.fillColor)
              .edgeAntialiasing(EDGE_ANTI_ALIASING);
          }
        }
        .width('100%')
        .padding({ left: '8vp', right: '8vp' })
        .borderRadius('16vp')
        .constraintSize({ minHeight: '48vp' })
        .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
        .onTouch((event?: TouchEvent): void => {
          if (event) {
            this.onTouchEvent(event);
          }
        })
        .onHover((isHover) => {
          isHover = isHover ? true : false;
          this.isHover = this.updateHover(isHover);
          this.controller?.handleHoverEvent(isHover);
        })
        .onMouse((event?: MouseEvent): void => {
          if (event) {
            this.onMouseEvent(event);
          }
        })
        .onClick(() => {
          this.controller?.onMenuClick();
        })

      }
      .alignContent(Alignment.Center)
      .size(this.getStyle()?.rootContainer?.size)
      .constraintSize({ minHeight: '56vp' })
      .padding({ left: '4vp', right: '4vp' })
      .margin({ top: '8vp' })
      .layoutWeight(this.getStyle()?.rootContainer?.layoutWeight ?? 0)
      .clip(this.getStyle()?.rootContainer?.clip)
      .borderRadius('16vp')
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey')
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return $r('app.color.color_default_white');
  }

  private updateHover(isHover: boolean): boolean {
    return isHover;
  }

  private getMenu(): BaseEntryMenu {
    return this.controller ? this.controller.menu as BaseEntryMenu : this.menu as BaseEntryMenu;
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private getStyle(): EntryMenuStyle {
    return this.getMenu().style as EntryMenuStyle;
  }

  private onMouseEvent(event: MouseEvent): void {
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  aboutToAppear(): void {
    if (this.menu) {
      if (this.menu.style instanceof EntryMenuStyle) {
        this.style = this.menu.style;
      }
    }
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as MenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}

@Component
export struct WLANQRCodeComponent {
  @State menu?: SettingsBaseMenu | undefined = undefined;
  @State controller?: SliderMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  tag: string = 'WIFIQRCodeController : ';

  build() {
    Column() {
      Column() {
        QRCode(this.menu?.searchKeyWords)
          .width(208)
          .height(208)
          .margin({ top: '16vp', left: '12vp', right: '12vp'})
      }
      .width('240vp')
      .height('240vp')
      .padding({ left: '44vp', right: '44vp' })
      .margin({ top: '16vp' })
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .alignItems(HorizontalAlign.Center)
      .borderRadius('12vp')
      Column() {
        Text(this.menu?.summary)
          .fontSize('14fp')
          .constraintSize({ minHeight: $r('app.float.length_19') })
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_text_hint'))
          .margin({top:'12vp'})
          .textAlign(TextAlign.Center)
      }
      .margin({bottom:'10vp'})
    }
  }

  aboutToAppear(): void {
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SliderMenuController;
  }

  aboutToDisappear(): void {

  }
}

@Component
export struct BatteryMpChartComponent {
  @State menu?: BaseEntryMenu = undefined;
  @State controller?: SliderMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State uiTriggerEvent: EventType = EventType.SingleTap;
  @State customUiInfo: CustomUiInfo = new CustomUiInfo(90, 50);
  @State lineChartModel?: LineChartModel = undefined;

  state: TextController = new TextController();
  secondState: TextController = new TextController();

  tag: string = 'BatteryMpChartComponent : ';

  private lineChartModelChangeEventCallback = (lineChartModel: LineChartModel) => {
    LogUtil.info(`${this.tag} lineChartModelChangeEventCallback`);
    this.lineChartModel = lineChartModel;
  };

  private stateChangeEventCallback = (state: string) => {
    LogUtil.info(`${this.tag} stateChangeEventCallback. state:${state}`);
    try {
      let newState: string = ResourceUtil.getPluralStringValueSync(this.menu?.secondSummary as Resource,
        Number.parseInt(state));
      this.getStyledString(newState, state, this.state);
    } catch (error) {
      LogUtil.error(`${this.tag} stateChangeEventCallback. code:${error?.code} message:${error?.message}`);
    }
  };
  private secondStateChangeEventCallback = (secondState: string) => {
    LogUtil.info(`${this.tag} secondStateChangeEventCallback. secondState:${secondState}`);
    try {
      let newState: string = ResourceUtil.getPluralStringValueSync(this.menu?.stateIcon as Resource,
        Number.parseInt(secondState));
      this.getStyledString(newState, secondState, this.secondState);
    } catch (error) {
      LogUtil.error(`${this.tag} secondStateChangeEventCallback. code:${error?.code} message:${error?.message}`);
    }
  };

  private getStyledString(state: string, numberStr: string, textController: TextController): void {
    const length = numberStr.length;
    const index = state.indexOf(numberStr);
    // 某些语种翻译后会倒序 (藏文是数字在后面)
    const isReverse = index > 0;
    let mutableStyledString: MutableStyledString = new MutableStyledString(state, [
      {
        start: isReverse ? index : 0,
        length: length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle({ fontWeight: FontWeight.Bold, fontSize: LengthMetrics.fp(30) })
      },
      {
        start: isReverse ? 0 : length + 1,
        length: state.length - length,
        styledKey: StyledStringKey.FONT,
        styledValue: new TextStyle({ fontSize: LengthMetrics.fp(12) })
      }
    ]);
    textController.setStyledString(mutableStyledString)
  }

  build() {
    Column() {
      Column() {
        this.headView()
        LineChart({
          model: this.lineChartModel,
          // 自定义 ui: 传入 builder
          customUiBuilder: this.customUi,
          // 通过什么事件触发
          customUiTriggerEvent: this.uiTriggerEvent,
          // 自定义ui的位置信息
          customUiInfo: this.customUiInfo,
        })
          .width('100%')
          .height('158vp')
          .margin({
            top: $r('sys.float.padding_level6'),
            bottom: $r('sys.float.padding_level10') })
      }
      .width('100%')
      .margin({ top: $r('sys.float.padding_level6') })
      .backgroundColor(Color.Transparent)
      .alignItems(HorizontalAlign.Start)
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SliderMenuController;
    EventBus.getInstance()
      .on(CommonEventConstant.EVENT_BATTERY_CONSUME_LINE_CHART_MODEL_CHANGE, this.lineChartModelChangeEventCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_BATTERY_CONSUME_STATE_CHANGE, this.stateChangeEventCallback);
    EventBus.getInstance()
      .on(CommonEventConstant.EVENT_BATTERY_CONSUME_SECOND_STATE_CHANGE, this.secondStateChangeEventCallback);
    this.controller?.aboutToAppear();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_BATTERY_CONSUME_LINE_CHART_MODEL_CHANGE,
      this.lineChartModelChangeEventCallback);
    EventBus.getInstance()
      .detach(CommonEventConstant.EVENT_BATTERY_CONSUME_STATE_CHANGE, this.stateChangeEventCallback);
    EventBus.getInstance()
      .detach(CommonEventConstant.EVENT_BATTERY_CONSUME_SECOND_STATE_CHANGE, this.secondStateChangeEventCallback);
    this.controller?.aboutToDisappear();
  }

  @Builder
  headView() {
    Text(this.menu?.title)
      .fontSize($r('sys.float.Subtitle_S'))
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Start)
      .margin({ left: $r('sys.float.padding_level6') })
    Row() {
      Row() {
        Text(undefined, { controller: this.state }).margin({ right: $r('app.float.margin_4') })
        Text(undefined, { controller: this.secondState })
      }
      .width('50%')
      Row() {
        Text() {}
        .width('14vp')
        .height('14vp')
        .backgroundColor('#64BB5C')
        .margin({right: $r('sys.float.padding_level2')})
        Text($r('app.string.charge_time_segment'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .margin({right: $r('sys.float.padding_level16')})
      }
      .justifyContent(FlexAlign.End)
      .width('50%')
    }
    .margin({
      left: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level6')
    })
  }

  @Builder
  customUi() {
    Column() {
    }
    .bindPopup((this.customUiInfo?.data?.getData() as PowerInfo)?.desc ? true : false,
      {
        message: (this.customUiInfo?.data?.getData() as PowerInfo)?.desc,
        placementOnTop: true,
        mask: false,
      })
    .alignItems(HorizontalAlign.Center)
    .margin({
      left: this.customUiInfo.x,
      // y轴坐标总高度120左右 0刻度到图表的上边距为135
      top: 135 - 1.2 * (this.customUiInfo.data?.getY() || 0),
    })
  }
}

@Component
export struct SliderPCMenuComponent {
  tag: string = 'SliderPCMenuComponent : ';
  @State menu?: SettingsBaseMenu | undefined = undefined;
  @State controller?: SliderMenuController = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Row() {
          Text(this.getMenu().title)
            .visibility(this.getMenu().title ? Visibility.Visible : Visibility.None)
            .textStyle(this.getStyle()?.title)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .opacity(this.getStyle()?.rootContainer?.opacity)
        }.width('55%')

        Row() {
          Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
            Image(this.getStartIcon())
              .fillColor($r('sys.color.ohos_id_color_text_primary'))
              .visibility(this.getStartIcon() ? Visibility.Visible : Visibility.None)
              .imageStyle(this.getStyle()?.startImage)
              .onClick(() => {
                this.controller?.onStartIconClick();
              });

            Slider({
              value: this.uiRefresher.refreshId ? this.controller?.getSliderValue() : this.controller?.getSliderValue(),
              min: this.controller?.getSliderMin(),
              max: this.controller?.getSliderMax(),
              step: this.controller?.getSliderStep(),
              style: this.getStyle()?.sliderStyle ?? SliderStyle.InSet
            })
              .onChange((value: number, mode: SliderChangeMode) => {
                this.controller?.onSliderChange(value, mode);
              })
              .selectedColor(this.getStyle()?.toggleStyle?.selectedColor ?? $r('sys.color.ohos_id_color_emphasize'))
              .blockColor('#ffffff')
              .showSteps((this.getStyle() as StepSliderMenuStyle)?.showSteps)
              .padding(this.getStyle()?.sliderPadding as Padding)

            Image(this.getEndIcon())
              .fillColor($r('sys.color.ohos_id_color_text_primary'))
              .visibility(this.getEndIcon() ? Visibility.Visible : Visibility.None)
              .imageStyle(this.getStyle()?.endImage)
              .onClick(() => {
                this.controller?.onEndIconClick();
              });
          }
        }
        .padding({ left: 0, right: '12vp', top: 0, bottom: 0 })
        .width('45%')
      }.width('100%')
    }
    .width('100%')
    .alignItems((this.getStyle() as DefaultSliderMenuStyle)?.verticalAlign)
    .justifyContent(FlexAlign.Center)
    .size(this.getStyle()?.rootContainer?.size)
    .padding(this.getStyle()?.rootContainer?.padding as Padding)
    .constraintSize(this.getStyle()?.rootContainer?.constraintSize)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getMenu(): SettingsBaseMenu {
    return this.controller ? this.controller.menu as SettingsBaseMenu : this.menu as SettingsBaseMenu;
  }

  private getStartIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.starIcon as ResourceStr : '';
  }

  private getEndIcon(): Resource | string {
    return (this.menu instanceof BaseSliderMenu) ? this.menu?.endIcon as ResourceStr : '';
  }

  private getStyle(): SliderMenuStyle {
    return this.getMenu().style as SliderMenuStyle;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear, ${this.menu?.getLogKey()}`);
    this.controller = this.menu?.getControllerInstance(this.uiRefresher) as SliderMenuController;
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear, ${this.menu?.getLogKey()}`);
    this.controller?.aboutToDisappear();
  }
}