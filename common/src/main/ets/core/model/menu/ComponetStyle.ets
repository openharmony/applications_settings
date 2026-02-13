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

export abstract class TextStyle extends BaseStyle {
  public fontColor?: ResourceColor;
  public font?: Font;
  public textAlign?: TextAlign;
  public overflow?: TextOverflow;
  public maxLines?: number;
  public lineHeight?: number | string | Resource;
  public wordBreak?: WordBreak;
  public maxFontSize?: number | string | Resource;
  public minFontSize?: number | string | Resource;
  public fontFeature?: string;
}

export abstract class TextInputStyle extends BaseStyle {
  public inputType?: InputType;
  public inputFilter: ResourceStr = '';
  public placeholderColor?: ResourceColor;
  public placeholderFont?: Font;
  public caretColor?: ResourceColor;
  public maxLength?: number;
  public textAlign?: TextAlign;
  public maxLines?: number;
  public fontWeight?: FontWeight;
  public fontFamily?: ResourceStr;
  public fontColor?: ResourceColor;
  public fontSize?: Font;
  public showUnderline?: boolean;
  public direction?: Direction;
  public inputFilterReg?: ResourceStr;
  public enableAutoFill?: boolean;
}

export abstract class ButtonStyle extends BaseStyle {
  public fontColor?: ResourceColor | Resource;
  public font?: Font;
  public lineHeight?: number | string | Resource;
  public maxLines?: number;
  public borderRadius?: Length;
}

export abstract class LoadingProgressStyle extends BaseStyle {
}

export abstract class ImageStyle extends BaseStyle {
  public imageFit?: ImageFit;
  public fillColor?: ResourceColor;
}

export abstract class SymbolGlyphStyle extends BaseStyle {
  public renderingStrategy?: SymbolRenderingStrategy;
  public fontColor?: ResourceColor[];
  public fontWeight?: FontWeight;
}

export abstract class CanvasStyle extends BaseStyle {
}

export abstract class RadioStyle extends BaseStyle {
  public size?: SizeOptions;
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
  public gridRowConfig?: GridRowOptions;
  public gridColConfig?: GridColOptions;
}

export abstract class CommonBadgeStyle extends BaseStyle {
  public badgeStyle?: BadgeStyle;
  public setMarginRight: (badgeCount: number) => void = (badgeCount: number) => {
  };
  public setPaddingRight: (badgeCount: number) => void = (badgeCount: number) => {
  };
}

export abstract class DividerStyle implements Style {
  public vertical?: boolean;
  public strokeWidth?: Length;
  public color?: ResourceColor;
  public startMargin?: Length;
  public endMargin?: Length;
  public lineCap?: LineCapStyle;
}

export abstract class SubHeaderStyle implements Style {
  public rootContainer?: ContainerStyle;
  public title?: TextStyle;
}

export abstract class IconTextStyle extends SubHeaderStyle {
  public icon?: TextStyle;
}

export abstract class PageHeaderStyle implements Style {
  public rootContainer?: ContainerStyle;
  public title?: TextStyle;
}

export abstract class GroupStyle extends ContainerStyle {
  public divider?: DividerStyle;
  public height?: number | string | Resource;
  public minHeight?: number | string | Resource;
  public subHeaderStyle?: SubHeaderStyle;
  public listStyle?: GroupStyle;
}

export abstract class PageStyle extends GroupStyle {
  public rootContainer?: ContainerStyle;
}

export abstract class SelectStyle extends BaseStyle {
  public font?: Font;
  public fontColor?: ResourceColor;
  public selectedOptionBgColor?: ResourceColor;
  public selectedOptionFont?: Font;
  public selectedOptionFontColor?: ResourceColor;
  public optionBgColor?: ResourceColor;
  public optionFont?: Font;
  public optionFontColor?: ResourceColor;
}