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

import common from '@ohos.app.ability.common';
import StartOptions from '@ohos.app.ability.StartOptions';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import { LengthMetrics } from '@ohos.arkui.node';
import display from '@ohos.display';
import emitter from '@ohos.events.emitter';
import Router from '@ohos.router';
import uiAppearance from '@ohos.uiAppearance';
import {
  FOCUS_BOX_PADDING_METRICS_5,
  PADDING_0,
  PADDING_12,
  PADDING_4,
  PADDING_8,
  StyleConstant
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  JumpController,
  LoadingMenuController,
  MenuController,
  NavCheckboxMenuController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import {
  BaseEntryMenu,
  BaseSelectEntryMenu,
  EntryMenuStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import {
  BaseStyle,
  ContainerStyle,
  DividerStyle,
  ImageStyle,
  PageHeaderStyle,
  Style,
  SubHeaderStyle,
  SymbolGlyphStyle,
  TextStyle,
  IconTextStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE } from '@ohos/settings.common/src/main/ets/event/types';
import { ExternalMenuController } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuController';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { BACK_ENTRY, NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import ConfigurationSelectController from '../configurationparse/controller/ConfigurationSelectController';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import {
  DefaultEntryMenuStyle,
  DefaultLoadingMenuStyle,
  DefaultNavPageHeaderStyle,
  DefaultSelectEntryMenuStyle,
  DialogListMessageMenu,
  EntryMenu,
  HomeEntryMenuStyle,
  NavigationCheckboxEntry,
  NavigationEntryMenuStyle,
  NavigatorEntryMenu,
  PageTitleTextStyle,
  RootContainerStyle72,
  StateMenu,
  SummaryTextStyle,
  SwitchToggleStyle
} from '../menus/Menu';
import { AuthConstant } from '@ohos/settings.common/src/main/ets/constant/AuthConstant';

/* instrument ignore file */
const TAG: string = 'BaseComponent : ';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const DEFAULT_WINDOW_MODE: number = 102; // pc默认窗口模式
const LAYOUT_WEIGHT_MAX: number = 1; // 设置有标题时标题比重为1，否则为0
const LAYOUT_WEIGHT_MIN: number = 0;
const INDEX_NOT_FOUNT: number = -1;
const TITLE_MAX_LINE_DEFAULT: number = 2;
const RESULT_CODE_INVALID: number = -1;
const EDGE_ANTI_ALIASING = DeviceUtil.isDevicePc() ? 0.5 : 0;

class AppIconStyle extends ImageStyle {
  public size: SizeOptions = {
    width: '40vp',
    height: '40vp',
  };
  public margin: Margin = {
    right: '16vp',
  };
  public imageFit = ImageFit.Contain;
  public visible = true;
}

class AppSummaryTextStyle extends SummaryTextStyle {
  public visible = true;
}

export class AppStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootContainerStyle72();
  public iconImage: ImageStyle = new AppIconStyle();
  public summary = new AppSummaryTextStyle();
}

@Builder
export function backButton(isShow: boolean, onBackClick: () => void): void {
  Button({ type: ButtonType.Circle }) {
    SymbolGlyph($r('sys.symbol.chevron_backward'))
      .width($r('app.float.height_24'))
      .height($r('app.float.height_24'))
      .draggable(false)
      .fontSize($r('app.float.height_24'))
      .fontColor([$r('sys.color.ohos_id_color_primary')])
  }
  .id('backButton')
  .visibility(isShow ? Visibility.Visible : Visibility.None)
  .hoverEffect(HoverEffect.Highlight)
  .draggable(false)
  .width('40vp')
  .height('40vp')
  .margin({ start: PADDING_4, end: PADDING_8 })
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .flexShrink(0)
  .onClick(() => {
    onBackClick?.();
  })
  .accessibilityText($r('app.string.back_to_parent_menu'))
}

@Component
export struct EntryComponent {
  tag: string = 'EntryComponent : ';
  @Link menu: BaseEntryMenu;
  @Link style: EntryMenuStyle;
  @Link controller: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
  @State pathInfos: NavPathStack | null = null;

  private getNormalColor(): ResourceColor{
    if (this.isHover) {
      return $r('sys.color.interactive_hover');
    }
    return Color.Transparent;
  }

  private getNormalBorderRadius(): Length | number {
    if (this.isHover) {
      return this.getBorderRadius();
    }
    return 0;
  }

  private getBorderRadius(): Length {
    return this.style?.rootContainer?.borderRadius ?? $r('app.float.list_item_background_radius');
  }

  private getPressedColor(): ResourceColor {
    LogUtil.info(`${this.tag} getPressedColor ${this.controller?.onStateIconClick}`);
    if (this.menu.pressedColor) {
      return this.menu.pressedColor;
    }
    if ((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) && this.menu.menuType !== MenuType.STATE) {
      return $r('sys.color.ohos_id_color_click_effect');
    }
    if (this.controller?.onStateIconClick || (DeviceUtil.isDevicePc() && this.isSelected)) {
      return $r('sys.color.ohos_id_color_click_effect');
    }
    return Color.Transparent;
  }

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.getNormalColor())
    .borderRadius(this.getNormalBorderRadius())
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius(this.getBorderRadius())
  }

  @Styles
  pressedStyles() {
    .backgroundColor(this.getPressedColor())
    .borderRadius(this.getBorderRadius())
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(this.controller?.onSecondStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius(this.getBorderRadius())
  }

  @Builder
  titleBuilder() {
    Column() {
      Row() {
        if (this.menu?.title) {
          if (this.menu?.extra === 'passError') {
            Row() {
              Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
                Row() {
                  Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
                    .onClick(this.controller?.onTitleClick)
                    .textStyle(this.style?.title as PageTitleTextStyle)
                    .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                    .id(`entry_title_${this.menu?.key}`)
                    .maxLines(this.style?.textStyle?.maxLines ?? 99)
                    .textAlign(TextAlign.Center)
                    .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
                }
                .constraintSize({ minHeight: '48vp'})
                .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
                .borderRadius(10)
                .width('100%')
              }
            }
            .constraintSize(this.style?.textStyle?.constraintSize)
            .size(this.style?.textStyle?.size)
            .padding({ left: $r('app.float.length_24'), right: $r('app.float.length_24') })
          } else {
            Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
              .onClick(this.controller?.onTitleClick)
              .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
              .textStyle(this.style?.title as PageTitleTextStyle)
              .id(`entry_title_${this.menu?.key}`)
              .fontSize(this.style?.title?.font?.size ?? $r('sys.float.ohos_id_text_size_sub_title2'))
              .maxLines(this.style?.textStyle?.maxLines ?? 99)
              .textOverflow({
                overflow: this.style?.textStyle?.overflow ?? TextOverflow.None
              })
              .wordBreak(WordBreak.BREAK_WORD)
              .size(this.style?.textStyle?.size)
          }
          if (this.menu?.textImg) {
            Image(this.menu.textImg)
              .width($r('app.float.length_20'))
              .height($r('app.float.length_20'))
          }
        }
        if (this.menu?.showNewInfo) {
          Image($r('app.media.new_info_point'))
            .visibility((this.menu?.showNewInfo) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.newInfoImage)
        }
      }

      if (this.menu?.summary) {
        Text(this.uiRefresher?.refreshId ? this.menu?.summary : this.menu?.summary)
          .onClick(this.controller?.onSummaryClick)
          .visibility((this.menu?.summary) || this.style?.summary?.visible ? Visibility.Visible : Visibility.None)
          .textStyle(this.style?.summary as PageTitleTextStyle)
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
      }

      if (this.menu?.secondSummary) {
        Text(this.menu?.secondSummary)
          .onClick(this.controller?.onSecondSummaryClick)
          .visibility((this.menu?.secondSummary) ? Visibility.Visible : Visibility.None)
          .textStyle(this.style?.secondSummary as PageTitleTextStyle)
      }
    }
    .alignItems(this.style?.rootContainer?.horizontalAlign ?? HorizontalAlign.Start)
  }

  // 针对蓝牙与左边导航封装,因为共用一个组件所以此时要做区分
  @Builder
  iconNeedColor() {
    Image(this.menu?.icon)
      .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
      .imageStyle(this.style?.iconImage)
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start)
      .id(`entry_image_${this.menu?.key}`)
      .fillColor(this.style?.iconImage?.fillColor)
      .autoResize(false)
      .interpolation(ImageInterpolation.Medium)
      .focusable(this.menu.menuType === MenuType.NAVIGATION_MENU_ENTRY ||
        this.menu.menuType === MenuType.NAVIGATOR_ENTRY)
      .edgeAntialiasing(EDGE_ANTI_ALIASING)
  };

  @Builder
  iconNoNeedColor() {
    Image(this.menu?.icon)
      .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
      .imageStyle(this.style?.iconImage)
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start)
      .id(`entry_image_${this.menu?.key}`)
      .autoResize(false)
      .interpolation(ImageInterpolation.Medium)
      .focusable(this.menu.menuType === MenuType.NAVIGATION_MENU_ENTRY ||
        this.menu.menuType === MenuType.NAVIGATOR_ENTRY)
      .edgeAntialiasing(EDGE_ANTI_ALIASING)
  };

  @Builder
  contentBuilder() {
    if (this.menu?.icon) {
      RelativeContainer() {
        if (this.menu?.isIconNeedColor) {
          this.iconNeedColor();
        } else {
          this.iconNoNeedColor();
        }
        // 分身应用的角标
        if (this.isCloneApp()) {
          Image($r(`app.media.app_icon_clone_index_${this.getAppIndex()}`))
            .height('18vp')
            .width('18vp')
            .offset({ start: LengthMetrics.vp(6), top: LengthMetrics.vp(2) })
            .alignRules({
              right: { anchor: `entry_image_${this.menu?.key}`, align: HorizontalAlign.End },
              bottom: { anchor: `entry_image_${this.menu?.key}`, align: VerticalAlign.Bottom },
            })
        }
      }
      .width(this.style?.iconImage?.size?.width)
      .height(this.style?.iconImage?.size?.height)
      .margin(this.style?.iconImage?.margin ? StyleConstant.getLocalizedPadding(this.style?.iconImage?.margin) : 0)
    }
    Row() {
      if (this.menu?.badge) {
        Badge({
          count: this.uiRefresher.refreshId ? this.menu?.badge : this.menu?.badge,
          position: BadgePosition.Right,
          style: this.style?.badge?.badgeStyle
        }) {
          this.titleBuilder()
        }
        .flexGrow(FontScaleUtils.isExtraLargeFontMode() ? 0 : 1)
        .flexShrink((this.style as DefaultEntryMenuStyle)?.startFlexShrink ?? 0)
        .padding({
          end: this.style?.badge?.padding?.right ? LengthMetrics.vp(this.style?.badge?.padding?.right as number) :
            PADDING_0
        })
        .margin({
          end: this.style?.badge?.margin?.right ? LengthMetrics.vp(this.style?.badge?.margin?.right as number) :
            PADDING_0
        })
      } else {
        this.titleBuilder()
      }
    }
    .flexGrow(FontScaleUtils.isExtraLargeFontMode() && !this.menu?.isAccountMenu ? 0 : 1)
    .flexShrink((this.style as
    DefaultEntryMenuStyle)?.startFlexShrink ?? 0) //The attributes of some subclasses can be obtained through as.
    .justifyContent(this.style?.rootContainer?.justifyContent ?? FlexAlign.Start)

    Row() {
      Row() {
        if (this.menu?.state) {
          Text(this.menu?.state)
            .onClick(this.controller?.onStateTextClick)
            .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.state)
            .constraintSize({ maxWidth:'90%' })
            .wordBreak(WordBreak.BREAK_WORD)
            .id(`entry_text_${this.menu?.key}`)
        }

        if (this.menu?.stateIcon) {
          Image(this.uiRefresher?.refreshId ? this.menu?.stateIcon : this.menu?.stateIcon)
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
            .edgeAntialiasing(EDGE_ANTI_ALIASING)
            .matchTextDirection(true);
        }

        if (this.menu?.symbolIcon) {
          SymbolGlyph((this.uiRefresher?.refreshId ? this.menu?.symbolIcon : this.menu?.symbolIcon) as Resource)
            .hoverEffect(this.controller?.onStateIconClick ? HoverEffect.Highlight : null)
            .onClick(this.controller?.onStateIconClick as (event?: ClickEvent) => void)
            .id(`entry_symbolIcon_${this.menu?.key}`)
            .stateStyles({
              normal: this.normalStateIconStyles,
              pressed: this.pressedStateIconStyles,
            })
            .visibility((this.menu?.symbolIcon) ? Visibility.Visible : Visibility.None)
            .symbolGlyphStyle(this.style?.symbolIcon)
        }
      }
      .width(this.getFonSizeCaleState() ? '100%' : 'auto')
      .justifyContent(FlexAlign.SpaceBetween)
      .visibility(((this.menu?.state) || (this.menu?.stateIcon) || (this.menu?.symbolIcon)) ?
        Visibility.Visible : Visibility.None)
      .margin({
        start: this.getSpace(((this.menu?.state != undefined) ||
          (this.menu?.stateIcon != undefined) || (this.menu?.symbolIcon != undefined)), this.style?.stateContainer)
      })

      Row() {
        if (this.menu?.secondState) {
          Text(this.menu?.secondState)
            .onClick(this.controller?.onSecondStateTextClick)
            .visibility((this.menu?.secondState) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.secondState)
        }

        if (this.menu?.secondStateIcon) {
          Image(this.menu?.secondStateIcon)
            .fillColor($r('sys.color.ohos_id_color_primary'))
            .hoverEffect(this.controller?.onSecondStateIconClick ? HoverEffect.Highlight : null)
            .id(`entry_image2_${this.menu?.key}`)
            .onClick(this.controller?.onSecondStateIconClick as (event?: ClickEvent) => void)
            .stateStyles({
              normal: this.normalSecondStateIconStyles,
              pressed: this.pressedSecondStateIconStyles,
            })
            .visibility((this.menu?.secondStateIcon) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.secondStateIcon)
        }
      }
      .onHover((isHover) => {
        isHover = isHover ? true : false;
        this.secondIsHover = isHover;
      })
      .onMouse((event?: MouseEvent): void => {
        if (event) {
          this.onSecondMouseEvent(event);
        }
      })
      .onTouch((event?: TouchEvent): void => {
        if (event) {
          this.onSecondTouchEvent(event);
        }
      })
      .visibility(((this.menu?.secondState) || (this.menu?.secondStateIcon)) ? Visibility.Visible : Visibility.None)
      .margin({
        start: this.getSpace(((this.menu?.state != undefined) ||
          (this.menu?.stateIcon != undefined)), this.style?.secondStateContainer)
      })
    }
    .flexShrink((this.style as DefaultEntryMenuStyle)?.endFlexShrink ?? 0) // 空值检测默认值为0
    .align(Alignment.End)
    .justifyContent(FlexAlign.End)
  }

  build() {
    Column() {
      Column() {
        if (this.controller?.onLongPressGesture) {
          Flex(this.getFonSizeCaleState() ? { direction: FlexDirection.Column } :
            { justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            this.contentBuilder()
          }
          .gesture(LongPressGesture().onActionEnd(this.controller?.onLongPressGesture as
          (event?: GestureEvent) => void))
          .height(this.style?.rootContainer?.size?.height as Length)
          .width(this.style?.rootContainer?.size?.width as Length)
          .constraintSize(this.style?.rootContainer?.constraintSize)
          .padding(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.padding)) // 空值检测默认值为0
          .margin(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.margin)) // 空值检测默认值为0
          .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
          .clip(this.style?.rootContainer?.clip)
          .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
          .onAppear(() => {
            this.reset();
          })
          .onDisAppear(() => {
            this.reset();
          })
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
        } else {
          Flex(this.getFonSizeCaleState() ? { direction: FlexDirection.Column } : {
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Center
          }) {
            this.contentBuilder()
          }
          .height(this.style?.rootContainer?.size?.height as Length)
          .width(this.style?.rootContainer?.size?.width as Length)
          .constraintSize(this.style?.rootContainer?.constraintSize)
          .padding(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.padding)) // 空值检测默认值为0
          .margin(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.margin)) // 空值检测默认值为0
          .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
          .clip(this.style?.rootContainer?.clip)
          .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
          .onAppear(() => {
            this.reset();
          })
          .onDisAppear(() => {
            this.reset();
          })
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
        }
      }
      .width('100%')
    }
    .accessibilityGroup(true)
    .padding(this.getBackgroundPadding())
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private isCloneApp(): boolean {
    const index = this.getAppIndex();
    return index > 0 && index <= 5;
  }

  private getAppIndex(): number {
    const extra = this.menu.extra as extraType;
    return extra?.appIndex || 0;
  }

  private getFonSizeCaleState(): boolean {
    return !!((this.menu.key !== 'mac_address_settings') && this.menu.state &&
      FontScaleUtils.isExtraLargeFontMode())
  }

  private getBackgroundColor(): ResourceColor {
    if (this.secondIsHover || this.isSecondSelected) {
      return $r('app.color.color_default_white');
    }
    if ((DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad()) &&
    this.isSelected && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (DeviceUtil.isDevicePc() && this.isSelected && !this.isHover) {
      return $r('app.color.color_default_white');
    }
    if (this.isSelected) {
      if (this.menu?.key === 'dormancy_settings' || this.menu?.key === 'software_version') {
        return $r('sys.color.ohos_id_color_click_effect');
      }
      if (DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) {
        return $r('app.color.color_default_white');
      } else {
        return this.menu?.key === 'app_info_header' ?
        $r('app.color.color_default_white') :
        $r('app.color.color_1A000000_grey')
      }
    }
    if (!this.showSelectedBackColor && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.color_pressed_click_dark') : $r('app.color.color_pressed_click');
    }
    if (this.menu.key === NavEntryKey.USER_SETTING_ENTRY &&
      (this.pathInfos?.getAllPathName()[0] === NavEntryKey.ADMIN_USER_ENTRY)) {
      return $r('app.color.color_pressed_click');
    }
    return $r('app.color.color_default_white');
  }

  private onSecondMouseEvent(event: MouseEvent): void {
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSecondSelected = false;
    }
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onSecondTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.type === TouchType.Up) {
      this.isSecondSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private getSpace(isVisible: boolean, style?: BaseStyle): LengthMetrics {
    if (!isVisible) {
      return PADDING_0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return LengthMetrics.vp(style?.margin?.left as number);
    }
    return LengthMetrics.vp(this.style?.rootContainer?.space as number ?? 0); // 空值检测默认值为0
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || this.controller?.isRespondTouchEvent;
  }

  private getBackgroundPadding(): LocalizedPadding {
    let leftPadding: Length = (this.style as HomeEntryMenuStyle)?.marginStatus && !this.showSelectedBackColor ? 0 :
    $r('app.float.wh_value_4');
    let topPadding = (this.style as HomeEntryMenuStyle)?.homeSpacing ?? 0;
    return StyleConstant.getLocalizedPadding({
      left: leftPadding,
      right: leftPadding,
      top: topPadding,
      bottom: topPadding
    });
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear: ${this.menu?.key}`);
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter subscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.on({
        eventId: EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE,
        priority: emitter.EventPriority.IMMEDIATE,
      }, (eventData: emitter.EventData) => {
        if (eventData?.data?.key === this.controller?.getKey()) {
          LogUtil.info(`${TAG} handlePluginWindowAboutToCloseEvent`);
          this.reset();
        }
      });
    }
  }

  aboutToDisappear(): void {
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter unsubscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.off(EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE);
    }
  }
}

@Component
export struct AboutDeviceEntryComponent {
  tag: string = 'AboutDeviceEntryComponent : ';
  @Link menu: BaseEntryMenu;
  @Link style: EntryMenuStyle;
  @Link controller: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
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

  @Styles
  pressedStyles() {
    .backgroundColor(this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Builder
  iconNoNeedColor() {
    Image(this.menu?.icon)
      .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
      .imageStyle(this.style?.iconImage)
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start)
      .id(`entry_image_${this.menu?.key}`)
      .autoResize(false)
      .interpolation(ImageInterpolation.Medium)
      .focusable(this.menu.menuType === MenuType.NAVIGATION_MENU_ENTRY ||
        this.menu.menuType === MenuType.NAVIGATOR_ENTRY)
      .edgeAntialiasing(EDGE_ANTI_ALIASING)
  };

  @Builder
  aboutDeviceContentBuilder() {
    this.iconNoNeedColor();
    Column() {
      this.aboutDeviceTitleBuilder();

      Badge({
        value: '',
        position: BadgePosition.Right,
        style: this.style?.badge?.badgeStyle
      }) {
        Text(this.menu?.state)
          .onClick(this.controller?.onStateTextClick)
          .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible : Visibility.None)
          .textStyle(this.style?.state)
          .id(`entry_text_${this.menu?.key}`)
      }
      .flexGrow(1)
      .flexShrink((this.style as DefaultEntryMenuStyle)?.startFlexShrink ?? 0)
      .padding({
        right: this.style?.badge?.padding?.right ?? 0
      })
      .margin({
        right: this.style?.badge?.margin?.right ?? 0
      })
      .visibility(this.uiRefresher?.refreshId ? (this.menu?.badge ? Visibility.Visible : Visibility.None) :
        (this.menu?.badge ? Visibility.Visible : Visibility.None))
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  aboutDeviceTitleBuilder() {
    Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
      .onClick(this.controller?.onTitleClick)
      .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
      .textStyle(this.style?.title as PageTitleTextStyle)
      .id(`entry_title_${this.menu?.key}`)
      .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
      .maxLines(this.style?.textStyle?.maxLines ?? 99)
      .textOverflow({
        overflow: this.style?.textStyle?.overflow ?? TextOverflow.None
      })
      .wordBreak(WordBreak.BREAK_ALL)
      .size(this.style?.textStyle?.size)
      .focusable(true)
  }

  build() {
    Column() {
      Column() {
        Flex({
          justifyContent: FlexAlign.Start,
          alignItems: ItemAlign.Center
        }) {
          this.aboutDeviceContentBuilder()
        }
        .height(this.style?.rootContainer?.size?.height as Length)
        .width(this.style?.rootContainer?.size?.width as Length)
        .constraintSize(this.style?.rootContainer?.constraintSize)
        .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
        .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
        .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
        .clip(this.style?.rootContainer?.clip)
        .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
        .onAppear(() => {
          this.reset();
        })
        .onDisAppear(() => {
          this.reset();
        })
        .stateStyles({
          normal: this.normalStateIconStyles,
          pressed: this.pressedStyles,
        })
      }
      .width('100%')
      .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
      .borderRadius(this.style?.rootContainer?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_card'))
    }
    .padding(this.getBackgroundPadding())
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.secondIsHover || this.isSecondSelected) {
      return $r('app.color.color_default_white');
    }
    if (this.isSelected && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (this.isSelected && !this.isHover) {
      return $r('app.color.color_default_white');
    }
    if (this.isSelected) {
      return $r('app.color.color_1A000000_grey');
    }
    if (!this.showSelectedBackColor && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return uiAppearance.getDarkMode() === 0 ? $r('app.color.color_pressed_click_dark') : $r('app.color.color_pressed_click');
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return $r('app.color.color_default_white');
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || this.controller?.isRespondTouchEvent;
  }

  private getBackgroundPadding(): Padding {
    let leftPadding: Length = $r('app.float.margin_0');
    let topPadding = $r('app.float.margin_0');
    let padding: Padding = { left: leftPadding, right: leftPadding, top: topPadding, bottom: topPadding };
    return padding;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear: ${this.menu?.key}`);
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter subscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.on({
        eventId: EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE,
        priority: emitter.EventPriority.IMMEDIATE,
      }, (eventData: emitter.EventData) => {
        if (eventData?.data?.key === this.controller?.getKey()) {
          LogUtil.info(`${TAG} handlePluginWindowAboutToCloseEvent`);
          this.reset();
        }
      });
    }
  }

  aboutToDisappear(): void {
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter unsubscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.off(EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE);
    }
  }
}

@Component
export struct SecondComponent {
  tag: string = 'SecondComponent : ';
  @Link menu: BaseEntryMenu;
  @Link style: EntryMenuStyle;
  @Link controller: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
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

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(this.controller?.onSecondStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius('8vp')
  }

  private getFonSizeCaleState(): boolean {
    return !!(this.menu.state && FontScaleUtils.isExtraLargeFontMode())
  }

  build() {
    Stack() {
      Column() {
        Text()
          .width('100%')
          .constraintSize(this.style?.rootContainer?.constraintSize)
          .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
          .borderRadius($r('sys.float.ohos_id_corner_radius_notification'))
      }
      .height(this.style?.rootContainer?.size?.height as Length)
      .width('100%')
      .constraintSize(this.style?.rootContainer?.constraintSize)
      .padding(this.getBackgroundPadding())

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        if (this.menu?.icon) {
          Image(this.menu?.icon)
            .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.iconImage)
            .flexGrow(0)
            .flexShrink(0)
            .width(this.style?.iconImage?.size?.width ?? $r('app.float.wh_value_24'))
            .height(this.style?.iconImage?.size?.height ?? $r('app.float.wh_value_24'))
            .align(Alignment.Start)
            .id(`entry_image_${this.menu?.key}`)
            .autoResize(false)
            .interpolation(ImageInterpolation.Medium)
        }
        Flex(this.getFonSizeCaleState() ? { direction: FlexDirection.Column } : {}) {
          Row() {
            Column() {
              Row() {
                if (this.menu?.title) {
                  Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
                    .onClick(this.controller?.onTitleClick)
                    .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.title as PageTitleTextStyle)
                    .id(`entry_title_${this.menu?.key}`)
                    .flexGrow(1)
                  if (this.menu?.textImg) {
                    Image(this.menu.textImg)
                      .width($r('app.float.length_20'))
                      .height($r('app.float.length_20'))
                  }
                }
                if (this.menu?.showNewInfo) {
                  Image($r('app.media.new_info_point'))
                    .visibility((this.menu?.showNewInfo) ? Visibility.Visible : Visibility.None)
                    .imageStyle(this.style?.newInfoImage)
                }
              }
            }
            .alignItems(this.style?.rootContainer?.horizontalAlign ?? HorizontalAlign.Start)
          }
          .flexShrink(0)
          .justifyContent(this.style?.rootContainer?.justifyContent ?? FlexAlign.Start)

          Row() {
            Row() {
              Column() {
                if (this.uiRefresher?.refreshId ? this.menu?.state : this.menu?.state) {
                  Text(this.uiRefresher?.refreshId ? this.menu?.state : this.menu?.state)
                    .onClick(this.controller?.onStateTextClick)
                    .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.state)
                    .id(`entry_text_${this.menu?.key}`)
                }
                if (this.uiRefresher?.refreshId ? this.menu?.secondState : this.menu?.secondState) {
                  Text(this.uiRefresher?.refreshId ? this.menu?.secondState : this.menu?.secondState)
                    .visibility((this.menu?.secondState) || this.style?.secondState?.visible ?
                      Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.state)
                }
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.End)
            }
            .visibility(((this.menu?.state) || (this.menu?.stateIcon)) ? Visibility.Visible : Visibility.None)

            Row() {
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
                  .fillColor($r('sys.color.ohos_id_color_fourth'))
              }
            }
            .flexShrink(0)
            .onHover((isHover) => {
              this.secondIsHover = isHover;
            })
            .onMouse((event?: MouseEvent): void => {
              if (event) {
                this.onSecondMouseEvent(event);
              }
            })
            .onTouch((event?: TouchEvent): void => {
              if (event) {
                this.onSecondTouchEvent(event);
              }
            })
            .visibility(((this.menu?.secondState) || (this.menu?.secondStateIcon)) ? Visibility.Visible : Visibility.None)
          }
          .justifyContent(FlexAlign.End)
          .align(Alignment.End)
          .flexGrow(1)
        }
      }
      .gesture(LongPressGesture().onActionEnd(this.controller?.onLongPressGesture as (event?: GestureEvent) => void))
      .height(this.style?.rootContainer?.size?.height as Length)
      .width(this.style?.rootContainer?.size?.width as Length)
      .constraintSize(this.style?.rootContainer?.constraintSize)
      .padding({
        left: $r('app.float.length_12'),
        right: $r('app.float.length_12'),
        top: FontScaleUtils.getCurrentTopPadding(),
        bottom: FontScaleUtils.getCurrentTopPadding()
      })
      .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
      .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
      .clip(this.style?.rootContainer?.clip)
      .borderRadius(this.style?.rootContainer?.borderRadius as Length)
      .onTouch((event?: TouchEvent): void => {
        if (event) {
          this.onTouchEvent(event);
        }
      })
      .onHover((isHover) => {
        this.isHover = this.updateHover(isHover);
        this.controller?.handleHoverEvent(isHover);
      })
      .onMouse((event?: MouseEvent): void => {
        if (event) {
          this.onMouseEvent(event);
        }
      })
      .onAppear(() => {
        this.reset();
      })
      .onDisAppear(() => {
        this.reset();
      })
    }.visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.secondIsHover || this.isSecondSelected) {
      return $r('app.color.color_default_white');
    }
    if (DeviceUtil.isDevicePc() && this.isSelected && !this.isHover) {
      return $r('app.color.color_default_white');
    }
    if (!this.showSelectedBackColor && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (this.menu.key === NavEntryKey.USER_SETTING_ENTRY &&
      (this.pathInfos?.getAllPathName()[0] === NavEntryKey.ADMIN_USER_ENTRY)) {
      return $r('app.color.color_pressed_click');
    }
    return $r('app.color.color_default_white');
  }

  private onSecondMouseEvent(event: MouseEvent): void {
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSecondSelected = false;
    }
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onSecondTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.type === TouchType.Up) {
      this.isSecondSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private getSpace(isVisible: boolean, style?: BaseStyle): Length {
    if (!isVisible) {
      return 0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return style?.margin?.left;
    }
    return this.style?.rootContainer?.space ?? 0; // 空值检测默认值为0
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || this.controller?.isRespondTouchEvent;
  }

  private getBackgroundPadding(): Padding {
    let leftPadding: Length =
      (this.style as HomeEntryMenuStyle)?.marginStatus && !this.showSelectedBackColor ? 0 : $r('app.float.wh_value_4');
    let topPadding = (this.style as HomeEntryMenuStyle)?.homeSpacing ?? 0;
    return { left: leftPadding, right: leftPadding, top: topPadding, bottom: topPadding };
  }

  aboutToAppear(): void {
    LogUtil.info(this.menu?.key)
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter subscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.on({
        eventId: EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE,
        priority: emitter.EventPriority.IMMEDIATE,
      }, (eventData: emitter.EventData) => {
        if (eventData?.data?.key === this.controller?.getKey()) {
          LogUtil.info(`${TAG} handlePluginWindowAboutToCloseEvent`);
          this.reset();
        }
      });
    }
  }

  aboutToDisappear(): void {
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter unsubscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.off(EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE);
    }
  }
}

@Component
export struct CheckboxEntryComponent {
  tag: string = 'CheckboxEntryComponent : ';
  @Link menu: NavigationCheckboxEntry;
  @Link style: EntryMenuStyle;
  @Link controller: NavCheckboxMenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State showSelectedBackColor: boolean = true;
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

  @Styles
  pressedStyles() {
    .backgroundColor(((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) &&
      this.menu.menuType !== MenuType.STATE) ? $r('sys.color.ohos_id_color_click_effect') :
      (this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null))
    .borderRadius(this.style?.stateStyles?.pressed?.borderRadius ?? $r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(this.controller?.onSecondStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius('8vp')
  }

  @Builder
  checkboxTitleBuilder() {
    Column() {
      Row() {
        Checkbox()
          .id('checkboxEntry_checkbox')
          .width(20)
          .height(20)
          .select(this.menu?.selected ?? false)
          .selectedColor($r('sys.color.ohos_id_color_component_activated'))
          .onChange((value: boolean) => {
            this.controller?.onCheckboxChange(value);
            LogUtil.info(`${TAG} CheckboxMenuComponent`);
          })
          .accessibilityFocusDrawLevel(FocusDrawLevel.TOP)
          .accessibilityLevel(AccessibilityLevelType.YES)
          .accessibilityText(this.menu?.title as string)
          .margin({ end: PADDING_12 })
          .enabled(this.uiRefresher.refreshId ? this.menu?.enable ?? true : this.menu?.enable ?? true);
        Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
          .onClick(this.controller?.onTitleClick)
          .id(`entry_title_${this.menu?.key}`)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .textAlign(TextAlign.Start)
      }
      .width('75%')
    }
    .alignItems(this.style?.rootContainer?.horizontalAlign ?? HorizontalAlign.Start)
  }

  @Builder
  contentBuilder() {
    Row() {
      this.checkboxTitleBuilder();
    }
    .flexGrow(1)
    .flexShrink((this.style as
    DefaultEntryMenuStyle)?.startFlexShrink ?? 0) //The attributes of some subclasses can be obtained through as.
    .justifyContent(this.style?.rootContainer?.justifyContent ?? FlexAlign.Start);

    Row() {
      Row() {
        if (this.menu?.state) {
          Text(this.menu?.state)
            .onClick(this.controller?.onStateTextClick)
            .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.state)
            .id(`entry_text_${this.menu?.key}`);
        }
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
            .fillColor($r('sys.color.ohos_id_color_fourth'))
            .matchTextDirection(true);
        }
      }
      .visibility(((this.menu?.state) || (this.menu?.stateIcon)) ? Visibility.Visible : Visibility.None)
      .margin({
        start: this.getSpace(((this.menu?.state != undefined) ||
          (this.menu?.stateIcon != undefined)), this.style?.stateContainer)
      });
    }
    .flexShrink((this.style as DefaultEntryMenuStyle)?.endFlexShrink ?? 0) // 空值检测默认值为0
    .align(Alignment.End);
  }

  build() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          this.contentBuilder();
        }
        .gesture(LongPressGesture().onActionEnd(this.controller?.onLongPressGesture as (event?: GestureEvent) => void))
        .height(this.style?.rootContainer?.size?.height as Length)
        .width(this.style?.rootContainer?.size?.width as Length)
        .constraintSize(this.style?.rootContainer?.constraintSize)
        .padding(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.padding))
        .margin(StyleConstant.getLocalizedPadding(this.style?.rootContainer?.margin))
        .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0)
        .clip(this.style?.rootContainer?.clip)
        .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
        .onAppear(() => {
          this.reset();
        })
        .onDisAppear(() => {
          this.reset();
        })
        .stateStyles({
          normal: this.normalStateIconStyles,
          pressed: this.pressedStyles,
        })
      }
      .padding(this.getBackgroundPadding())
      .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private getBackgroundColor(): ResourceColor {
    if ((DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad()) &&
    this.isSelected && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (DeviceUtil.isDevicePc() && this.isSelected && !this.isHover) {
      return $r('app.color.color_default_white');
    }
    if (this.isSelected) {
      return this.menu?.key === 'app_info_header' ?
      $r('app.color.color_default_white') :
      $r('app.color.color_1A000000_grey')
    }
    if (!this.showSelectedBackColor && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (this.isHover && DeviceUtil.isDevicePc()) {
      return $r('app.color.color_0D000000_grey');
    }
    return $r('app.color.color_default_white');
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || this.controller?.isRespondTouchEvent;
  }

  private reset(): void {
    this.isSelected = false;
  }

  private getSpace(isVisible: boolean, style?: BaseStyle): LengthMetrics {
    if (!isVisible) {
      return PADDING_0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return LengthMetrics.vp(style?.margin?.left as number ?? 0);
    }
    return LengthMetrics.vp(this.style?.rootContainer?.space as number ?? 0); // 空值检测默认值为0
  }

  private getBackgroundPadding(): LocalizedPadding {
    let leftPadding: Length = (this.style as HomeEntryMenuStyle)?.marginStatus &&
      !this.showSelectedBackColor ? 0 : $r('app.float.wh_value_4');
    let topPadding = (this.style as HomeEntryMenuStyle)?.homeSpacing ?? 0;
    return StyleConstant.getLocalizedPadding({
      left: leftPadding,
      right: leftPadding,
      top: topPadding,
      bottom: topPadding
    });
  }

  aboutToAppear(): void {
    LogUtil.info(this.menu?.key)
  }

  aboutToDisappear(): void {
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter unsubscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.off(EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE);
    }
  }
}

@Component
export struct EntryInfoComponent {
  tag: string = 'EntryInfoComponent : ';
  @Link menu: BaseEntryMenu;
  @Link style: EntryMenuStyle;
  @Link controller: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
  @State pathInfos: NavPathStack | null = null;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius('8vp')
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius('8vp')
  }

  @Styles
  pressedStyles() {
    .backgroundColor(((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) &&
      this.menu.menuType !== MenuType.STATE) ? $r('sys.color.ohos_id_color_click_effect') :
      (this.controller?.onStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(this.controller?.onSecondStateIconClick ? $r('sys.color.ohos_id_color_click_effect') : null)
    .borderRadius('8vp')
  }

  build() {
    Column() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          if (this.menu?.icon) {
            Image(this.menu?.icon)
              .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
              .imageStyle(this.style?.iconImage)
              .flexGrow(0)
              .flexShrink(0)
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .align(Alignment.Start)
              .id(`entry_image_${this.menu?.key}`)
              .autoResize(false)
              .interpolation(ImageInterpolation.Medium)
              .margin({ right: $r('app.float.margin_16') })
          }
          Row() {
            Column() {
              Row() {
                if (this.menu?.title) {
                  Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
                    .onClick(this.controller?.onTitleClick)
                    .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.title as PageTitleTextStyle)
                    .id(`entry_title_${this.menu?.key}`)
                    .margin({ right: $r('app.float.margin_16') })
                    .flexGrow(1)
                  if (this.menu?.textImg) {
                    Image(this.menu.textImg)
                      .width($r('app.float.length_20'))
                      .height($r('app.float.length_20'))
                  }
                }
                if (this.menu?.showNewInfo) {
                  Image($r('app.media.new_info_point'))
                    .visibility((this.menu?.showNewInfo) ? Visibility.Visible : Visibility.None)
                    .imageStyle(this.style?.newInfoImage)
                }
              }
            }
            .alignItems(this.style?.rootContainer?.horizontalAlign ?? HorizontalAlign.Start)
          }
          .flexShrink(0)
          .justifyContent(this.style?.rootContainer?.justifyContent ?? FlexAlign.Start)

          Row() {
            Row() {
              Column() {
                if (this.uiRefresher?.refreshId ? this.menu?.state : this.menu?.state) {
                  Text(this.uiRefresher?.refreshId ? this.menu?.state : this.menu?.state)
                    .onClick(this.controller?.onStateTextClick)
                    .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible :
                      Visibility.None)
                    .textStyle(this.style?.state)
                    .id(`entry_text_${this.menu?.key}`)
                    .fontSize(14)
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })
                    .width('90%')
                    .maxLines(1)
                    .lineHeight(20)
                    .baselineOffset(2)
                    .textAlign(TextAlign.End)
                }
                if (this.uiRefresher?.refreshId ? this.menu?.summary : this.menu?.summary) {
                  Text(this.uiRefresher?.refreshId ? this.menu?.summary : this.menu?.summary)
                    .onClick(this.controller?.onSummaryClick)
                    .visibility((this.menu?.summary) || this.style?.summary?.visible ?
                      Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.state)
                    .fontSize($r('app.float.font_14'))
                    .width('90%')
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })
                    .maxLines(1)
                    .lineHeight($r('app.float.length_20'))
                    .baselineOffset(2)
                    .textAlign(TextAlign.End)
                }
                if (this.uiRefresher?.refreshId ? this.menu?.stateInfo : this.menu?.stateInfo) {
                  Text(this.uiRefresher?.refreshId ? this.menu?.stateInfo : this.menu?.stateInfo)
                    .onClick(this.controller?.onSecondSummaryClick)
                    .visibility((this.menu?.stateInfo) ? Visibility.Visible : Visibility.None)
                    .textStyle(this.style?.state)
                    .fontSize($r('app.float.font_14'))
                    .width('90%')
                    .textOverflow({
                      overflow: TextOverflow.Ellipsis
                    })
                    .maxLines(1)
                    .lineHeight($r('app.float.length_20'))
                    .baselineOffset(2)
                    .textAlign(TextAlign.End)
                }
              }
              .height(this.menu?.stateInfo ? $r('app.float.height_48') : $r('app.float.height_64'))
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.End)
            }
            .margin({ right: $r('app.float.margin_4') })
            .visibility(((this.menu?.state) || (this.menu?.stateIcon)) ? Visibility.Visible : Visibility.None)

            Row() {
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
                  .fillColor($r('sys.color.icon_fourth'))
              }
            }
            .flexShrink(0)
            .onHover((isHover) => {
              isHover = isHover ? true : false;
              this.secondIsHover = isHover;
            })
            .onMouse((event?: MouseEvent): void => {
              if (event) {
                this.onSecondMouseEvent(event);
              }
            })
            .onTouch((event?: TouchEvent): void => {
              if (event) {
                this.onSecondTouchEvent(event);
              }
            })
            .visibility(((this.menu?.secondState) || (this.menu?.secondStateIcon)) ? Visibility.Visible :
              Visibility.None)
          }
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Center)
          .flexGrow(1)
        }
        .gesture(LongPressGesture().onActionEnd(this.controller?.onLongPressGesture as (event?: GestureEvent) => void))
        .height(this.style?.rootContainer?.size?.height as Length)
        .width(this.style?.rootContainer?.size?.width as Length)
        .constraintSize(this.style?.rootContainer?.constraintSize)
        .padding({ left: $r('app.float.length_12'), right: $r('app.float.length_12') })
        .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
        .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
        .clip(this.style?.rootContainer?.clip)
        .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
        .onAppear(() => {
          this.reset();
        })
        .onDisAppear(() => {
          this.reset();
        })
        .stateStyles({
          normal: this.normalStateIconStyles,
          pressed: this.pressedStyles,
        })
      }
      .height(this.menu?.stateInfo ? $r('app.float.height_48') : $r('app.float.height_64'))
      .width('100%')
      .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
      .borderRadius($r('sys.float.ohos_id_corner_radius_notification'))
    }
    .padding(this.getBackgroundPadding())
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.secondIsHover || this.isSecondSelected) {
      return $r('app.color.color_default_white');
    }
    if (DeviceUtil.isDevicePc() && this.isSelected && !this.isHover) {
      return $r('app.color.color_default_white');
    }
    if ((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) && this.isSelected) {
      return $r('app.color.color_default_white');
    }
    if (!this.showSelectedBackColor && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
      return $r('app.color.color_pressed_click');
    }
    if (this.menu.key === NavEntryKey.USER_SETTING_ENTRY &&
      (this.pathInfos?.getAllPathName()[0] === NavEntryKey.ADMIN_USER_ENTRY)) {
      return $r('app.color.color_pressed_click');
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_click_effect');
    }
    return $r('app.color.color_default_white');
  }

  private onSecondMouseEvent(event: MouseEvent): void {
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSecondSelected = false;
    }
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    } else {
      LogUtil.info('error')
    }
  }

  private onSecondTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSecondSelected = true;
      this.isSelected = false;
    } else if (event.type === TouchType.Up) {
      this.isSecondSelected = false;
    } else {
      LogUtil.info('error')
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      LogUtil.showError(TAG, 'touch event is not respond.');
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    } else {
      LogUtil.info('error')
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private getSpace(isVisible: boolean, style?: BaseStyle): Length {
    if (!isVisible) {
      return 0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return style?.margin?.left;
    }
    return this.style?.rootContainer?.space ?? 0; // 空值检测默认值为0
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || this.controller?.isRespondTouchEvent;
  }

  private getBackgroundPadding(): Padding {
    let leftPadding: Length =
      (this.style as HomeEntryMenuStyle)?.marginStatus && !this.showSelectedBackColor ? 0 : $r('app.float.wh_value_4');
    let topPadding = (this.style as HomeEntryMenuStyle)?.homeSpacing ?? 0;
    return { left: leftPadding, right: leftPadding, top: topPadding, bottom: topPadding };
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear ${this.menu?.title}`);
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter subscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.on({
        eventId: EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE,
        priority: emitter.EventPriority.IMMEDIATE,
      }, (eventData: emitter.EventData) => {
        if (eventData?.data?.key === this.controller?.getKey()) {
          LogUtil.info(`${TAG} handlePluginWindowAboutToCloseEvent`);
          this.reset();
        }
      });
    }
  }

  aboutToDisappear(): void {
    if (this.controller instanceof JumpController) {
      LogUtil.info(`${TAG} emitter unsubscribe ${EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE}`);
      emitter.off(EVENT_ID_ON_PLUGIN_WINDOW_ABOUT_TO_CLOSE);
    }
  }
}


@Component
export struct TextComponent {
  tag: string = 'TextComponent : ';
  @Link menu: SettingsBaseMenu;
  @Link uiRefresher: UiRefresher;

  build() {
    Row() {
      Scroll() {
        Text(this.menu.title)
          .id(`text_title_${this.menu?.key}`)
          .visibility(this.uiRefresher.refreshId ? (this.menu.title ? Visibility.Visible :
          Visibility.None) : (this.menu.title ? Visibility.Visible : Visibility.None))
          .textStyle((this.menu.style as SubHeaderStyle)?.title)
          .wordBreak(WordBreak.BREAK_WORD)
          .accessibilityDescription(this.menu.accessibilityDescription ?? TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS)
      }
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .width((this.menu.style as SubHeaderStyle)?.rootContainer?.size?.width as Length)
    .height((this.menu.style as SubHeaderStyle)?.rootContainer?.size?.height as Length)
    .constraintSize((this.menu.style as SubHeaderStyle)?.rootContainer?.constraintSize)
    .align((this.menu.style as SubHeaderStyle)?.rootContainer?.align)
    .alignItems((this.menu.style as SubHeaderStyle)?.rootContainer?.verticalAlign)
    .justifyContent((this.menu.style as SubHeaderStyle)?.rootContainer?.justifyContent ?? FlexAlign.Start)
  }
}

@Component
export struct TextListComponent {
  tag: string = 'TextListComponent : ';
  @Link menu: DialogListMessageMenu;
  @Link uiRefresher: UiRefresher;

  build() {
    Row() {
      Scroll() {
        List() {
          ListItem() {
            Text(this.menu.title)
              .id(`text_title_${this.menu.key}`)
              .textStyle((this.menu.style as SubHeaderStyle).title)
              .wordBreak(WordBreak.BREAK_WORD)
          }
          ForEach(this.menu.textSiblings, (item: DialogListMessageMenu) => {
            ListItem() {
              Flex() {
                if (item.symbolIcon) {
                  Text() {
                    SymbolSpan(item.symbolIcon as Resource)
                  }
                  .id(`text_symbol_${item.key}`)
                  .textStyle((item.style as IconTextStyle).icon)
                  .flexShrink(0)
                  .accessibilityLevel('no-hide-descendants')
                }
                Text(item.title)
                  .id(`text_title_${item.key}`)
                  .textStyle((item.style as SubHeaderStyle).title)
                  .wordBreak(WordBreak.BREAK_WORD)
              }
            }
          })
        }
      }
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
    .width((this.menu.style as SubHeaderStyle)?.rootContainer?.size?.width as Length)
    .height((this.menu.style as SubHeaderStyle)?.rootContainer?.size?.height as Length)
    .constraintSize((this.menu.style as SubHeaderStyle)?.rootContainer?.constraintSize)
    .align((this.menu.style as SubHeaderStyle)?.rootContainer?.align)
    .alignItems((this.menu.style as SubHeaderStyle)?.rootContainer?.verticalAlign)
    .justifyContent((this.menu.style as SubHeaderStyle)?.rootContainer?.justifyContent ?? FlexAlign.Start)
  }
}

@Component
export struct LoadingComponent {
  tag: string = 'LoadingComponent : ';
  menuKey: string = '';
  title: ResourceStr = '';
  summary: ResourceStr = '';
  style?: DefaultLoadingMenuStyle | Style;
  controller: LoadingMenuController | undefined = undefined;
  @Link uiRefresher: UiRefresher;

  build() {
    Column() {
      Row() {
        Text(this.title)
          .visibility(this.title ? Visibility.Visible : Visibility.None)
          .textStyle((this.getStyle() as DefaultLoadingMenuStyle)?.title)
          .layoutWeight(this.title ? LAYOUT_WEIGHT_MAX : LAYOUT_WEIGHT_MIN)

        LoadingProgress()
          .size((this.getStyle() as DefaultLoadingMenuStyle)?.loadingProgressStyle?.size)
          .margin((this.getStyle() as DefaultLoadingMenuStyle)?.loadingProgressStyle?.margin)
          .padding((this.getStyle() as DefaultLoadingMenuStyle)?.loadingProgressStyle?.padding as Padding)
          .visibility(this.uiRefresher.refreshId && this.isLoadingVisible() ? Visibility.Visible : Visibility.Hidden)
          .id('loading_progress_' + this.menuKey)
      }
      .alignItems((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.verticalAlign)

      Text(this.summary)
        .visibility(this.summary ? Visibility.Visible : Visibility.None)
        .textStyle((this.getStyle() as DefaultLoadingMenuStyle)?.summary)
    }
    .size((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.size)
    .constraintSize((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.constraintSize)
    .padding((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.padding ?? 0)
    .margin((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.margin ?? 0)
    .alignItems((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.horizontalAlign)
    .justifyContent((this.getStyle() as DefaultLoadingMenuStyle)?.rootContainer?.justifyContent ?? FlexAlign.End)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private isLoadingVisible(): boolean {
    return !this.controller || !this.controller.isLoadingVisible || this.controller.isLoadingVisible();
  }

  private getStyle(): Style {
    return this.controller ? this.controller.menu?.style as Style : this.style as Style;
  }
}

@Component
export struct SpaceComponent {
  tag: string = 'SpaceComponent : ';
  space: Length = 0;
  @Link uiRefresher: UiRefresher;

  build() {
    Row() {
      Divider()
        .height(0)
        .color($r('sys.color.ohos_id_color_list_separator'))
    }
    .width('100%')
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }
}

@Component
export struct DividerComponent {
  tag: string = 'DividerComponent : ';
  style?: Style; // DividerStyle
  @Link uiRefresher: UiRefresher;

  build() {
    Row() {
      Divider()
        .vertical((this.style as DividerStyle)?.vertical ?? false)
        .strokeWidth((this.style as DividerStyle)?.strokeWidth as string | number)
        .color((this.style as BaseStyle)?.backgroundColor)
        .lineCap(LineCapStyle.Square);
    }
    .width('100%')
    .visibility(Visibility.Visible)
  }
}

@Component
export struct HeaderComponent {
  tag: string = 'HeaderComponent : ';
  targetPageUrl: string = '';
  menuKey: string = '';
  title: ResourceStr = '';
  isShowBack: boolean = true;
  isShowAbout: boolean = false;
  isStartAbility: boolean = false;
  style?: Style; // PageHeaderStyle
  @Link uiRefresher: UiRefresher;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_back_night'))
          .fillColor($r('sys.color.ohos_id_color_foreground'))
          .width('24vp')
          .height('24vp')
          .id('back_icon_' + this.menuKey)
          .margin({ left: '12vp' })
          .draggable(false);
      }
      .width('48vp')
      .height('48vp')
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .margin({ right: '4vp' })
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start)
      .visibility(this.isShowBack ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.onBackClick();
      })

      Row() {
        Text(this.uiRefresher?.refreshTitleId ? this.title : this.title)
          .textStyle((this.style as PageHeaderStyle)?.title)
          .textOverflow({ overflow: (this.style as PageHeaderStyle)?.title?.overflow ?? TextOverflow.Ellipsis })
          .maxLines((this.style as PageHeaderStyle)?.title?.maxLines ?? 1)
          .wordBreak(WordBreak.BREAK_WORD)
          .maxFontScale(2)
      }
      .flexGrow(1)
      .flexShrink((this.style as DefaultEntryMenuStyle)?.endFlexShrink ?? 0)
      .align(Alignment.Start)
      .accessibilityGroup(true)
      .justifyContent((this.style as PageHeaderStyle)?.title?.justifyContent ?? FlexAlign.Start)

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_about'))
          .width('24vp')
          .height('24vp')
          .id('about_icon_' + this.menuKey)
          .margin({ right: '12vp' })
          .draggable(false);
      }
      .width('48vp')
      .height('48vp')
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .margin({ left: '4vp' })
      .flexShrink((this.style as DefaultEntryMenuStyle)?.endFlexShrink ?? 0)
      .align(Alignment.End)
      .visibility(this.isShowAbout ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.onAboutClick();
      })
    }
    .visibility(this.uiRefresher?.refreshTitleId ? (this.uiRefresher.isVisible() ?
    Visibility.Visible : Visibility.None) : (this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None))
    .width((this.style as PageHeaderStyle)?.rootContainer?.size?.width as Length)
    .height((this.style as PageHeaderStyle)?.rootContainer?.size?.height as Length)
    .padding((this.style as PageHeaderStyle)?.rootContainer?.padding as Padding)
    .margin((this.style as PageHeaderStyle)?.rootContainer?.margin as Padding)
    .constraintSize((this.style as PageHeaderStyle)?.rootContainer?.constraintSize)
    .layoutWeight((this.style as PageHeaderStyle)?.rootContainer?.layoutWeight)
    .clip((this.style as PageHeaderStyle)?.rootContainer?.clip)
    .borderRadius((this.style as PageHeaderStyle)?.rootContainer?.borderRadius as Length)
    .backgroundColor((this.style as PageHeaderStyle)?.rootContainer?.backgroundColor)
  }

  private onAboutClick(): void {
    if (this.targetPageUrl) {
      let message: string = `pageUrl: ${this.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.pushUrl({
        url: this.targetPageUrl
      });
    }
  }

  private onBackClick(): void {
    if (this.isStartAbility) {
      this.startAbilityBack();
    } else {
      Router.back();
    }
  }

  private startAbilityBack(): void {
    let want: Want = {
      bundleName: 'com.ohos.clock',
      abilityName: 'com.ohos.clock.phone',
      parameters: {
        cityId: '',
      },
    };
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want);
      return;
    }
    if ((AppStorage.get<boolean>('isPcWorldClock') as boolean)) {
      let options: StartOptions = {
        windowMode: DEFAULT_WINDOW_MODE,
      };
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want, options);
      return;
    }
    Router.back();
    return;
  }
}

@Component
export struct NavHeaderComponent {
  tag: string = 'HeaderComponent : ';
  targetPageUrl: string = '';
  menuKey: string = '';
  title: ResourceStr = '';
  @State isShowBack: boolean = true;
  isShowAbout: boolean = false;
  isShowClose: boolean = false;
  titleMaxLine: number = TITLE_MAX_LINE_DEFAULT;
  isStartAbility: boolean = false;
  showALL: boolean = true;
  style?: Style; //DefaultNavPageHeaderStyle
  @Link uiRefresher: UiRefresher;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('curNavigationMode') @Watch('getNavigationMode') curNavigationMode: NavigationMode = NavigationMode.Auto;
  @StorageProp('isFromSearch') isFromSearch: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      if (!(this.isFromSearch && this.navigationMode === NavigationMode.Split)) {
        backButton(this.isShowBack, () => this.onBackClick());
      }

      Row() {
        Text(this.title)
          .textStyle((this.style as DefaultNavPageHeaderStyle)?.title)
          .fontSize((this.style as DefaultNavPageHeaderStyle)?.title?.font?.size as Length)
          .fontWeight((this.style as DefaultNavPageHeaderStyle)?.title?.font?.weight ?? FontWeight.Bold)
          .draggable(false)
          .maxLines(this.titleMaxLine)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .flexGrow(1)
      .flexShrink((this.style as NavigationEntryMenuStyle)?.endFlexShrink ?? 1)
      .align(Alignment.Start)

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_about'))
          .width('24vp')
          .height('24vp')
          .id('about_icon_' + this.menuKey)
          .margin({ end: PADDING_12 })
          .accessibilityText('')
          .draggable(false);
      }
      .width('48vp')
      .height('48vp')
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .margin({ start: PADDING_4 })
      .flexShrink((this.style as NavigationEntryMenuStyle)?.endFlexShrink ?? 0)
      .align(Alignment.End)
      .accessibilityText('')
      .visibility(this.isShowAbout ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.onAboutClick();
      });

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .width('20vp')
          .height('20vp')
          .draggable(false)
          .fontSize($r('app.float.font_20_vp'))
          .fontColor([$r('sys.color.icon_primary')])
      }
      .id('closeButton')
      .visibility(this.isShowClose ? Visibility.Visible : Visibility.None)
      .hoverEffect(HoverEffect.Highlight)
      .draggable(false)
      .width('40vp')
      .height('40vp')
      .margin({ start: PADDING_4, end: PADDING_4 })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .flexShrink((this.style as NavigationEntryMenuStyle)?.endFlexShrink ?? 0)
      .onClick(() => {
        this.onCloseClick();
      })
      .accessibilityText($r('app.string.close_menu'))
    }
    .id('NavHeaderComponent')
    .visibility(this.uiRefresher.isVisible() && this.showALL ? Visibility.Visible : Visibility.None)
    .width((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.size?.width as Length)
    .height((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.size?.height as Length)
    .padding(StyleConstant.getLocalizedPadding((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.padding as Padding))
    .margin(StyleConstant.getLocalizedPadding((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.margin as Padding))
    .constraintSize((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.constraintSize)
    .layoutWeight((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.layoutWeight as string | number)
    .clip((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.clip)
    .borderRadius((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.borderRadius as Length)
    .backgroundColor((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.backgroundColor);
  }

  private onAboutClick(): void {
    if (this.targetPageUrl) {
      let message: string = `pageUrl: ${this.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(this.targetPageUrl, null);
    }
  }

  private startAbilityBack(): void {
    let want: Want = {
      bundleName: 'com.ohos.clock',
      abilityName: 'com.ohos.clock.phone',
      parameters: {
        cityId: ''
      },
    };
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want);
      return;
    }
    if ((AppStorage.get<boolean>('isPcWorldClock') as boolean)) {
      let options: StartOptions = {
        windowMode: DEFAULT_WINDOW_MODE,
      };
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want, options);
      return;
    }
    Router.back();
    return;
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  clear() {
    this.pathInfos?.clear();
  }

  pop() {
    this.pathInfos?.pop();
  }

  popTo(entry: string) {
    this.pathInfos?.popToName(entry);
  }

  private onCloseClick(): void {
    LogUtil.info('onCloseClick');
    WalletManageUtils.sendAbilityResultToWallet(RESULT_CODE_INVALID);
    if (this.isStartAbility) {
      this.startAbilityBack();
      return;
    }
    let backEntry: string = AppStorage.Get(BACK_ENTRY) as string;
    if (!backEntry) {
      LogUtil.info('NavHeaderCompenent onCloseClick');
      this.pop();
      AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'),
        AuthConstant.CREATE_PSD_CLOSE);
      return;
    }
    AppStorage.setOrCreate(BACK_ENTRY, '');
    if (this.pathInfos?.getAllPathName().indexOf(backEntry) !== INDEX_NOT_FOUNT) {
      this.popTo(backEntry);
    } else {
      this.clear();
      this.pushName(backEntry, null);
    }
    AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'),
      AuthConstant.CREATE_PSD_CLOSE);
  }

  private onBackClick(): void {
    LogUtil.info('onBackClick');
    WalletManageUtils.sendAbilityResultToWallet(-1);
    if (this.isStartAbility) {
      this.startAbilityBack();
    } else {
      let backEntry: string = AppStorage.Get(BACK_ENTRY) as string;
      if (backEntry) {
        AppStorage.SetOrCreate(BACK_ENTRY, '');
        if (this.pathInfos?.getAllPathName().indexOf(backEntry) !== INDEX_NOT_FOUNT) {
          this.popTo(backEntry);
        } else {
          this.clear();
          this.pushName(backEntry, null);
        }
      } else {
        LogUtil.info('NavHeaderCompenent onBackClick');
        this.pop();
      }
      AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), -1);
    }
  }

  private getNavigationMode(): void {
    this.isShowBack = this.curNavigationMode === NavigationMode.Stack;
  }
}

@Component
export struct SelectEntryComponent {
  tag: string = 'SelectEntryComponent : ';
  @Link menu: BaseSelectEntryMenu;
  @Link style: DefaultSelectEntryMenuStyle;
  @Link controller: ConfigurationSelectController; // remind-del-tag: 可能会crash
  @Link uiRefresher: UiRefresher;

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
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Image(this.menu?.icon)
        .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
        .imageStyle(this.style?.iconImage)
        .flexGrow(0)
        .flexShrink(0)
        .align(Alignment.Start)

      Row() {
        Column() {
          Text(this.menu?.title)
            .onClick(this.controller?.onTitleClick)
            .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.title)
          Text(this.menu?.summary)
            .onClick(this.controller?.onSummaryClick)
            .visibility((this.menu?.summary) || this.style?.summary?.visible ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.summary)
          Text(this.menu?.secondSummary)
            .onClick(this.controller?.onSecondSummaryClick)
            .visibility((this.menu?.secondSummary) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.secondSummary)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .flexGrow(1)
      .flexShrink(this.style?.startFlexShrink ?? 0)
      .align(Alignment.Start)

      Row() {
        Row() {
          Text(this.menu?.state)
            .onClick(this.controller?.onStateTextClick)
            .visibility((this.menu?.state) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.state as PageTitleTextStyle)
          Image(this.menu?.stateIcon)
            .hoverEffect(this.controller?.onStateIconClick ? HoverEffect.Highlight : HoverEffect.None)
            .onClick(this.controller?.onStateIconClick as (event?: ClickEvent) => void)
            .stateStyles({
              normal: this.normalStateIconStyles,
              pressed: this.pressedStateIconStyles,
            })
            .visibility((this.menu?.stateIcon) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.stateIcon)
        }
        .visibility(((this.menu?.state) || (this.menu?.stateIcon)) ? Visibility.Visible : Visibility.None)
        .margin({
          left: this.getSpace(((this.menu?.state != undefined) ||
            (this.menu?.stateIcon != undefined)), this.style?.stateContainer)
        })

        Select(this.menu?.selectList)
          .backgroundColor(this.style?.selectStyle?.optionBgColor)
          .value(this.menu?.value)
          .selected(this.menu?.selected)
          .font((this.menu.key === 'time_zone_settings' || this.menu.key === 'debug_transition_animation') ? {
            size: $r('sys.float.ohos_id_text_size_button1'),
            weight: FontWeight.Medium,
            family: 'HarmonyHeiTi'
          } : this.style?.selectStyle?.font)
          .fontColor((this.menu.key === 'time_zone_settings' ||
            this.menu.key === 'debug_transition_animation') ?
          $r('sys.color.ohos_id_color_text_primary') : this.style?.selectStyle?.fontColor)
          .selectedOptionBgColor((this.menu.key === 'time_zone_settings' ||
            this.menu.key === 'debug_transition_animation') ?
          $r('sys.color.ohos_id_color_card_bg') : this.style?.selectStyle?.selectedOptionBgColor)
          .selectedOptionFont((this.menu.key === 'time_zone_settings' ||
            this.menu.key === 'debug_transition_animation') ? {
            size: $r('sys.float.ohos_id_text_size_body1'),
            weight: FontWeight.Regular,
            family: 'HarmonyHeiTi'
          } : this.style?.selectStyle?.selectedOptionFont)
          .selectedOptionFontColor((this.menu.key === 'time_zone_settings' ||
            this.menu.key === 'debug_transition_animation') ? $r('sys.color.ohos_id_color_text_primary') :
            this.style?.selectStyle?.selectedOptionFontColor)
          .optionBgColor(this.style?.selectStyle?.optionBgColor)
          .optionFont((this.menu.key === 'time_zone_settings' || this.menu.key === 'debug_transition_animation') ? {
            size: $r('sys.float.ohos_id_text_size_body1'),
            weight: FontWeight.Regular
          } : this.style?.selectStyle?.optionFont)
          .optionFontColor((this.menu.key === 'time_zone_settings' ||
            this.menu.key === 'debug_transition_animation') ?
          $r('sys.color.ohos_id_color_text_primary') : this.style?.selectStyle?.optionFontColor)
          .optionHeight(this.menu.key === 'bluetooth_device_type' ? null : $r('app.float.time_zone_height'))
          .menuAlign(MenuAlignType.END)
          .align(this.style?.selectStyle?.align)
          .margin(this.style?.selectStyle?.margin as Padding)
          .enabled(this.style?.selectStyle?.enabled ?? true)
          .onSelect((index: number) => {
            this.controller?.onSelectClick(index);
          })
          .onClick((event: ClickEvent) => {
            if (this.controller?.onClick) {
              this.controller?.onClick(event);
            }
          })
          .height($r('app.float.height_48'))
          .padding(this.style?.selectStyle?.padding as Padding)
          .borderRadius(this.style?.selectStyle?.borderRadius ?? $r('app.float.border_radius_16'))
          .onKeyEvent((event: KeyEvent) => {
            this.controller?.onKeyEvent(event);
          });
      }
      .flexShrink(this.style?.endFlexShrink ?? 0)
      .align(Alignment.End)
    }
    .gesture(LongPressGesture().onAction(this.controller?.onLongPressGesture as (event?: GestureEvent) => void))
    .height(this.style?.rootContainer?.size?.height as Length)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding(this.style?.rootContainer?.padding ?? 0)
    .margin(this.style?.rootContainer?.margin ?? 0)
    .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0)
    .clip(this.style?.rootContainer?.clip)
    .borderRadius(this.style?.rootContainer?.borderRadius as Length)
    .backgroundColor(this.style?.rootContainer?.backgroundColor)
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None)
  }

  private getWidth(): Resource {
    LogUtil.info(`${this.tag} showSelectedIcon, index: ${this.menu.key}`);
    if (this.menu.key === 'time_zone_settings') {
      LogUtil.info(`${this.tag} showSelectedIcon, index: ${this.menu.key}`);
      return $r('app.float.time_zone_width');
    } else if (this.menu.key === 'wifi_mac_address_settings' || this.menu.key === 'key_security_selector') {
      return $r('app.float.width_173');
    } else if (this.menu.key === 'debug_transition_animation') {
      return $r('app.float.width_173');
    } else {
      return $r('app.float.height_106');
    }
  }

  private getSpace(isVisible: boolean, style?: ContainerStyle): Length {
    if (!isVisible) {
      return 0;
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return style?.margin?.left;
    }
    return this.style?.rootContainer?.space ?? 0;
  }
}

@Extend(Image)
function imageStyle(imageStyle?: ImageStyle) {
  .width(imageStyle?.size?.width as Length)
  .height(imageStyle?.size?.height as Length)
  .constraintSize(imageStyle?.constraintSize)
  .padding(imageStyle?.padding ? StyleConstant.getLocalizedPadding(imageStyle?.padding) : 0)
  .margin(imageStyle?.margin ? StyleConstant.getLocalizedPadding(imageStyle?.margin) : 0)
  .borderRadius(imageStyle?.borderRadius ?? 12)
  .borderWidth(imageStyle?.borderWidth ?? 0)
  .borderColor(imageStyle?.borderColor ?? 0)
  .layoutWeight(imageStyle?.layoutWeight ?? 0)
  .objectFit(imageStyle?.imageFit ?? ImageFit.Contain)
  .opacity(imageStyle?.opacity ?? 1)
  .draggable(false)
}

@Extend(SymbolGlyph)
function symbolGlyphStyle(symbolGlyphStyle?: SymbolGlyphStyle) {
  .width(symbolGlyphStyle?.size?.width as Length)
  .height(symbolGlyphStyle?.size?.height as Length)
  .constraintSize(symbolGlyphStyle?.constraintSize)
  .padding(symbolGlyphStyle?.padding ?? 0)
  .margin(symbolGlyphStyle?.margin ?? 0)
  .borderRadius(symbolGlyphStyle?.borderRadius ?? 12)
  .borderWidth(symbolGlyphStyle?.borderWidth ?? 0)
  .borderColor(symbolGlyphStyle?.borderColor ?? 0)
  .layoutWeight(symbolGlyphStyle?.layoutWeight ?? 0)
  .opacity(symbolGlyphStyle?.opacity ?? 1)
  .renderingStrategy(symbolGlyphStyle?.renderingStrategy ?? SymbolRenderingStrategy.SINGLE)
  .draggable(false)
  .fontColor([$r('sys.color.ohos_id_color_fourth')])
  .fontWeight(symbolGlyphStyle?.fontWeight)
  .fontSize($r('app.float.length_24'))
}

@Extend(Text)
function textStyle(textStyle?: TextStyle) {
  .width(textStyle?.size?.width as Length)
  .height(textStyle?.size?.height as Length)
  .constraintSize(textStyle?.constraintSize)
  .padding(textStyle?.padding ? StyleConstant.getLocalizedPadding(textStyle?.padding) : 0)
  .margin(textStyle?.margin ? StyleConstant.getLocalizedPadding(textStyle?.margin) : 0)
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
  .heightAdaptivePolicy((textStyle as PageTitleTextStyle)?.font?.heightAdaptivePolicy)
}

@Extend(Toggle)
function toggleStyle(toggleStyle: SwitchToggleStyle) {
  .width(toggleStyle?.size?.width as Length)
  .height(toggleStyle?.size?.height as Length)
  .constraintSize(toggleStyle?.constraintSize)
  .padding(toggleStyle?.padding ?? 0)
  .margin(toggleStyle?.margin ?? 0)
}

@Component
export struct FlatEntryComponent {
  tag: string = 'FlatEntryComponent : ';
  @Link menu: EntryMenu;
  style?: DefaultEntryMenuStyle;
  controller?: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State showSelectedBackColor: boolean = true;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0) //  ux规定普通状态边界半径默认值0
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp') //  ux规定按压状态边界半径默认值8vp
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp') //  ux规定按压状态边界半径默认值8vp
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0) //  ux规定普通状态边界半径默认值0
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Image(this.menu?.icon)
        .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
        .imageStyle(this.style?.iconImage)
        .flexGrow(0)//  剩余空间百分比默认值0
        .flexShrink(0)//  压缩大小比例默认值0
        .align(Alignment.Start)
        .id(`entry_image_${this.menu?.key}`)
        .autoResize(false)
        .interpolation(ImageInterpolation.Medium)
      Row() {
        Column() {
          Row() {
            Text(this.menu?.title)
              .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
              .textStyle(this.style?.title)
            Image($r('app.media.new_info_point'))
              .visibility((this.menu?.showNewInfo) ? Visibility.Visible : Visibility.None)
              .imageStyle(this.style?.newInfoImage)
          }

          Text(this.menu?.summary)
            .visibility((this.menu?.summary) || this.style?.summary?.visible ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.summary)
          Text(this.menu?.secondSummary)
            .visibility((this.menu?.secondSummary) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.secondSummary)
        }
        .alignItems(this.style?.rootContainer?.horizontalAlign ?? HorizontalAlign.Start)
      }
      .flexGrow(1)
      .flexShrink(this.style?.startFlexShrink ?? 0) // 空值检测默认值为0
      .justifyContent(this.style?.rootContainer?.justifyContent ?? FlexAlign.Start)

      Row() {
        Row() {
          Text(this.menu?.state)
            .visibility((this.uiRefresher?.refreshId && this.menu?.state) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.state)
            .id(`entry_text_${this.menu?.key}`)
          Image(this.menu?.stateIcon)
            .hoverEffect(null)
            .id(`entry_image_${this.menu?.key}`)
            .stateStyles({
              normal: this.normalStateIconStyles,
              pressed: this.pressedStateIconStyles,
            })
            .visibility((this.menu?.stateIcon) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.stateIcon)
        }
        .visibility(((this.menu?.state) || (this.menu?.stateIcon)) ? Visibility.Visible : Visibility.None)
        .margin({
          left: this.getSpace(Boolean(((this.menu?.state) || (this.menu?.stateIcon))), this.style?.stateContainer)
        })

        Row() {
          Text(this.menu?.secondState)
            .visibility((this.menu?.secondState) ? Visibility.Visible : Visibility.None)
            .textStyle(this.style?.secondState)
          Image(this.menu?.secondStateIcon)
            .hoverEffect(null)
            .id(`entry_image2_${this.menu?.key}`)
            .stateStyles({
              normal: this.normalSecondStateIconStyles,
              pressed: this.pressedSecondStateIconStyles,
            })
            .visibility((this.menu?.secondStateIcon) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.secondStateIcon)
        }
        .visibility(((this.menu?.secondState) || (this.menu?.secondStateIcon)) ? Visibility.Visible : Visibility.None)
        .margin({
          left: this.getSpace(Boolean(((this.menu?.secondState) ||
            (this.menu?.secondStateIcon))), this.style?.secondStateContainer)
        })
      }
      .flexShrink(this.style?.endFlexShrink ?? 0) // 空值检测默认值为0
      .align(Alignment.End)
    }
    .height(this.style?.rootContainer?.size?.height as Length)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
    .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
    .clip(this.style?.rootContainer?.clip)
    .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
    .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
    .onAppear(() => {
      this.reset();
    })
    .onDisAppear(() => {
      this.reset();
    })
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private getBackgroundColor(): ResourceColor {
    if (this.showSelectedBackColor) {
      if (this.isSelected) {
        return $r('app.color.color_1A000000_grey');
      }
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return $r('app.color.color_default_white');
  }

  private getSpace(isVisible: boolean, style?: ContainerStyle): Length {
    if (!isVisible) {
      return 0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return style?.margin?.left;
    }
    return this.style?.rootContainer?.space ?? 0; // 空值检测默认值为0
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu);
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }
}

@Component
export struct SimplifyEntryComponent {
  tag: string = 'SimplifyEntryComponent : ';
  @Link menu: EntryMenu;
  style?: DefaultEntryMenuStyle;
  controller?: MenuController;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State showSelectedBackColor: boolean = true;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0) //  ux规定普通状态边界半径默认值0
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp') //  ux规定按压状态边界半径默认值8vp
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp') //  ux规定按压状态边界半径默认值8vp
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0) //  ux规定普通状态边界半径默认值0
  }

  // Time Zone list tailor
  build() {
    Column() {
      Text(this.uiRefresher.refreshId ? this.menu?.title : this.menu?.title)
        .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
        .textStyle(this.style?.title)

      Text(this.menu?.summary)
        .visibility((this.menu?.summary) || this.style?.summary?.visible ? Visibility.Visible : Visibility.None)
        .textStyle(this.style?.summary)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
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
    .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
    .onAppear(() => {
      this.reset();
    })
    .onDisAppear(() => {
      this.reset();
    })
    .onClick(() => {
      this.onEntryClick();
    })
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
  }

  private getBackgroundColor(): ResourceColor {
    if (this.showSelectedBackColor) {
      if (this.isSelected) {
        return $r('app.color.color_1A000000_grey');
      }
    }
    if (this.isHover) {
      return $r('app.color.color_0D000000_grey');
    }
    return $r('app.color.color_default_white');
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu);
  }
}

@Component
export struct AppListEntryComponent {
  tag: string = 'AppListEntryComponent : ';
  style: AppStyle | null = null;
  controller: MenuController | null = null;
  @Link menu: SettingsBaseMenu;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
  @State pathInfos: NavPathStack | null = null;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius('8vp')
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius('8vp')
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Image(this.menu?.icon)
        .visibility(Visibility.Visible)
        .imageStyle(this.style?.iconImage)
        .flexGrow(0)
        .flexShrink(0)
        .align(Alignment.Start)
        .id(`entry_image_${this.menu?.key}`)
        .autoResize(false)
        .interpolation(ImageInterpolation.Medium)
      Row() {
        Column() {
          Row() {
            Text(this.menu?.title)// .onClick(this.controller?.onTitleClick)
              .visibility(Visibility.Visible)
              .textStyle(this.style?.title)
          }

          Text(this.uiRefresher?.refreshId ? this.menu?.summary : this.menu?.summary)
            .visibility(Visibility.Visible)
            .textStyle(this.style?.summary)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .flexGrow(1)
      .flexShrink(this.style?.startFlexShrink ?? 0)
      .justifyContent(FlexAlign.Start)

      Row() {
        Image(this.menu?.stateIcon)
          .hoverEffect(HoverEffect.Highlight)
          .id(`entry_image_${this.menu?.key}`)
          .stateStyles({
            normal: this.normalStateIconStyles,
            pressed: this.pressedStateIconStyles,
          })
          .visibility(Visibility.Visible)
          .imageStyle(this.style?.stateIcon)
      }
      .visibility(Visibility.Visible)
      .flexShrink(this.style?.endFlexShrink ?? 0) // 空值检测默认值为0
      .align(Alignment.End)
    }
    .height(this.style?.rootContainer?.size?.height as Length)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
    .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
    .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
    .clip(this.style?.rootContainer?.clip)
    .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStateIconStyles,
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        this.onMouseEvent(event);
      }
    })
    .onAppear(() => {
      this.reset();
    })
    .onDisAppear(() => {
      this.reset();
    })
    .onClick(() => {
      this.onEntryClick();
    })
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu)
  }
}

@Component
export struct SettingHomeEntryComponent {
  tag: string = 'SettingHomeEntryComponent : ';
  @Link menu: NavigatorEntryMenu;
  @Link style: DefaultEntryMenuStyle;
  @Link controller: ExternalMenuController | null;
  @Link uiRefresher: UiRefresher;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @Link isSecondSelected: boolean;
  @State showSelectedBackColor: boolean = true;
  @State pathInfos: NavPathStack | null = null;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  @StorageProp('defaultEntryKey') defaultEntryKey: string = '';

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp')
  }

  @Styles
  pressedStyles() {
    .backgroundColor((display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED ||
    DeviceUtil.isDevicePad()) ? null : $r('sys.color.ohos_id_color_click_effect'))
    .borderRadius('12vp')
  }

  @Builder
  titleBuilder() {
    Text(this.menu?.title)
      .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
      .textStyle(this.style?.title)
      .flexGrow(1)
      .flexShrink(this.style?.startFlexShrink ?? 0)
  }

  build() {
    Column() {
      Column() {
        Row() {
          Image(this.menu?.icon)
            .visibility((this.menu?.icon) || this.style?.iconImage?.visible ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.iconImage)
            .flexGrow(0)
            .flexShrink(0)
            .align(Alignment.Start)
            .id(`entry_image_${this.menu?.key}`)
            .autoResize(false)
            .interpolation(ImageInterpolation.Medium)

          if (this.menu?.badge) {
            Badge({
              count: this.uiRefresher.refreshId ? this.menu?.badge : this.menu?.badge,
              position: BadgePosition.Right,
              style: this.style?.badge?.badgeStyle
            }) {
              this.titleBuilder()
            }
            .flexGrow(1)
            .flexShrink(this.style?.startFlexShrink ?? 0)
            .padding({
              right: this.style?.badge?.padding?.right ?? 0
            })
            .margin({
              right: this.style?.badge?.margin?.right ?? 0
            })
          } else {
            this.titleBuilder()
          }
          if (this.menu?.state) {
            Text(this.uiRefresher.refreshId ? this.menu?.state : this.menu?.state)
              .textStyle(this.style?.state)
          }
          Image(this.menu?.stateIcon)
            .hoverEffect(null)
            .id(`entry_image_${this.menu?.key}`)
            .stateStyles({
              normal: this.normalStateIconStyles,
              pressed: this.pressedStateIconStyles,
            })
            .visibility((this.menu?.stateIcon) ? Visibility.Visible : Visibility.None)
            .imageStyle(this.style?.stateIcon)
            .margin({
              left: this.getSpace(Boolean(((this.menu?.state) || (this.menu?.stateIcon))), this.style?.stateContainer)
            })
        }
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height(this.style?.rootContainer?.size?.height as Length)
        .width(this.style?.rootContainer?.size?.width as Length)
        .constraintSize(this.style?.rootContainer?.constraintSize)
        .padding(this.style?.rootContainer?.padding ?? 0) // 空值检测默认值为0
        .margin(this.style?.rootContainer?.margin ?? 0) // 空值检测默认值为0
        .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0) // 空值检测默认值为0
        .clip(this.style?.rootContainer?.clip)
        .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
        .onAppear(() => {
          this.reset();
        })
        .onDisAppear(() => {
          this.reset();
        })
        .onClick(() => {
          this.menu.menuType === MenuType.NAVIGATOR_ENTRY ?
          this.onEntryClickNavigator() : this.onEntryClickNavigation();
        })
        .stateStyles({
          normal: this.normalStateIconStyles,
          pressed: this.pressedStyles,
        })
      }
      .width('100%')
      .backgroundColor(this.uiRefresher.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
      .borderRadius($r('app.float.wh_value_12'));
    }
    .padding({
      left: $r('app.float.padding_4'),
      right: $r('app.float.padding_4'),
    })
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  private onEntryClickNavigator(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  replaceName(key: string, params: PushParam | null): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.replacePathByName(key, params);
    });
  }

  clear() {
    this.pathInfos?.clear();
  }

  private onEntryClickNavigation(): void {
    if (this.menu?.key === NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY &&
    this.pathInfos?.getAllPathName() && this.pathInfos?.getAllPathName().indexOf(NavEntryKey
      .PHONE_NOTIFICATION_SETTINGS_ENTRY) >= 0) {
      this.clear();
      this.replaceName(this.menu?.key as string, null);
    } else {
      LogUtil.info(`${this.tag} onEntryClick this.menu.key : ${this.menu.key}`);
      this.clear();
      LogUtil.info(`${this.tag} onEntryClick navstack pushName : ${this.menu.key}`);
      this.pushName(this.menu?.key as string, null);
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.secondIsHover || this.isSecondSelected) {
      return $r('app.color.color_default_white');
    }
    if (this.isSelected) {
      if ((display.isFoldable() || DeviceUtil.isDevicePad()) && this.pathInfos?.getAllPathName()[0] === this.menu.key) {
        return $r('app.color.color_pressed_click');
      }
      return $r('app.color.color_default_white');
    }
    if ((this.navigationMode === NavigationMode.Split) && this.showSelectedBackColor &&
      (this.pathInfos?.getAllPathName()[0] === this.menu.key ||
        (!this.pathInfos?.size() && this.menu.key === this.defaultEntryKey)
      )) {
      return $r('app.color.color_pressed_click');
    }
    if (this.menu.key === NavEntryKey.USER_SETTING_ENTRY &&
      (this.pathInfos?.getAllPathName()[0] === NavEntryKey.ADMIN_USER_ENTRY)) {
      return $r('app.color.color_pressed_click');
    }
    if (this.isHover && DeviceUtil.isDevicePc()) {
      return $r('app.color.color_0D000000_grey');
    }
    return $r('app.color.color_default_white');
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private getSpace(isVisible: boolean, style?: ContainerStyle): Length {
    if (!isVisible) {
      return 0; // 默认值为0
    }
    if (style?.margin?.left !== null && style?.margin?.left !== undefined) {
      return style?.margin?.left;
    }
    return this.style?.rootContainer?.space ?? 0; // 空值检测默认值为0
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu) || (this.controller ? true : false);
  }
}

@Reusable
@Component
export struct TimeZoneReusableEntryComponent {
  tag: string = 'TimeZoneReusableEntryComponent : ';
  @State menu: EntryMenu | null = null;
  style?: DefaultEntryMenuStyle;
  controller?: MenuController;
  @State uiRefresher: UiRefresher | null = null;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State showSelectedBackColor: boolean = true;
  @State showTitle: string = '';
  @State showSummary: string = '';

  private getNormalColor(): ResourceColor{
    LogUtil.info(`${TAG} getNormalColor`);
    if (this.isHover) {
      return $r('sys.color.interactive_hover');
    }
    return Color.Transparent;
  }

  private getNormalBorderRadius(): Length | number {
    LogUtil.info(`${TAG} getNormalBorderRadius`);
    if (this.isHover) {
      return $r('sys.float.corner_radius_level8');
    }
    return 0;
  }

  @Styles
  normalStateIconStyles() {
    .backgroundColor(this.getNormalColor())
    .borderRadius(this.getNormalBorderRadius())
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor(null)
    .borderRadius('8vp')
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor((DeviceUtil.isDevicePhone() ||
    DeviceUtil.isDevicePad()) ? $r('sys.color.ohos_id_color_click_effect') : null)
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  build() {
    Column() {
      Text(this.showTitle)
        .visibility((this.menu?.title) ? Visibility.Visible : Visibility.None)
        .textStyle(this.style?.title)
        .margin({ bottom: $r('app.float.width_2') })

      Text(this.showSummary)
        .visibility((this.menu?.summary) || this.style?.summary?.visible ? Visibility.Visible : Visibility.None)
        .textStyle(this.style?.summary)
    }
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS_5 })
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding({
      top: this.style?.rootContainer?.padding?.top,
      bottom: this.style?.rootContainer?.padding?.bottom,
      left: $r('app.float.padding_8'),
      right: $r('app.float.padding_8')
    })
    .borderRadius($r('app.float.padding_16'))
    .onTouch((event?: TouchEvent): void => {
      if (event) {
        this.onTouchEvent(event);
      }
    })
    .margin(this.style?.rootContainer?.margin ?? 0)
    .onHover((isHover?) => {
      isHover = isHover ? true : false;
      this.isHover = this.updateHover(isHover);
      this.controller?.handleHoverEvent(isHover);
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        this.onMouseEvent(event);
      }
    })
    .backgroundColor(this.uiRefresher?.refreshId ? this.getBackgroundColor() : this.getBackgroundColor())
    .onAppear(() => {
      this.reset();
    })
    .onDisAppear(() => {
      this.reset();
    })
    .onClick(() => {
      this.onClickPressed();
    })
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStateIconStyles,
    })
    .visibility(this.uiRefresher?.refreshId && this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToReuse(params: Record<string, Object>) {
    this.showTitle = params.showTitle as string;
    this.showSummary = params.showSummary as string;
    this.controller = params.controller as MenuController;
  }

  onClickPressed(): void {
    this.isSelected = true;
    this.onEntryClick();
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu?.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private onTouchEvent(event: TouchEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
  }

  private getBackgroundColor(): ResourceColor {
    if ((DeviceUtil.isDevicePhone() || DeviceUtil.isDevicePad()) && this.isSelected) {
      return $r('app.color.color_default_white');
    }

    if (this.showSelectedBackColor) {
      if (this.isSelected) {
        return $r('app.color.color_1A000000_grey');
      }
    }
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return $r('app.color.color_default_white');
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu);
  }
}

@Reusable
@Component
export struct AppListReusableEntryComponent {
  tag: string = 'AppListReusableEntryComponent : ';
  style: AppStyle | null = null;
  controller: MenuController | null = null;
  @State menu: SettingsBaseMenu | null = null;
  @State uiRefresher: UiRefresher | null = null;
  @State isSelected: boolean = false;
  @State isHover: boolean = false;
  @State secondIsHover: boolean = false;
  @State isSecondSelected: boolean | null = null;
  @State showSelectedBackColor: boolean = true;
  @State pathInfos: NavPathStack | null = null;
  @State showIcon: Resource | null = null;
  @State showTitle: Resource | null = null;
  @State showSummary: Resource | null = null;
  @State showStateIcon: Resource | null = null;

  @Styles
  normalStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedStateIconStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius('8vp')
  }

  @Styles
  normalSecondStateIconStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius(0)
  }

  @Styles
  pressedSecondStateIconStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius('8vp')
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Image(this.showIcon)
        .visibility(Visibility.Visible)
        .imageStyle(this.style?.iconImage)
        .flexGrow(0)
        .flexShrink(0)
        .align(Alignment.Start)
        .id(`entry_image_${this.menu?.key}`)
        .autoResize(false)
        .interpolation(ImageInterpolation.Medium)
      Column() {
        Text(this.showTitle)
          .visibility(Visibility.Visible)
          .textStyle(this.style?.title)
        Text(this.showSummary as Resource)
          .visibility(Visibility.Visible)
          .textStyle(this.style?.summary)
      }
      .alignItems(HorizontalAlign.Start)
      .flexGrow(1)
      .flexShrink(this.style?.startFlexShrink ?? 0)
      .justifyContent(FlexAlign.Start)

      Image(this.showStateIcon)
        .hoverEffect(HoverEffect.Highlight)
        .id(`entry_image_${this.menu?.key}`)
        .stateStyles({
          normal: this.normalStateIconStyles,
          pressed: this.pressedStateIconStyles,
        })
        .visibility(Visibility.Visible)
        .imageStyle(this.style?.stateIcon)
        .visibility(Visibility.Visible)
        .flexShrink(this.style?.endFlexShrink ?? 0)
    }
    .height(this.style?.rootContainer?.size?.height as Length)
    .width(this.style?.rootContainer?.size?.width as Length)
    .constraintSize(this.style?.rootContainer?.constraintSize)
    .padding(this.style?.rootContainer?.padding ?? 0)
    .margin(this.style?.rootContainer?.margin ?? 0)
    .layoutWeight(this.style?.rootContainer?.layoutWeight ?? 0)
    .clip(this.style?.rootContainer?.clip)
    .borderRadius(this.style?.rootContainer?.borderRadius as Length)
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
    .stateStyles({
      normal: this.normalStateIconStyles,
      pressed: this.pressedStateIconStyles,
    })
    .onMouse((event?: MouseEvent): void => {
      if (event) {
        this.onMouseEvent(event);
      }
    })
    .onAppear(() => {
      this.reset();
    })
    .onDisAppear(() => {
      this.reset();
    })
    .onClick(() => {
      this.onEntryClick();
    })
  }

  private onEntryClick(): void {
    LogUtil.info(`${this.tag} onEntryClick`);
    if (this.controller && this.controller.onMenuClick()) {
      return;
    }
    if (this.menu?.targetPageUrl) {
      let message: string = `pageUrl: ${this.menu.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      Router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  aboutToReuse(params: Record<string, Object>): void {
    this.showIcon = params.showIcon as Resource;
    this.showTitle = params.showTitle as Resource;
    this.showSummary = params.showSummary as Resource;
    this.showStateIcon = params.showStateIcon as Resource;
    this.controller = params.controller as MenuController;
  }

  private onMouseEvent(event: MouseEvent): void {
    if (!this.isRespondTouchEvent()) {
      return;
    }
    if (event.button === MouseButton.Left && event.action === MouseAction.Press) {
      this.isSelected = true;
    } else if (event.button === MouseButton.Left && event.action === MouseAction.Release) {
      this.isSelected = false;
    }
  }

  private onTouchEvent(event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.isSelected = true;
    } else if (event.type === TouchType.Up) {
      this.isSelected = false;
    }
  }

  private reset(): void {
    this.isSelected = false;
    this.isHover = false;
    this.isSecondSelected = false;
    this.secondIsHover = false;
  }

  private updateHover(isHover: boolean): boolean {
    if (!this.isRespondTouchEvent()) {
      return this.isHover;
    }
    return isHover;
  }

  private isRespondTouchEvent(): boolean {
    return this.menu == null || !(this.menu instanceof StateMenu);
  }
}

@Component
export struct NavTitleHeaderComponent {
  tag: string = 'NavTitleHeaderComponent : ';
  targetPageUrl: string = '';
  menuKey: string = '';
  isShowBack: boolean = true;
  isShowAbout: boolean = false;
  isStartAbility: boolean = false;
  showALL: boolean = true;
  style?: Style;
  @Link title: ResourceStr;
  @Link uiRefresher: UiRefresher;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('isFromSearch') isFromSearch: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      if (!(this.isFromSearch && this.navigationMode === NavigationMode.Split)) {
        backButton(this.isShowBack, () => this.onBackClick());
      }

      Row() {
        Text(this.uiRefresher.refreshId ? this.title : this.title)
          .textStyle((this.style as DefaultNavPageHeaderStyle)?.title)
          .fontSize((this.style as DefaultNavPageHeaderStyle)?.title?.font?.size as Length)
          .fontWeight((this.style as DefaultNavPageHeaderStyle)?.title?.font?.weight)
      }
      .flexGrow(1)
      .flexShrink((this.style as NavigationEntryMenuStyle)?.endFlexShrink ?? 1)
      .align(Alignment.Start)

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_about'))
          .width('24vp')
          .height('24vp')
          .id('about_icon_' + this.menuKey)
          .margin({ right: '12vp' })
          .draggable(false);
      }
      .width('48vp')
      .height('48vp')
      .hoverEffect(HoverEffect.Highlight)
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .margin({ left: '4vp' })
      .flexShrink((this.style as NavigationEntryMenuStyle)?.endFlexShrink ?? 0)
      .align(Alignment.End)
      .visibility(this.isShowAbout ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        this.onAboutClick();
      });
    }
    .id('NavTitleHeaderComponent')
    .visibility(this.uiRefresher.isVisible() && this.showALL ? Visibility.Visible : Visibility.None)
    .width((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.size?.width as Length)
    .height((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.size?.height as Length)
    .padding((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.padding as Padding)
    .margin((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.margin as Padding)
    .constraintSize((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.constraintSize)
    .layoutWeight((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.layoutWeight as string | number)
    .clip((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.clip)
    .borderRadius((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.borderRadius as Length)
    .backgroundColor((this.style as DefaultNavPageHeaderStyle)?.rootContainer?.backgroundColor);
  }

  private onAboutClick(): void {
    if (this.targetPageUrl) {
      let message: string = `pageUrl: ${this.targetPageUrl}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(this.targetPageUrl, null);
    }
  }

  private startAbilityBack(): void {
    let want: Want = {
      bundleName: 'com.ohos.clock',
      abilityName: 'com.ohos.clock.phone',
      parameters: {
        cityId: ''
      },
    };
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want);
      return;
    }
    if ((AppStorage.get<boolean>('isPcWorldClock') as boolean)) {
      let options: StartOptions = {
        windowMode: DEFAULT_WINDOW_MODE,
      };
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want, options);
      return;
    }
    Router.back();
    return;
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  clear() {
    this.pathInfos?.clear();
  }

  pop() {
    this.pathInfos?.pop();
  }

  popTo(entry: string) {
    this.pathInfos?.popToName(entry);
  }

  private onBackClick(): void {
    LogUtil.info('onBackClick');
    WalletManageUtils.sendAbilityResultToWallet(-1);
    if (this.isStartAbility) {
      this.startAbilityBack();
    } else {
      let backEntry: string = AppStorage.Get(BACK_ENTRY) as string;
      if (backEntry) {
        AppStorage.SetOrCreate(BACK_ENTRY, '');
        if (this.pathInfos?.getAllPathName().indexOf(backEntry) !== INDEX_NOT_FOUNT) {
          this.popTo(backEntry);
        } else {
          this.clear();
          this.pushName(backEntry, null);
        }
      } else {
        LogUtil.info('NavHeaderCompenent onBackClick');
        this.pop();
      }
      AbilityUtils.closeUiExtension(AppStorage.get<UIExtensionContentSession>('uiExtensionContentSession'), -1);
    }
  }
}