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
  BaseStyle,
  ContainerStyle,
  TextStyle
} from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { CardRadioMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import {
  ButtonMenuContainerStyle,
  DefaultButtonMenuStyle,
  DefaultSwitchMenuStyle,
  DialogMessageStyle,
  DialogMessageTextStyle,
  DialogTitleMenuStyle,
  PageTitleContainerStyle,
  PageTitleTextStyle,
  SummaryTextStyle,
  SwitchContainerStyle,
  SwitchToggleStyle,
  TransparentButtonStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';

export const TEXT_MARGIN_HORIZONTAL: Length = $r('sys.float.padding_level4');

const MAX_LINES_10: number = 10;
const MAX_LINES_19: number = 19;

class RadioContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: $r('app.float.wh_20'),
    height: $r('app.float.wh_20'),
  };
  public margin: Margin = {
    right: $r('sys.float.padding_level8'),
  };
}

let radioContainerStyle = new RadioContainerStyle();

/**
 * 标题样式
 */
export class DisplayTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public font: Font = {
    size: $r('sys.float.Subtitle_M'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_10;
}

/**
 * 辅助文本样式
 */
export class DisplaySummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.Subtitle_S'),
    weight: FontWeight.Regular
  };
}

/**
 * 卡片形式的Radio控件样式
 */
export class DisplayRadioStyle extends CardRadioMenuStyle {
  public rootContainer: ContainerStyle = radioContainerStyle;
  public title: TextStyle = new DisplayTitleTextStyle();
  public summary: TextStyle = new DisplaySummaryTextStyle();
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_64'),
  }
  public padding: Padding = {
    left: $r('sys.float.padding_level8'),
    top: $r('app.float.padding_8'),
    bottom: $r('app.float.padding_8')
  };
  public menuContainerPadding: Padding = {
    left: $r('sys.float.corner_radius_level2'),
    right: $r('sys.float.corner_radius_level2')
  };
}

/**
 * 开关样式
 */
export class BrightnessSwitchMenuStyle extends DefaultSwitchMenuStyle {
  public toggleStyle: BaseStyle = new BrightnessSwitchToggleStyle();
}

class BrightnessSwitchToggleStyle extends SwitchToggleStyle {
  public selectedColor: Resource = $r('sys.color.comp_background_emphasize');
}

class SummarySwitchContainerStyle extends SwitchContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_64'),
  };
}

/**
 * 开关的辅助文本样式
 */
export class SummarySwitchMenuStyle extends DefaultSwitchMenuStyle {
  public rootContainer: ContainerStyle = new SummarySwitchContainerStyle();
  public toggleStyle: BaseStyle = new BrightnessSwitchToggleStyle();
}

export class RadioMenuStyle extends CardRadioMenuStyle {
  public title: TextStyle = new A11yTitleTextStyle();
  public summary: TextStyle = new RadioSummaryTextStyle();
  public toggleStyle = new SwitchToggleStyle();
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: $r('app.float.length_13'),
    bottom: $r('app.float.length_14'),
  };
  public menuContainerPadding: Padding = {
    left: $r('sys.float.padding_level2'),
    right: $r('sys.float.padding_level2'),
  };
}

export class RadioTopMenuStyle extends RadioMenuStyle {
  public title: TextStyle = new RadioTitleTextStyle();
  public summary: TextStyle = new RadioSummaryStyle();
  public rootContainer: ContainerStyle = new RadioTextContainerStyle();
  public padding: Padding = {
    left: $r('app.float.padding_8'),
    right: $r('app.float.padding_8'),
    top: $r('app.float.padding_8'),
    bottom: $r('app.float.padding_8'),
  };
}

export class RadioBottomMenuStyle extends RadioMenuStyle {
  public title: TextStyle = new RadioAndTitleTextStyle();
  public summary: TextStyle = new RadioBottomSummaryTextStyle();
  public rootContainer: ContainerStyle = new RadioTextContainerStyle();
}

export class RadioBottomSummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.Subtitle_S'),
    weight: FontWeight.Regular
  };
  public margin: Margin = {
    top: $r('app.float.border_radius_0'),
  };
}

export class RadioAndTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public font: Font = {
    size: $r('sys.float.Subtitle_M'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_19;
}

export class RadioTitleTextStyle extends RadioAndTitleTextStyle {
  public margin: Margin = {
    top: $r('app.float.length_2'),
  };
}

export class RadioSummaryStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.Subtitle_S'),
    weight: FontWeight.Regular
  };
}

/**
 * 菜单标题样式
 *
 * @since 2024-05-14
 */
export class A11yTitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Medium,
  };
  public margin: Margin = {
    left: $r('app.float.wh_value_0'),
    right: $r('app.float.wh_value_0'),
    top: $r('app.float.wh_value_10'),
    bottom: $r('app.float.wh_value_0'),
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = MAX_LINES_19;
  public size: SizeOptions = {
    width: '70%',
  };
  public constraintSize?: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_22'),
  };
}

export class RadioSummaryTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.Subtitle_S'),
    weight: FontWeight.Regular
  };
}

class RadioTextContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: $r('app.float.wh_20'),
    height: $r('app.float.wh_20'),
  };
  public margin: Margin = {
    left: $r('app.float.margin_16'),
    top: $r('app.float.margin_0'),
    right: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
}

class DarkModeButtonStyle extends TransparentButtonStyle {
  public margin: Margin = {
    top: $r('app.float.length_8'),
    bottom: $r('app.float.border_radius_16'),
  };
  public size: SizeOptions = {
    width: '100%',
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_40'),
  };
  public font: Font = {
    family: 'HarmonyHeiTi',
    size: $r('app.float.font_16'),
    weight: FontWeight.Medium,
  };
  public lineHeight: Resource = $r('app.float.lineHeight_19');
}

export class ConfirmDeleteButtonMenuStyle extends DefaultButtonMenuStyle {
  public rootContainer = new ButtonMenuContainerStyle();
  public buttonStyle1 = new DarkModeButtonStyle();
  public buttonStyle2 = new DarkModeButtonStyle();
}

export class DialogTitleStyle extends PageTitleTextStyle {
  public font: Font = {
    family: 'HarmonyHeiTi',
    weight: FontWeight.Bold,
    size: $r('app.float.font_20'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.height_23'),
  };
  public margin: Margin = {
    top: $r('app.float.length_15'),
    bottom: $r('app.float.length_15'),
  };
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
  public maxLines: number = MAX_LINES_10;
}

export class DarkModeTitleMenuStyle extends DialogTitleMenuStyle {
  public rootContainer?: ContainerStyle = new PageTitleContainerStyle();
  public title?: TextStyle = new DialogTitleStyle();
}

class DarkModeMessageContainerStyle extends PageTitleContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  };
  public justifyContent: FlexAlign = FlexAlign.Center;
  public overflow: TextOverflow = TextOverflow.None;
}

export class DarkModeMessageStyle extends DialogMessageTextStyle {
  public font: Font = {
    family: 'HarmonyHeiTi',
    size: $r('app.float.font_14'),
    weight: FontWeight.Regular,
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: $r('app.float.lineHeight_16'),
  };
  public fontColor: ResourceColor = $r('sys.color.font_primary');
}

export class DarkModeMessageMenuStyle extends DialogMessageStyle {
  public rootContainer?: ContainerStyle = new DarkModeMessageContainerStyle();
  public title?: TextStyle = new DarkModeMessageStyle();
}
