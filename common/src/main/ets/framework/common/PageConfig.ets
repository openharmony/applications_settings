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

import { PADDING_0, PADDING_12, PADDING_16 } from '../../constant/StyleConstant';
import {
  GroupDividerStyle,
  SettingContentModel,
  SettingContentTextStyle,
  SettingGroupLayout,
  SettingGroupModel
} from '../model/SettingGroupModel';
import {
  DialogButton,
  DialogButtonStyle,
  DialogLayoutStyle,
  SettingCheckboxModel,
  SettingCheckboxStyle,
  SettingDialogModel,
  SettingIconModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemLayout,
  SettingItemModel,
  SettingMenuStyle,
  SettingRadioModel,
  SettingRadioStyle,
  SettingTextModel,
  SettingTextStyle,
  SettingTextType,
} from '../model/SettingItemModel';
import { PageType, SettingPageLayout, SettingPageModel } from '../model/SettingPageModel';

const TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS: string = '';

export interface PageConfigIf {
  getDefaultPageLayout?: (isHomePage: boolean) => SettingPageLayout;
  getDefaultPageHeaderStyle?: () => SettingContentTextStyle;

  getDefaultGroupLayout?: (isHomePage?: boolean) => SettingGroupLayout;
  getDefaultGroupHeaderStyle?: () => SettingContentTextStyle;
  getDefaultGroupFooterStyle?: () => SettingContentTextStyle;

  getDefaultItemLayout?: (item: SettingItemModel, homeComp?: boolean) => SettingItemLayout;
  getItemMinHeight?: (item: SettingItemModel, hasDesp: boolean) => Length;
  getDefaultTextStyle?: (textType?: SettingTextType) => SettingTextStyle;
  getDefaultIconStyle?: (iconType?: SettingIconType) => SettingIconStyle;
  getDefaultRadioStyle?: () => SettingRadioStyle;
  getDefaultCheckboxStyle?: () => SettingCheckboxStyle;

  getDefaultDialogStyle?: (dialog: SettingDialogModel) => DialogLayoutStyle;
  getDefaultDialogButtonStyle?: () => DialogButtonStyle;

  getDefaultMenuStyle?: () => SettingMenuStyle;
  getAccessibilityDescription?: (item: SettingItemModel, state: boolean, checked: boolean, selected: boolean,
    enabledState: boolean) => string;
}

export enum ScreenType {
  SCREEN_TYPE_SMALL,
  SCREEN_TYPE_MIDDLE,
  SCREEN_TYPE_BIG,
  SCREEN_TYPE_HUGE,
  SCREEN_TYPE_CIRCLE,
}

export interface SettingPageConfigGlobal {
  defaultPageConfig: PageConfigIf;
  defaultPageBuilder: WrappedBuilder<[object]>;
  navMode: NavigationMode,
  screenType: ScreenType,
}

export class PageConfig {
  private static pageConfigInstance: PageConfig;

  private pageConfigGlobal: SettingPageConfigGlobal = {
    defaultPageConfig: {},
    defaultPageBuilder: new WrappedBuilder(() => {}),
    navMode: NavigationMode.Auto,
    screenType: ScreenType.SCREEN_TYPE_SMALL,
  }

  private constructor() {
  }

  public static getInstance(): PageConfig {
    if (!PageConfig.pageConfigInstance) {
      PageConfig.pageConfigInstance = new PageConfig();
    }
    return PageConfig.pageConfigInstance;
  }

  public setPageConfigGlobal(config: SettingPageConfigGlobal): void {
    this.pageConfigGlobal.defaultPageConfig = config.defaultPageConfig;
    this.pageConfigGlobal.defaultPageBuilder = config.defaultPageBuilder;
    this.pageConfigGlobal.screenType = config.screenType;
    this.pageConfigGlobal.navMode = config.navMode;
  }

  public isSplitMode(): boolean {
    return (this.pageConfigGlobal.navMode === NavigationMode.Split);
  }

  public isCircleScreen(): boolean {
    return (this.pageConfigGlobal.screenType === ScreenType.SCREEN_TYPE_CIRCLE);
  }

  public getDefaultPageBuilder(): WrappedBuilder<[object]> {
    return this.pageConfigGlobal.defaultPageBuilder;
  }

  public getPageLayout(page: SettingPageModel): SettingPageLayout {
    let userCfg = page.layout;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultPageLayout?.(
      page.type === PageType.PAGE_TYPE_HOME
    );
    return {
      backgroundColor: userCfg?.backgroundColor ?? defaultCfg?.backgroundColor,
      padding: {
        start: userCfg?.padding?.start ?? defaultCfg?.padding?.start,
        end: userCfg?.padding?.end ?? defaultCfg?.padding?.end,
        top: userCfg?.padding?.top ?? defaultCfg?.padding?.top,
        bottom: userCfg?.padding?.bottom ?? defaultCfg?.padding?.bottom,
      },
      barState: userCfg?.barState ?? defaultCfg?.barState,
      hideTitleBar: userCfg?.hideTitleBar ?? defaultCfg?.hideTitleBar,
    };
  }

  // 计算group外间距，以top算；有header时为0，构造看上一个group情况，如果上一个group有footer则为16，否则为12
  private getGroupMarginTop(group?: SettingGroupModel, previousGroup?: SettingGroupModel): LengthMetrics | undefined {
    if (group?.header) {
      return PADDING_0;
    } else {
      return previousGroup ? (previousGroup.footer && previousGroup.footer.visible === true ? PADDING_16 : PADDING_12) :
        this.pageConfigGlobal.defaultPageConfig.getDefaultGroupLayout?.().margin?.top;
    }
  }

  public getGroupLayout(group?: SettingGroupModel, previousGroup?: SettingGroupModel,
    homeComp?: boolean): SettingGroupLayout {
    let userCfg = group?.layout;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultGroupLayout?.(homeComp);
    return {
      backgroupColor: userCfg?.backgroupColor ?? defaultCfg?.backgroupColor,
      borderRadius: userCfg?.borderRadius ?? defaultCfg?.borderRadius,
      padding: {
        top: userCfg?.padding?.top ?? defaultCfg?.padding?.top,
        bottom: userCfg?.padding?.bottom ?? defaultCfg?.padding?.bottom,
        start: userCfg?.padding?.start ?? defaultCfg?.padding?.start,
        end: userCfg?.padding?.end ?? defaultCfg?.padding?.end,
      },
      margin: {
        top: userCfg?.margin?.top ? userCfg?.margin?.top : this.getGroupMarginTop(group, previousGroup),
        bottom: userCfg?.margin?.bottom ? userCfg?.margin?.bottom : PADDING_0,
      },
      dividerStyle: userCfg?.dividerStyle ?? defaultCfg?.dividerStyle,
    };
  }


  public getItemLayout(item: SettingItemModel, homeComp: boolean = false): SettingItemLayout {
    let userCfg = item.layout;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultItemLayout?.(item, homeComp);
    return {
      background: {
        normalBackgroundColor: userCfg?.background?.normalBackgroundColor ??
          defaultCfg?.background?.normalBackgroundColor,
        pressedBackgroundColor: userCfg?.background?.pressedBackgroundColor ??
          defaultCfg?.background?.pressedBackgroundColor
      },
      minHeight: userCfg?.minHeight ?? defaultCfg?.minHeight,
      borderRadius: userCfg?.borderRadius ?? defaultCfg?.borderRadius,
      innerLeftSpace: userCfg?.innerLeftSpace ?? defaultCfg?.innerLeftSpace,
      innerRightSpace: userCfg?.innerRightSpace ?? defaultCfg?.innerRightSpace,
      leftMiddleSpace: userCfg?.leftMiddleSpace ?? defaultCfg?.leftMiddleSpace,
      rightMiddleSpace: userCfg?.rightMiddleSpace ?? defaultCfg?.rightMiddleSpace,
      middleRowSpace: userCfg?.middleRowSpace ?? defaultCfg?.middleRowSpace,
      middleColumnSpace: userCfg?.middleColumnSpace ?? defaultCfg?.middleColumnSpace,
      safetyPadding: userCfg?.safetyPadding ?? defaultCfg?.safetyPadding,
      noNeedDivider: userCfg?.noNeedDivider ?? defaultCfg?.noNeedDivider,
    };
  }

  public getItemMinHeigth(item: SettingItemModel, hasDesp: boolean): Length {
    return (item.layout?.minHeight ?? this.pageConfigGlobal.defaultPageConfig.getItemMinHeight?.(item, hasDesp)) ?? 0;
  }

  public getIconStyle(icon?: SettingIconModel): SettingIconStyle {
    let userCfg = icon?.style;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultIconStyle?.(icon?.iconType);
    return {
      width: userCfg?.width ?? (defaultCfg?.width ?? 0),
      height: userCfg?.height ?? (defaultCfg?.height ?? 0),
      objectFit: userCfg?.objectFit ?? ImageFit.Contain,
      borderRadius: userCfg?.borderRadius ?? defaultCfg?.borderRadius,
      draggable: userCfg?.draggable ?? false,
      mirrored: userCfg?.mirrored ?? (defaultCfg?.mirrored ?? true),
      fillColor: userCfg?.fillColor ?? defaultCfg?.fillColor,
      interpolation: userCfg?.interpolation ?? defaultCfg?.interpolation,
      edgeAntialiasing: userCfg?.edgeAntialiasing ?? defaultCfg?.edgeAntialiasing,
      border: userCfg?.border ?? defaultCfg?.border,
      clip: userCfg?.clip ?? defaultCfg?.clip,
      renderingStrategy: userCfg?.renderingStrategy ?? SymbolRenderingStrategy.MULTIPLE_OPACITY,
      accessibilityText: userCfg?.accessibilityText ?? defaultCfg?.accessibilityText,
      accessibilityLevel: userCfg?.accessibilityLevel ?? defaultCfg?.accessibilityLevel,
      builder: icon?.builder,
      opacity: userCfg?.opacity,
      fontWeight: userCfg?.fontWeight
    };
  }

  public getTextStyle(text?: SettingTextModel): SettingTextStyle {
    let userCfg = text?.style;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultTextStyle?.(text?.textType);
    return {
      fontSize: userCfg?.fontSize ?? defaultCfg?.fontSize,
      fontColor: userCfg?.fontColor ?? defaultCfg?.fontColor,
      fontWeight: userCfg?.fontWeight ?? defaultCfg?.fontWeight,
      fontFamily: userCfg?.fontFamily ?? defaultCfg?.fontFamily,
      textAlign: userCfg?.textAlign ?? defaultCfg?.textAlign,
      maxLines: userCfg?.maxLines ?? defaultCfg?.maxLines,
      textOverflow: userCfg?.textOverflow ?? defaultCfg?.textOverflow,
      minFontSize: userCfg?.minFontSize ?? defaultCfg?.minFontSize,
      maxFontSize: userCfg?.maxFontSize ?? defaultCfg?.maxFontSize,
      wordBreak: userCfg?.wordBreak ?? defaultCfg?.wordBreak,
      lineHeight: userCfg?.lineHeight ?? defaultCfg?.lineHeight,
      opacity: userCfg?.opacity ?? defaultCfg?.opacity,
      direction: userCfg?.direction ?? (defaultCfg?.direction ?? Direction.Auto),
      copyOption: userCfg?.copyOption ?? defaultCfg?.copyOption,
    };
  }

  public getDialogStyle(dialog: SettingDialogModel): DialogLayoutStyle {
    let userCfg = dialog.style;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultDialogStyle?.(dialog);
    return {
      width: userCfg?.width ?? defaultCfg?.width,
      height: userCfg?.height ?? defaultCfg?.height,
      backgroundColor: userCfg?.backgroundColor ?? defaultCfg?.backgroundColor,
      cornerRadius: userCfg?.cornerRadius ?? defaultCfg?.cornerRadius,
      autoCancel: userCfg?.autoCancel !== undefined ? userCfg.autoCancel : defaultCfg?.autoCancel,
      maskColor: userCfg?.maskColor ?? defaultCfg?.maskColor,
      alignment: userCfg?.alignment ?? defaultCfg?.alignment,
      padding: {
        top: userCfg?.padding?.top ?? defaultCfg?.padding?.top,
        bottom: userCfg?.padding?.bottom ?? defaultCfg?.padding?.bottom,
        start: userCfg?.padding?.start ?? defaultCfg?.padding?.start,
        end: userCfg?.padding?.end ?? defaultCfg?.padding?.end,
      },
      contentButtonSpace: userCfg?.contentButtonSpace ?? defaultCfg?.contentButtonSpace,
      titleHeight: userCfg?.titleHeight ?? defaultCfg?.titleHeight,
      buttonPad: userCfg?.buttonPad ?? defaultCfg?.buttonPad,
      buttonSpaceHorizontal: userCfg?.buttonSpaceHorizontal ?? defaultCfg?.buttonSpaceHorizontal,
      buttonSpaceVertical: userCfg?.buttonSpaceVertical ?? defaultCfg?.buttonSpaceVertical,
      titleStyle: {
        textAlign: userCfg?.titleStyle?.textAlign ?? defaultCfg?.titleStyle?.textAlign,
      },
      contentStyle: {
        textAlign: userCfg?.contentStyle?.textAlign ?? defaultCfg?.contentStyle?.textAlign,
      }
    };
  }

  public getDialogButtonStyle(dialogButton: DialogButton): DialogButtonStyle {
    let userCfg = dialogButton.style;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultDialogButtonStyle?.();
    return {
      type: userCfg?.type ?? defaultCfg?.type,
      borderRadius: userCfg?.borderRadius ?? defaultCfg?.borderRadius,
      height: userCfg?.height ?? defaultCfg?.background,
      width: userCfg?.width ?? defaultCfg?.width,
      alignSelf: userCfg?.alignSelf ?? defaultCfg?.alignSelf,
      constraintSize: userCfg?.constraintSize ?? defaultCfg?.constraintSize,
      padding: userCfg?.padding ?? defaultCfg?.padding,
      background: userCfg?.background ?? defaultCfg?.background,
      fontColor: userCfg?.fontColor ?? defaultCfg?.fontColor,
      buttonStyle: userCfg?.buttonStyle ?? defaultCfg?.buttonStyle,
      role: userCfg?.role ?? defaultCfg?.role,
    };
  }

  private getContentTextStyle(userCfg?: SettingContentTextStyle,
    defaultCfg?: SettingContentTextStyle): SettingContentTextStyle {
    return {
      height: userCfg?.height ?? defaultCfg?.height,
      textAlign: userCfg?.textAlign ?? defaultCfg?.textAlign,
      justifyContent: userCfg?.justifyContent ?? defaultCfg?.justifyContent,
      padding: userCfg?.padding ?? defaultCfg?.padding,
      fontSize: userCfg?.fontSize ?? defaultCfg?.fontSize,
      fontColor: userCfg?.fontColor ?? defaultCfg?.fontColor,
      fontWeight: userCfg?.fontWeight ?? defaultCfg?.fontWeight,
      opacity: userCfg?.opacity ?? defaultCfg?.opacity,
      lineHeight: userCfg?.lineHeight ?? defaultCfg?.lineHeight,
    };
  }

  public getGroupHeaderStyle(header?: SettingContentModel): SettingContentTextStyle {
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultGroupHeaderStyle?.();
    return this.getContentTextStyle(header?.style, defaultCfg);
  }

  public getGroupFooterStyle(footer?: SettingContentModel): SettingContentTextStyle {
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultGroupFooterStyle?.();
    return this.getContentTextStyle(footer?.style, defaultCfg);
  }

  public getGroupDividerStyle(userDividerStyle?: GroupDividerStyle): DividerStyle | undefined {
    if (!userDividerStyle) {
      return undefined;
    }
    return {
      strokeWidth: userDividerStyle.strokeWidth ?? px2vp(2),
      color: userDividerStyle.color ?? $r('sys.color.comp_divider'),
      startMargin: userDividerStyle.startMargin ?? 8,
      endMargin: userDividerStyle.endMargin ?? 8
    };
  }

  public getPageHeaderStyle(header?: SettingContentModel): SettingContentTextStyle {
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultPageHeaderStyle?.();
    return this.getContentTextStyle(header?.style, defaultCfg);
  }

  public getRadioStyle(radio?: SettingRadioModel): SettingRadioStyle {
    let userCfg = radio?.style;
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultRadioStyle?.();
    return {
      width: userCfg?.width ?? defaultCfg?.width,
      height: userCfg?.height ?? defaultCfg?.height,
      indicatorType: userCfg?.indicatorType ?? defaultCfg?.indicatorType,
      radioStyle: {
        checkedBackgroundColor: userCfg?.radioStyle?.checkedBackgroundColor ??
          defaultCfg?.radioStyle?.checkedBackgroundColor,
        uncheckedBorderColor: userCfg?.radioStyle?.uncheckedBorderColor ?? defaultCfg?.radioStyle?.uncheckedBorderColor,
        indicatorColor: userCfg?.radioStyle?.indicatorColor ?? defaultCfg?.radioStyle?.indicatorColor
      },
      showUnchecked: userCfg?.showUnchecked !== undefined ? userCfg?.showUnchecked : defaultCfg?.showUnchecked
    };
  }

  public getCheckboxStyle(checkbox?: SettingCheckboxModel): SettingCheckboxStyle {
    let userCfg = checkbox?.style;
    let defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultCheckboxStyle?.();
    return {
      width: userCfg?.width ?? defaultCfg?.width,
      height: userCfg?.height ?? defaultCfg?.height,
      selectedColor: userCfg?.selectedColor ?? defaultCfg?.selectedColor,
      unselectedColor: userCfg?.unselectedColor ?? defaultCfg?.unselectedColor,
      mark: userCfg?.mark ?? defaultCfg?.mark,
      shape: userCfg?.shape ?? defaultCfg?.shape,
      showUnSelected: userCfg?.showUnSelected !== undefined ? userCfg?.showUnSelected : defaultCfg?.showUnSelected,
    };
  }

  public getMenuStyle(userCfg?: SettingMenuStyle): SettingMenuStyle {
    const defaultCfg = this.pageConfigGlobal.defaultPageConfig.getDefaultMenuStyle?.();
    return {
      width: userCfg?.width ?? defaultCfg?.width,
      itemHeight: userCfg?.itemHeight ?? defaultCfg?.itemHeight,
      itemPadding: {
        start: userCfg?.itemPadding?.start ?? defaultCfg?.itemPadding?.start,
        end: userCfg?.itemPadding?.end ?? defaultCfg?.itemPadding?.end,
        top: userCfg?.itemPadding?.top ?? defaultCfg?.itemPadding?.top,
        bottom: userCfg?.itemPadding?.bottom ?? defaultCfg?.itemPadding?.bottom,
      },
      padding: {
        start: userCfg?.padding?.start ?? defaultCfg?.padding?.start,
        end: userCfg?.padding?.end ?? defaultCfg?.padding?.end,
        top: userCfg?.padding?.top ?? defaultCfg?.padding?.top,
        bottom: userCfg?.padding?.bottom ?? defaultCfg?.padding?.bottom,
      },
      borderRadius: userCfg?.borderRadius ?? defaultCfg?.borderRadius,
      backgroundColor: userCfg?.backgroundColor ?? defaultCfg?.backgroundColor,
    };
  }

  public getAccessibilityDescription(item: SettingItemModel, state: boolean, checked: boolean,
    selected: boolean, enabledState: boolean): string {
    return this.pageConfigGlobal.defaultPageConfig.getAccessibilityDescription?.(item, state, checked, selected,
      enabledState) ??
      TALKBACK_SUPPORT_DEFAULT_CLICK_TIPS;
  }
}