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

import {
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_2,
  PADDING_20,
  PADDING_24,
  PADDING_4,
  PADDING_8
} from '../../constant/StyleConstant';
import { SettingContentTextStyle, SettingGroupLayout } from '../model/SettingGroupModel';
import {
  DialogButtonStyle,
  DialogLayoutStyle,
  ItemResultType,
  SettingDialogModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemLayout,
  SettingItemModel,
  SettingMenuStyle,
  SettingTextStyle,
  SettingTextType
} from '../model/SettingItemModel';
import { SettingPageLayout } from '../model/SettingPageModel';
import { PageConfigIf } from './PageConfig';

export class PcPageConfig implements PageConfigIf {
  private static instance: PcPageConfig;
  private static readonly DEFAULT_PAGE_LAYOUT: SettingPageLayout = {
    backgroundColor: $r('sys.color.background_secondary'),
    padding: {
      start: PADDING_24,
      end: PADDING_24,
      top: PADDING_8,
      bottom: PADDING_20
    },
  };
  private static readonly DEFAULT_PAGE_HEADER_STYLE: SettingContentTextStyle = {
    padding: { start: PADDING_12, end: PADDING_12, top: PADDING_8 },
    fontSize: $r('sys.float.Body_M'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Regular,
  };
  private static readonly DEFAULT_GROUP_LAYOUT: SettingGroupLayout = {
    backgroupColor: $r('sys.color.ohos_id_color_list_card_bg'),
    borderRadius: $r('sys.float.corner_radius_level8'),
    padding: { top: PADDING_4, bottom: PADDING_4, start: PADDING_4, end: PADDING_4 },
    margin: { top: PADDING_0 },
  };
  private static readonly DEFAULT_GROUP_HEADER_STYLE: SettingContentTextStyle = {
    height: 40,
    textAlign: TextAlign.Start,
    justifyContent: FlexAlign.End,
    padding: { start: PADDING_12, end: PADDING_12, bottom: PADDING_8 },
    fontSize: $r('sys.float.Body_M'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Medium,
  };
  private static readonly DEFAULT_GROUP_FOOTER_STYLE: SettingContentTextStyle = {
    textAlign: TextAlign.Start,
    padding: { start: PADDING_12, end: PADDING_12, top: PADDING_8 },
    fontSize: $r('sys.float.Body_S'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Regular,
  };
  private static readonly DEFAULT_ITEM_LAYOUT: SettingItemLayout = {
    background: {
      normalBackgroundColor: Color.Transparent,
      pressedBackgroundColor: $r('sys.color.interactive_pressed'),
    },
    minHeight: 40,
    borderRadius: $r('sys.float.corner_radius_level6'),
    innerLeftSpace: PADDING_8,
    innerRightSpace: PADDING_8,
    leftMiddleSpace: PADDING_16,
    rightMiddleSpace: PADDING_4,
    middleRowSpace: PADDING_16,
    middleColumnSpace: PADDING_2,
    safetyPadding: PADDING_8,
  };
  private static readonly DEFAULT_ICON_STYLE: SettingIconStyle[] = [
    {
      width: 32,
      height: 32,
    },
    {
      width: 32,
      height: 32,
      borderRadius: $r('sys.float.corner_radius_level6'),
      interpolation: ImageInterpolation.Medium,
    },
    {
      width: 48,
      height: 48,
      borderRadius: $r('sys.float.corner_radius_level6'),
      interpolation: ImageInterpolation.Medium,
      border: { width: '1px', color: '#3F808080' },
    },
    {
      width: 12,
      height: 24,
      fillColor: $r('sys.color.icon_fourth'),
    },
    {
      width: 24,
      height: 24,
      fillColor: $r('sys.color.icon_primary'),
    },
  ];
  private static readonly DEFAULT_TEXT_STYLE: SettingTextStyle[] = [
    {
      fontSize: $r('sys.float.Body_L'),
      fontColor: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
      textAlign: TextAlign.Start,
    },
    {
      fontSize: $r('sys.float.Body_L'),
      fontColor: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
      textAlign: TextAlign.Start,
    },
    {
      fontSize: $r('sys.float.Body_M'),
      fontColor: $r('sys.color.font_secondary'),
      fontWeight: FontWeight.Regular,
      textAlign: TextAlign.Start,
    },
    {
      fontSize: $r('sys.float.Body_S'),
      fontColor: $r('sys.color.font_secondary'),
      fontWeight: FontWeight.Regular,
      textAlign: TextAlign.Start,
    },
  ];
  private static readonly DEFAULT_DIALOG_STYLE: DialogLayoutStyle = {
    cornerRadius: { topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 16 },
    autoCancel: true,
    maskColor: '0x33000000',
    alignment: DialogAlignment.Center,
    padding: { start: PADDING_24, end: PADDING_24 },
    contentButtonSpace: PADDING_16,
    titleHeight: 56,
    buttonPad: PADDING_16,
    buttonSpaceHorizontal: PADDING_4,
    buttonSpaceVertical: 16,
    titleStyle: {
      textAlign: TextAlign.Center,
    }
  };
  private static readonly DEFAULT_DIALOG_BUTTON_STYLE: DialogButtonStyle = {
    height: 40,
    buttonStyle: ButtonStyleMode.NORMAL,
    role: ButtonRole.NORMAL,
    type: ButtonType.Normal,
    borderRadius: $r('sys.float.corner_radius_level4'),
  };
  private static readonly DEFAULT_MENU_STYLE: SettingMenuStyle = {
    width: 160,
    itemHeight: 40,
    padding: { start: PADDING_0, end: PADDING_0 },
    borderRadius: $r('sys.float.corner_radius_level4'),
  };

  private constructor() {
  }

  public static getInstance(): PcPageConfig {
    if (!PcPageConfig.instance) {
      PcPageConfig.instance = new PcPageConfig();
    }
    return PcPageConfig.instance;
  }

  public getDefaultPageLayout(isHomePage: boolean): SettingPageLayout {
    return {
      backgroundColor: PcPageConfig.DEFAULT_PAGE_LAYOUT.backgroundColor,
      padding: {
        start: PcPageConfig.DEFAULT_PAGE_LAYOUT.padding?.start,
        end: PcPageConfig.DEFAULT_PAGE_LAYOUT.padding?.end,
        top: isHomePage ? PADDING_8 : PcPageConfig.DEFAULT_PAGE_LAYOUT.padding?.top,
        bottom: PcPageConfig.DEFAULT_PAGE_LAYOUT.padding?.bottom
      },
    };
  }

  public getDefaultPageHeaderStyle(): SettingContentTextStyle {
    return PcPageConfig.DEFAULT_PAGE_HEADER_STYLE;
  }

  getDefaultGroupLayout(isHomePage?: boolean): SettingGroupLayout {
    return {
      backgroupColor: isHomePage ? '' : $r('sys.color.comp_background_list_card'),
      borderRadius: $r('sys.float.corner_radius_level8'),
      padding: {
        top: PADDING_4,
        bottom: PADDING_4,
        start: isHomePage ? PADDING_0 : PADDING_4,
        end: isHomePage ? PADDING_0 : PADDING_4
      },
      margin: { top: PADDING_0 },
    };
  }

  getDefaultGroupHeaderStyle(): SettingContentTextStyle {
    return PcPageConfig.DEFAULT_GROUP_HEADER_STYLE;
  }

  getDefaultGroupFooterStyle(): SettingContentTextStyle {
    return PcPageConfig.DEFAULT_GROUP_FOOTER_STYLE;
  }

  private getMinItemHeigth(item: SettingItemModel, hasDesp: boolean): Length {
    if (hasDesp) {
      // 双行时，右侧有图标高小于24，或者无图标，最小高度为64，有图标但高度大于24则为72 商务风有改动: 单行文本时最小高度为40，双行为56
      if (item.icon) {
        if ((item.icon.iconType && item.icon.iconType <= SettingIconType.ICON_TYPE_APPICON) ||
          (item.icon.style?.height && item.icon.style.height >= 24)) {
          return 56;
        }
      }
      return 56;
    } else {
      if (item.icon) {
        return item.icon.iconType === SettingIconType.ICON_TYPE_APPICON ? 64 : 40;
      }
      return 40;
    }
  }

  private getDefaultRightMiddleSpace(item: SettingItemModel, defaultSpace?: LengthMetrics): LengthMetrics | undefined {
    if (item.result && item.result.type === ItemResultType.RESULT_TYPE_IMAGE) {
      return PADDING_8;
    }
    return defaultSpace;
  }

  private getDefaultMiddleRowSpace(item: SettingItemModel, defaultSpace?: LengthMetrics): LengthMetrics | undefined {
    if (item.result && (item.result.type === ItemResultType.RESULT_TYPE_IMAGE ||
      item.result.type === ItemResultType.RESULT_TYPE_TOGGLE)) {
      return PADDING_8;
    }
    if (!item.result) {
      return undefined;
    }
    return defaultSpace;
  }

  getDefaultItemLayout(item: SettingItemModel, homeComp?: boolean): SettingItemLayout {
    return {
      background: {
        normalBackgroundColor: homeComp ? '' : PcPageConfig.DEFAULT_ITEM_LAYOUT.background?.normalBackgroundColor,
        pressedBackgroundColor: PcPageConfig.DEFAULT_ITEM_LAYOUT.background?.pressedBackgroundColor,
      },
      minHeight: homeComp ? 48 : this.getMinItemHeigth(item, (item.desc !== undefined && item.desc.content !== '')),
      borderRadius: homeComp ? $r('sys.float.corner_radius_level4') : PcPageConfig.DEFAULT_ITEM_LAYOUT.borderRadius,
      innerLeftSpace: PcPageConfig.DEFAULT_ITEM_LAYOUT.innerLeftSpace,
      innerRightSpace: PcPageConfig.DEFAULT_ITEM_LAYOUT.innerRightSpace,
      leftMiddleSpace:
        item.icon ? (homeComp ? PADDING_8 : PcPageConfig.DEFAULT_ITEM_LAYOUT.leftMiddleSpace) : PADDING_0,
      rightMiddleSpace: item.detail ? this.getDefaultRightMiddleSpace(item,
        PcPageConfig.DEFAULT_ITEM_LAYOUT.rightMiddleSpace) : PADDING_0,
      middleRowSpace: this.getDefaultMiddleRowSpace(item,
        PcPageConfig.DEFAULT_ITEM_LAYOUT.middleRowSpace),
      middleColumnSpace: PcPageConfig.DEFAULT_ITEM_LAYOUT.middleColumnSpace,
      safetyPadding: PcPageConfig.DEFAULT_ITEM_LAYOUT.safetyPadding,
      noNeedDivider: homeComp ? true : false,
    };
  }

  getItemMinHeight(item: SettingItemModel, hasDesp: boolean): Length {
    return this.getMinItemHeigth(item, hasDesp);
  }

  getDefaultTextStyle(textType?: SettingTextType): SettingTextStyle {
    let type = textType ?? 0;
    return PcPageConfig.DEFAULT_TEXT_STYLE[type];
  }

  getDefaultIconStyle(iconType?: SettingIconType): SettingIconStyle {
    let type = iconType ?? 0;
    return PcPageConfig.DEFAULT_ICON_STYLE[type];
  }

  getDefaultDialogStyle(dialog: SettingDialogModel): DialogLayoutStyle {
    return {
      cornerRadius: PcPageConfig.DEFAULT_DIALOG_STYLE.cornerRadius,
      autoCancel: PcPageConfig.DEFAULT_DIALOG_STYLE.autoCancel,
      maskColor: PcPageConfig.DEFAULT_DIALOG_STYLE.maskColor,
      alignment: PcPageConfig.DEFAULT_DIALOG_STYLE.alignment,
      padding: {
        top: PcPageConfig.DEFAULT_DIALOG_STYLE.padding?.top ?? (dialog.title ? PADDING_0 : PADDING_24),
        bottom: PcPageConfig.DEFAULT_DIALOG_STYLE.padding?.bottom ?? (dialog.buttons ? PADDING_16 : PADDING_24),
        start: PcPageConfig.DEFAULT_DIALOG_STYLE.padding?.start,
        end: PcPageConfig.DEFAULT_DIALOG_STYLE.padding?.end,
      },
      contentButtonSpace: PcPageConfig.DEFAULT_DIALOG_STYLE.contentButtonSpace,
      titleHeight: PcPageConfig.DEFAULT_DIALOG_STYLE.titleHeight,
      buttonPad: PcPageConfig.DEFAULT_DIALOG_STYLE.buttonPad,
      buttonSpaceHorizontal: PcPageConfig.DEFAULT_DIALOG_STYLE.buttonSpaceHorizontal,
      buttonSpaceVertical: PcPageConfig.DEFAULT_DIALOG_STYLE.buttonSpaceVertical,
      titleStyle: PcPageConfig.DEFAULT_DIALOG_STYLE.titleStyle,
    };
  }

  getDefaultDialogButtonStyle(): DialogButtonStyle {
    return PcPageConfig.DEFAULT_DIALOG_BUTTON_STYLE;
  }

  getDefaultMenuStyle(): SettingMenuStyle {
    return PcPageConfig.DEFAULT_MENU_STYLE;
  }
}