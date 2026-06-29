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
  PADDING_24,
  PADDING_3,
  PADDING_4,
  PADDING_8
} from '../../constant/StyleConstant';
import { DeviceUtil } from '../../utils/BaseUtils';
import { FontScaleUtils } from '../../utils/FontScaleUtils';
import { SettingContentTextStyle, SettingGroupLayout } from '../model/SettingGroupModel';
import {
  DialogButtonStyle,
  DialogLayoutStyle,
  ItemResultType,
  SettingCheckboxStyle,
  SettingDialogModel,
  SettingIconStyle,
  SettingIconType,
  SettingItemLayout,
  SettingItemModel,
  SettingMenuStyle,
  SettingRadioStyle,
  SettingSheetTitleStyle,
  SettingTextStyle,
  SettingTextType
} from '../model/SettingItemModel';
import { SettingPageLayout } from '../model/SettingPageModel';
import { PageConfigIf } from './PageConfig';

export class DefaultPageConfig implements PageConfigIf {
  private static instance: DefaultPageConfig;
  private static readonly DEFAULT_PAGE_LAYOUT: SettingPageLayout = {
    backgroundColor: $r('sys.color.ohos_id_color_sub_background'),
    padding: {
      start: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
      end: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
      top: PADDING_16,
      bottom: PADDING_16
    },
  };
  private static readonly DEFAULT_PAGE_HEADER_STYLE: SettingContentTextStyle = {
    padding: { start: PADDING_12, end: PADDING_12, top: PADDING_8 },
    fontSize: $r('sys.float.ohos_id_text_size_body2'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Regular,
  };
  private static readonly DEFAULT_GROUP_LAYOUT: SettingGroupLayout = {
    backgroupColor: $r('sys.color.comp_background_list_card'),
    borderRadius: $r('sys.float.corner_radius_level10'),
    padding: { top: PADDING_4, bottom: PADDING_4, start: PADDING_4, end: PADDING_4 },
    margin: { top: PADDING_0 },
  };
  private static readonly DEFAULT_GROUP_HEADER_STYLE: SettingContentTextStyle = {
    height: 56,
    textAlign: TextAlign.Start,
    justifyContent: FlexAlign.End,
    padding: { start: PADDING_12, end: PADDING_12, bottom: PADDING_8 },
    fontSize: $r('sys.float.ohos_id_text_size_body2'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Medium,
  };
  private static readonly DEFAULT_GROUP_FOOTER_STYLE: SettingContentTextStyle = {
    textAlign: TextAlign.Start,
    padding: { start: PADDING_12, end: PADDING_12, top: PADDING_8 },
    fontSize: $r('sys.float.ohos_id_text_size_body3'),
    fontColor: $r('sys.color.font_secondary'),
    fontWeight: FontWeight.Regular,
  };
  private static readonly DEFAULT_ITEM_LAYOUT: SettingItemLayout = {
    background: {
      pressedBackgroundColor: $r('sys.color.ohos_id_color_click_effect'),
    },
    minHeight: 48,
    borderRadius: $r('sys.float.corner_radius_level8'),
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
      mirrored: true
    },
    {
      width: 32,
      height: 32,
      borderRadius: $r('sys.float.corner_radius_level6'),
      interpolation: ImageInterpolation.Medium,
      mirrored: true
    },
    {
      width: 48,
      height: 48,
      borderRadius: $r('sys.float.corner_radius_level6'),
      interpolation: ImageInterpolation.Medium,
      border: { width: '1px', color: '#3F808080' },
      mirrored: false
    },
    {
      width: 12,
      height: 24,
      fillColor: $r('sys.color.icon_fourth'),
      mirrored: true
    },
    {
      width: 24,
      height: 24,
      fillColor: $r('sys.color.icon_primary'),
      mirrored: true
    },
  ];
  private static readonly DEFAULT_TEXT_STYLE: SettingTextStyle[] = [
    {
      fontSize: $r('sys.float.ohos_id_text_size_body1'),
      fontColor: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
      textAlign: TextAlign.Start,
      wordBreak: WordBreak.BREAK_WORD,
    },
    {
      fontSize: $r('sys.float.ohos_id_text_size_body1'),
      fontColor: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
      textAlign: TextAlign.Start,
      wordBreak: WordBreak.BREAK_WORD,
    },
    {
      fontSize: $r('sys.float.ohos_id_text_size_body2'),
      fontColor: $r('sys.color.font_secondary'),
      fontWeight: FontWeight.Regular,
      textAlign: TextAlign.Start,
      wordBreak: WordBreak.BREAK_WORD,
    },
    {
      fontSize: $r('sys.float.ohos_id_text_size_body3'),
      fontColor: $r('sys.color.font_secondary'),
      fontWeight: FontWeight.Regular,
      textAlign: TextAlign.Start,
      wordBreak: WordBreak.BREAK_WORD,
    },
  ];
  private static readonly DEFAULT_DIALOG_STYLE: DialogLayoutStyle = {
    cornerRadius: { topLeft: 32, topRight: 32, bottomLeft: 32, bottomRight: 32 },
    autoCancel: true,
    maskColor: '0x33000000',
    alignment: DialogAlignment.Center,
    padding: { start: PADDING_24, end: PADDING_24 },
    contentButtonSpace: PADDING_8,
    titleHeight: 56,
    buttonPad: PADDING_16,
    buttonSpaceHorizontal: PADDING_4,
    buttonSpaceVertical: 16,
    titleStyle: {
      textAlign: TextAlign.Center,
      maxLines: 2,
      minFontSize: '16'
    },
    contentStyle: {
      textAlign: TextAlign.Center
    }
  };
  private static readonly DEFAULT_DIALOG_BUTTON_STYLE: DialogButtonStyle = {
    height: 40,
    buttonStyle: ButtonStyleMode.TEXTUAL,
    role: ButtonRole.NORMAL,
  };
  private static readonly DEFAULT_RADIO_STYLE: SettingRadioStyle = {
    width: 24,
    height: 24,
    indicatorType: RadioIndicatorType.TICK,
    radioStyle: {
      checkedBackgroundColor: $r('sys.color.ohos_id_color_emphasize')
    },
    showUnchecked: false,
  };
  private static readonly DEFAULT_CHECKBOX_STYLE: SettingCheckboxStyle = {
    width: 24,
    height: 24,
    selectedColor: $r('sys.color.font_emphasize'),
    unselectedColor: $r('sys.color.icon_tertiary'),
    mark: {
      strokeColor : $r('sys.color.comp_background_primary_contrary'),
      strokeWidth: $r('sys.float.ohos_id_checkbox_stroke_width'),
      size: '20vp'
    },
    shape: CheckBoxShape.CIRCLE,
    /**
     * 未选中时是否展示checkbox
     */
    showUnSelected: true,
  }
  private static readonly DEFAULT_MENU_STYLE: SettingMenuStyle = {
    width: 224,
    itemHeight: 48,
    padding: { start: PADDING_3, end: PADDING_3 },
    borderRadius: 20,
  };
  private static readonly DEFAULT_SHEET_TITLE: SettingSheetTitleStyle = {
    titleHeight: 64,
  }

  private constructor() {
  }

  public static getInstance(): DefaultPageConfig {
    if (!DefaultPageConfig.instance) {
      DefaultPageConfig.instance = new DefaultPageConfig();
    }
    return DefaultPageConfig.instance;
  }

  public getDefaultPageLayout(isHomePage: boolean): SettingPageLayout {
    return {
      backgroundColor: isHomePage ? Color.Transparent : DefaultPageConfig.DEFAULT_PAGE_LAYOUT.backgroundColor,
      padding: {
        start: DefaultPageConfig.DEFAULT_PAGE_LAYOUT.padding?.start,
        end: DefaultPageConfig.DEFAULT_PAGE_LAYOUT.padding?.end,
        top: isHomePage ? PADDING_8 : DefaultPageConfig.DEFAULT_PAGE_LAYOUT.padding?.top,
        bottom: DefaultPageConfig.DEFAULT_PAGE_LAYOUT.padding?.bottom
      }
    };
  }

  public getDefaultSheetTitleLayout(): SettingSheetTitleStyle {
    return {
      titleHeight: FontScaleUtils.isExtraLargeFontMode() ? 100 : DefaultPageConfig.DEFAULT_SHEET_TITLE.titleHeight,
    };
  }

  public getDefaultPageHeaderStyle(): SettingContentTextStyle {
    return DefaultPageConfig.DEFAULT_PAGE_HEADER_STYLE;
  }

  getDefaultGroupLayout(isHomePage?: boolean): SettingGroupLayout {
    return DefaultPageConfig.DEFAULT_GROUP_LAYOUT;
  }

  getDefaultGroupHeaderStyle(): SettingContentTextStyle {
    return {
      height: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.height,
      textAlign: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.textAlign,
      justifyContent: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.justifyContent,
      padding: {
        start: PADDING_12,
        end: PADDING_12,
        bottom: PADDING_8,
        top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0
      },
      fontSize: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.fontSize,
      fontColor: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.fontColor,
      fontWeight: DefaultPageConfig.DEFAULT_GROUP_HEADER_STYLE?.fontWeight,
    };
  }

  getDefaultGroupFooterStyle(): SettingContentTextStyle {
    return DefaultPageConfig.DEFAULT_GROUP_FOOTER_STYLE;
  }

  private getMinItemHeigth(item: SettingItemModel, hasDesp: boolean): Length {
    if (hasDesp) {
      // 双行时，左侧侧有图标高小于等于24，或者无图标，最小高度为64，有图标但高度大于24则为72,新调整：双行高为64，单行为56
      if (item.icon) {
        if ((item.icon.iconType && item.icon.iconType <= SettingIconType.ICON_TYPE_APPICON) ||
          (item.icon.style?.height && item.icon.style.height > 24)) {
          return 64;
        }
      }
      return 64;
    } else {
      if (item.icon) {
        return item.icon.iconType === SettingIconType.ICON_TYPE_APPICON ? 64 : 56;
      }
      return 48;
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
        normalBackgroundColor: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.background?.normalBackgroundColor,
        pressedBackgroundColor: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.background?.pressedBackgroundColor,
      },
      minHeight: homeComp ? 48 : this.getMinItemHeigth(item, (item.desc !== undefined && item.desc.content !== '')),
      borderRadius: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.borderRadius,
      innerLeftSpace: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.innerLeftSpace,
      innerRightSpace: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.innerRightSpace,
      leftMiddleSpace: item.icon ? DefaultPageConfig.DEFAULT_ITEM_LAYOUT.leftMiddleSpace : PADDING_0,
      rightMiddleSpace: item.detail ? this.getDefaultRightMiddleSpace(item,
        DefaultPageConfig.DEFAULT_ITEM_LAYOUT.rightMiddleSpace) : PADDING_0,
      middleRowSpace: this.getDefaultMiddleRowSpace(item,
        DefaultPageConfig.DEFAULT_ITEM_LAYOUT.middleRowSpace),
      middleColumnSpace: DefaultPageConfig.DEFAULT_ITEM_LAYOUT.middleColumnSpace,
      safetyPadding: FontScaleUtils.getSafetyPadding(),
    };
  }

  getItemMinHeight(item: SettingItemModel, hasDesp: boolean): Length {
    return this.getMinItemHeigth(item, hasDesp);
  }

  getDefaultTextStyle(textType?: SettingTextType): SettingTextStyle {
    let type = textType ?? 0;
    return DefaultPageConfig.DEFAULT_TEXT_STYLE[type];
  }

  getDefaultIconStyle(iconType?: SettingIconType): SettingIconStyle {
    let type = iconType ?? 0;
    return DefaultPageConfig.DEFAULT_ICON_STYLE[type];
  }

  getDefaultDialogStyle(dialog: SettingDialogModel): DialogLayoutStyle {
    return {
      cornerRadius: DefaultPageConfig.DEFAULT_DIALOG_STYLE.cornerRadius,
      autoCancel: DefaultPageConfig.DEFAULT_DIALOG_STYLE.autoCancel,
      maskColor: DefaultPageConfig.DEFAULT_DIALOG_STYLE.maskColor,
      alignment: DefaultPageConfig.DEFAULT_DIALOG_STYLE.alignment,
      padding: {
        top: DefaultPageConfig.DEFAULT_DIALOG_STYLE.padding?.top ?? (dialog.title ? PADDING_0 : PADDING_24),
        bottom: DefaultPageConfig.DEFAULT_DIALOG_STYLE.padding?.bottom ?? (dialog.buttons ? PADDING_16 : PADDING_24),
        start: DefaultPageConfig.DEFAULT_DIALOG_STYLE.padding?.start,
        end: DefaultPageConfig.DEFAULT_DIALOG_STYLE.padding?.end,
      },
      contentButtonSpace: DefaultPageConfig.DEFAULT_DIALOG_STYLE.contentButtonSpace,
      titleHeight: DefaultPageConfig.DEFAULT_DIALOG_STYLE.titleHeight,
      buttonPad: DefaultPageConfig.DEFAULT_DIALOG_STYLE.buttonPad,
      buttonSpaceHorizontal: DefaultPageConfig.DEFAULT_DIALOG_STYLE.buttonSpaceHorizontal,
      buttonSpaceVertical: DefaultPageConfig.DEFAULT_DIALOG_STYLE.buttonSpaceVertical,
      titleStyle: DefaultPageConfig.DEFAULT_DIALOG_STYLE.titleStyle,
      contentStyle: DefaultPageConfig.DEFAULT_DIALOG_STYLE.contentStyle
    };
  }

  getDefaultDialogButtonStyle(): DialogButtonStyle {
    return DefaultPageConfig.DEFAULT_DIALOG_BUTTON_STYLE;
  }

  getDefaultRadioStyle(): SettingRadioStyle {
    return DefaultPageConfig.DEFAULT_RADIO_STYLE;
  }

  getDefaultCheckboxStyle(): SettingCheckboxStyle {
    return DefaultPageConfig.DEFAULT_CHECKBOX_STYLE;
  }

  getDefaultMenuStyle(): SettingMenuStyle {
    return {
      width: DefaultPageConfig.DEFAULT_MENU_STYLE.width,
      itemHeight: DefaultPageConfig.DEFAULT_MENU_STYLE.itemHeight,
      itemPadding: { top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_12 : PADDING_0,
        bottom: FontScaleUtils.isExtraLargeFontMode() ? PADDING_12 : PADDING_0 },
      padding: DefaultPageConfig.DEFAULT_MENU_STYLE.padding,
      borderRadius: DefaultPageConfig.DEFAULT_MENU_STYLE.borderRadius,
    };
  }
}