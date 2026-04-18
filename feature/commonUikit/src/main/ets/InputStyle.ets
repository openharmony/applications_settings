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

export interface Style {}

export abstract class BaseStyle implements Style {
  public size?: SizeOptions;
  public constraintSize?: ConstraintSizeOptions;
  public padding?: Padding;
  public pagePadding?: Padding;
  public margin?: Margin;
  public layoutWeight?: number | string;
  public clip?: boolean | CircleAttribute | EllipseAttribute | PathAttribute | RectAttribute;
  public borderRadius?: Length;
  public borderColor?: ResourceColor;
  public borderWidth?: Length;
  public selectColor?: ResourceColor | Color;
  public imageColor?: ResourceColor;
  public backgroundColor?: ResourceColor | Color | Resource;
  public backgroundBlurStyle?: BlurStyle;
  public align?: Alignment;
  public visible?: boolean;
  public gridSpan?: number;
  public gridOffset?: number;
  public opacity?: number | Resource;
  public enabled?: boolean;
  public justifyContent?: FlexAlign;
}

export abstract class ContainerStyle extends BaseStyle {
  public space?: Length;
  public verticalAlign?: VerticalAlign;
  public horizontalAlign?: HorizontalAlign;
  public justifyContent?: FlexAlign;
  public gridGutter?: Length;
  public gridMargin?: Length;
  public gridColumns?: number;
  public rowStart?: number;
  public rowEnd?: number;
  public columnStart?: number;
  public columnEnd?: number;
  public lanes?: number;
  public responseRegion?: Rectangle;
  public lineHeight?: number | string | Resource;
}

export abstract class TextInputMenuStyle implements Style {
  public rootContainer?: ContainerStyle;
  public textInputStyle?: TextInputStyle;
  public summaryStyle?: TextStyle;
  public stateStyle?: TextStyle;
  public dividerStyle?: BaseStyle;
}

export abstract class TextInputStyle extends BaseStyle {
  public inputType?: InputType;
  public inputFilter: ResourceStr = '';
  public placeholderColor?: ResourceColor;
  public placeholderFont?: Font;
  public caretColor?: ResourceColor;
  public maxLength?: number;
  public textAlign?: TextAlign;
  public direction?: Direction;
  public maxLines?: number;
  public fontWeight?: FontWeight;
  public fontFamily?: ResourceStr;
  public fontColor?: ResourceColor;
  public fontSize?: Font;
  public showUnderline?: boolean;
}

export class RootContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
  }
  public padding: Padding = {
    left: $r('sys.float.padding_level4'),
    right: $r('sys.float.padding_level4'),
    top: $r('sys.float.padding_level0'),
    bottom: $r('sys.float.padding_level0'),
  };
  public margin: Margin = {
    top: $r('sys.float.padding_level0'),
    bottom: $r('sys.float.padding_level0'),
    left: $r('sys.float.padding_level0'),
    right: $r('sys.float.padding_level0'),
  };
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '48vp',
  };
  public space: Length = '16vp';
}

export class TextInputContainerStyle extends RootContainerStyle {
  public horizontalAlign: number = HorizontalAlign.Start;
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '40vp',
  };
  public size: SizeOptions = {
    width: '100%',
  };
}

export class TitleTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Medium,
  };
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public maxLines: number = 10;
}

export class NewInputTextSummaryStyle extends TitleTextStyle {
  public padding: Padding = {
    top: $r('sys.float.padding_level12'),
    bottom: $r('sys.float.padding_level2'),
  };
  public font: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Regular,
  };
}

export class NewTextInputStyle extends TextInputStyle {
  public fontColor: ResourceColor = $r('sys.color.font_primary');
  public fontSize: Font = {
    size: $r('sys.float.Subtitle_M'),
    weight: FontWeight.Regular,
  };
  public constraintSize?: ConstraintSizeOptions | undefined = {
    minHeight: '56vp'
  };
  public backgroundColor: number = Color.Transparent;
  public maxLength: number = 128;
  public padding: Padding = {
    left: $r('sys.float.padding_level0'),
  };
  public margin: Margin = {
    left: $r('sys.float.padding_level0'),
  };
}

export class TextDividerStyle extends BaseStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '1vp',
  };
  public backgroundColor: Resource = $r('sys.color.comp_background_tertiary');
}

export class NewDefaultTextInputMenuStyle extends TextInputMenuStyle {
  public rootContainer: TextInputContainerStyle = newDefaultTextInputRootContainer;
  public summaryStyle: NewInputTextSummaryStyle = newDefaultTextInputSummaryStyle;
  public textInputStyle: NewTextInputStyle = newDefaultTextInputStyle;
  public stateStyle: TitleTextStyle = titleTextStyle;
  public dividerStyle: TextDividerStyle = newDefaultTextInputDividerStyle;
}

export class NewNumTextInputStyle extends NewTextInputStyle {
  public inputType: number = InputType.Number;
}

export class PasswordInputStyle extends TextInputStyle {
  public inputType: number = InputType.Password;
  public placeholderColor: Resource = $r('sys.color.font_secondary');
  public placeholderFont: Font = {
    size: $r('sys.float.Body_L'),
    weight: FontWeight.Regular,
    family: 'sans-serif',
    style: FontStyle.Normal,
  };
  public backgroundColor: ResourceColor | Color = '#0C000000';
  public caretColor: number = Color.Blue;
  public size: SizeOptions = {
    height: '56vp',
  };
  public maxLength: number = 64;
}

export class PasswordInputContainerStyle extends RootContainerStyle {
}

export class EapPasswordInputStyle extends PasswordInputStyle {
  public backgroundColor: ResourceColor | Color = Color.Transparent;
  public padding: Padding = {
    left: $r('sys.float.padding_level2'),
  };
  public margin: Margin = {
    top: $r('sys.float.padding_level4'),
  };
  public size: SizeOptions = {
    height: '48vp',
  };
}

export class HotspotLimitTextInputStyle extends TextInputStyle {
  public inputType?: InputType = InputType.Number;
  public maxLength?: number = 6;
  public backgroundColor: ResourceColor | Color = Color.Transparent;
  public size: SizeOptions = {
    height: '48vp',
  };
  public padding: Padding = {
    left: $r('sys.float.padding_level4'),
  };
}

export class EapPasswordTextDividerStyle extends BaseStyle {
  public size: SizeOptions = {
    width: 'calc(100% - 10vp)',
    height: '1vp',
  };
  public backgroundColor = $r('sys.color.comp_background_tertiary');
}

export class PasswordInputMenuStyle extends TextInputMenuStyle {
  public rootContainer: PasswordInputContainerStyle = new PasswordInputContainerStyle();
  public textInputStyle: PasswordInputStyle = new PasswordInputStyle();
}

export class HotspotLimitStyle extends TextInputMenuStyle {
  public textInputStyle: TextInputStyle = new HotspotLimitTextInputStyle();
}

export class NewNumDefaultTextInputMenuStyle extends NewDefaultTextInputMenuStyle {
  public textInputStyle: NewNumTextInputStyle = newNumTextInputStyle;
}

export class EapPasswordTextInputStyle extends PasswordInputMenuStyle {
  public textInputStyle: EapPasswordInputStyle = new EapPasswordInputStyle();
  public dividerStyle: EapPasswordTextDividerStyle = new EapPasswordTextDividerStyle();
}

let newNumTextInputStyle: NewNumTextInputStyle = new NewNumTextInputStyle();

let newDefaultTextInputDividerStyle: TextDividerStyle = new TextDividerStyle();

let titleTextStyle: TitleTextStyle = new TitleTextStyle();

let newDefaultTextInputRootContainer: TextInputContainerStyle = new TextInputContainerStyle();

let newDefaultTextInputSummaryStyle: NewInputTextSummaryStyle = new NewInputTextSummaryStyle();

let newDefaultTextInputStyle: NewTextInputStyle = new NewTextInputStyle();