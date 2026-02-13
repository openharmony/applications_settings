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
import { SettingBaseModel } from './SettingBaseModel';
import { SettingPageLayout } from './SettingPageModel';
import { SettingBaseState, SettingStateType } from './SettingStateModel';
import { AccessibilityLevelType } from '../../utils/AccessibilityUtils';

export enum ItemType {
  /*
   * 自定义类型
   */
  ITEM_TYPE_CUSTOM = 0,

  /*
   * 标准类型，配置项整体构成如下：
   * +++++++++++++++++++++++++++++
   * | 左侧元素 | 中间元素 | 右侧元素 |
   * +++++++++++++++++++++++++++++
   * 左侧元素：一般为icon，可选
   * 中间元素：包括title、desp、reddot，其中title为必选
   * 右侧元素：包括result、detail，可选
   */
  ITEM_TYPE_STANDARD = 1,

  /*
   * 输入类型
   */
  ITEM_TYPE_INPUT = 2,

  /*
   * 进度条类型
   */
  ITEM_TYPE_PROGRESS = 3,

  /*
  * 选择类型
  */
  ITEM_TYPE_SELECTOR = 4,
}

/*
 * 可定义的icon样式
 */
export interface SettingIconStyle {
  width?: Length;
  height?: Length;
  objectFit?: ImageFit;
  borderRadius?: Length;
  draggable?: boolean;
  mirrored?: boolean;
  fillColor?: ResourceColor;
  interpolation?: ImageInterpolation;
  edgeAntialiasing?: number;
  border?: BorderOptions;
  clip?: boolean | CircleAttribute | EllipseAttribute | PathAttribute | RectAttribute;
  renderingStrategy?: SymbolRenderingStrategy;
  accessibilityText?: Resource;
  accessibilityLevel?: AccessibilityLevelType;
  builder?: WrappedBuilder<[object]>;
  opacity?: number | Resource;
  fontWeight?: FontWeight;
}

/*
 * 支持的标准icon类型
 */
export enum SettingIconType {
  // 通用图标，32 x 32
  ICON_TYPE_STANDARD = 1,
  // appicon, 48 x 48
  ICON_TYPE_APPICON = 2,
  // 调整箭头, 12 x 24
  ICON_TYPE_ARROW = 3,
  // 提醒图标，24 X 24
  ICON_TYPE_TIP = 4,
  // 标题旁图标，32 X 16
  ICON_TYPE_TITLE_ICON = 5
}

export interface SettingIconModel {
  /*
   * icon资源
   */
  icon?: ResourceStr | PixelMap;

  /*
   * icon类型，可指定icon类型以使用该类型的标准style
   */
  iconType?: SettingIconType;

  /*
   * icon样式，自定义style，定义了会优先使用，否则使用默认样式
   */
  style?: SettingIconStyle;

  /**
   * 图片是否由Symbol组件创建
   */
  isSymbolIcon?: boolean;

  /**
   * 图标自定义
   */
  builder?: WrappedBuilder<[object]>;
}

/*
 * 可定义的text样式
 */
export interface SettingTextStyle {
  fontSize?: Length;
  fontColor?: ResourceColor;
  fontWeight?: FontWeight;
  fontFamily?: ResourceStr;
  textAlign?: TextAlign;
  maxLines?: number;
  textOverflow?: TextOverflow;
  minFontSize?: ResourceStr;
  maxFontSize?: ResourceStr;
  lineHeight?: ResourceStr;
  wordBreak?: WordBreak;
  opacity?: number | Resource;
  direction?: Direction;
  copyOption?: CopyOptions;
}

/*
 * 支持的标准text类型
 */
export enum SettingTextType {
  // 一级文本
  TEXT_TYPE_PRIMARY = 1,
  // 二级文本
  TEXT_TYPE_SECONDARY = 2,
  // 三级文本
  TEXT_TYPE_THIRD = 3,
}

export interface SettingTextModel {
  /*
   * text资源
   */
  content: ResourceStr;

  /*
   * text类型，可指定text类型以使用该类型的标准style
   */
  textType?: SettingTextType;

  /*
   * text样式，自定义style，定义了会优先使用，否则使用默认样式
   */
  style?: SettingTextStyle;

  /**
   * text的layout占用权重
   */
  layoutWeight?: number;
}

export interface SettingToggleStyle {
  width?: Length;
  height?: Length;
  hoverEffect?: HoverEffect;
  margin?: Length;
}

export interface SettingToggleModel {
  state: boolean;
  style?: SettingToggleStyle;
  enabled?: boolean;
  onChanged?: (isOn: boolean) => void;
}

export interface SettingRadioStyle {
  width?: Length;
  height?: Length;
  indicatorType?: RadioIndicatorType;
  radioStyle?: RadioStyle;
  /*
   * 未选中时是否展示radio
   */
  showUnchecked?: boolean;
}

export interface SettingRadioModel {
  /*
   * 默认选中状态
   */
  checked?: boolean;
  style?: SettingRadioStyle;
  onCheck?: (isCheck: boolean, item: SettingItemModel) => void;
}

export interface SettingCheckboxStyle {
  width?: Length;
  height?: Length;
  selectedColor?: ResourceColor;
  unselectedColor?: ResourceColor;
  mark?: MarkStyle;
  shape?: CheckBoxShape;
  /**
   * 未选中时是否展示checkbox
   */
  showUnSelected?: boolean;
}

export interface SettingCheckboxModel {
  /**
   * 默认选中状态
   */
  selected?: boolean;
  style?: SettingCheckboxStyle;
  onSelected?: (isSelected: boolean, item: SettingItemModel) => void;
}

/*
 * 支持的标准result类型
 */
export enum ItemResultType {
  // result为自定义组件
  RESULT_TYPE_CUSTOM = 0,
  // result为text样式
  RESULT_TYPE_TEXT = 1,
  // result为image样式
  RESULT_TYPE_IMAGE = 2,
  // result为toggle样式
  RESULT_TYPE_TOGGLE = 3,
  // result为radio样式
  RESULT_TYPE_RADIO = 4,
  // result为checkbox样式
  RESULT_TYPE_CHECKBOX = 5
}

export interface SettingItemResultModel {
  /*
   * result类型
   */
  type: ItemResultType;

  /*
   * result数据内容
   */
  result: SettingTextModel | SettingIconModel | SettingToggleModel | SettingRadioModel | 
    SettingCheckboxModel | undefined;

  /*
   * 自定义组件Builder
   */
  builder?: WrappedBuilder<[object]>;
}

export interface DialogButtonStyle {
  type?: ButtonType;
  borderRadius?: Length;
  width?: Length;
  height?: Length;
  alignSelf?: ItemAlign;
  constraintSize?: ConstraintSizeOptions;
  padding?: LocalizedPadding;
  background?: ResourceColor;
  fontColor?: ResourceColor;
  buttonStyle?: ButtonStyleMode;
  fontWeight?: FontWeight;
  role?: ButtonRole;
}

export interface DialogButton {
  value: ResourceStr;
  action: (component: SettingItemModel) => void;
  style?: DialogButtonStyle;

  /*
   * 默认焦点
   */
  focused?: boolean;
}

export interface SegmentButtonModel {
  tabContents: ResourceStr[];
  selectedIndexes: number[];
  layout?: SettingPageLayout;
  compId: string;
}

export interface DialogLayoutStyle {
  width?: Dimension;
  height?: Dimension;
  backgroundColor?: ResourceColor;
  cornerRadius?: BorderRadiuses;
  autoCancel?: boolean;
  maskColor?: ResourceColor;
  alignment?: DialogAlignment;

  /*
   * 整体内间距
   */
  padding?: LocalizedPadding;
  /*
   * 内容区与操作区间距
   */
  contentButtonSpace?: LengthMetrics;
  /*
   * 标题区高度
   */
  titleHeight?: Length;
  /*
   * 操作区左右间距
   */
  buttonPad?: LengthMetrics;

  /*
   * | Button1 | <间距> | Button2 |
   */
  buttonSpaceHorizontal?: LengthMetrics;

  /*
   * |        Button1        |
   *           <间距>
   * |        Button2        |
   */
  buttonSpaceVertical?: Length;

  /*
   * title style
   */
  titleStyle?: SettingTextStyle;

  /**
   * content text style
   */
  contentStyle?: SettingTextStyle;
}

export interface SettingDialogModel {
  /*
   * 内容区自定义builder
   */
  contentBuilder?: WrappedBuilder<[SettingItemModel]>;

  /*
   * 标题
   */
  title?: ResourceStr;

  /*
   * 文本内容 (优先渲染contentBuilder)
   */
  message?: ResourceStr;
  /*
   * 操作区buttons
   */
  buttons?: DialogButton[];

  /*
   * button排列方向：true表示水平方向, false表示竖直方向
   */
  buttonVertical?: boolean;

  /*
   * 弹框布局
   */
  style?: DialogLayoutStyle;

  /**
   * 弹框层级
   */
  showInSubWindow?: boolean;

  /*
   * 弹窗自动关闭回调
   */
  onWillDismiss?: () => void;
}

export enum ItemDetailType {
  /*
   * 自定义类型，处理由item的compControl?.onClick定义的点击事件
   */
  DETAIL_TYPE_CUSTOM = 0,

  /*
   * 导航类型，跳转到目标页面
   */
  DETAIL_TYPE_NAVIGATE = 1,

  /*
   * 菜单类型，弹出菜单选项
   */
  DETAIL_TYPE_MENU = 2,

  /*
   * 弹框类型，弹出弹框
   */
  DETAIL_TYPE_DIALOG = 3,

  /*
   * 半模态弹框
   */
  DETAIL_TYPE_MODAL = 4,
}

export interface SettingMenuStyle {
  width?: Length;
  constraintSize?: ConstraintSizeOptions;
  itemHeight?: Length;
  itemPadding?: LocalizedPadding;
  padding?: LocalizedPadding;
  borderRadius?: Length;
  backgroundColor?: ResourceColor;
}

export interface SettingSheetTitleStyle {
  titleHeight?: Length;
}

export interface SettingSelectMenu {
  items: ResourceStr[];
  selectIcon: ResourceStr;
  defaultFocus?: number;
  style?: SettingMenuStyle;
  onSelected?: (index: number) => void;
}

// detail定义的是设置项的详情处理事件
export interface SettingItemDetailModel extends SettingIconModel {
  type: ItemDetailType;
  destination?: string;
  responseRegion?: Rectangle;

  /*
   * 菜单选择项
   */
  menu?: SettingSelectMenu;

  /*
   * 弹框配置，仅支持静态弹框配置；
   * 如需动态弹框，通过自定义类型点击，触发弹框事件实现
   */
  dialog?: SettingDialogModel;

  /*
   * 半模态页面配置项
   */
  sheetOptions?: SheetOptions

  /*
   * 自定义半模态弹框
   */
  sheetBuilder?: WrappedBuilder<[SettingItemModel]>;

  /*
   * 自定义item点击事件
   */
  onItemClick?: (component: SettingBaseModel) => void;

  /*
   * 自定义detail子组件自身的点击事件
   */
  onSelfClick?: (component: SettingBaseModel) => void;

  /**
   * 图标可见性
   */
  visible?: Visibility;

  /**
   * 忽略detail的点击处理，走controller中定义的点击事件
   */
  ignoreClick?: boolean;
}

export interface SettingItemDividerModel {
  /*
   * 分割线左侧间距（相对于顶格元素左侧的间距）
   */
  leftPadding?: LengthMetrics;

  /*
 * 分割线顶部间距（相对于顶格元素顶部的间距）
 */
  topPadding?: LengthMetrics;

  /*
 * 分割线底部间距（相对于顶格元素底部的间距）
 */
  bottomPadding?: LengthMetrics;
}

export interface SettingItemBackground {
  normalBackgroundColor?: ResourceColor;
  pressedBackgroundColor?: ResourceColor;
}

/*
 * 配置项分左、中、右3部分，中间必须有，左右可有可无
 * 中间部分又可分为列和行，一般不超过2列，不超过3行
 */
export interface SettingItemLayout {
  /*
   * 背景设置
   */
  background?: SettingItemBackground;

  /*
   * 设置项最小高度
   */
  minHeight?: Length;

  /*
   * 设置项圆角
   */
  borderRadius?: Length;

  /*
   * 设置项左内边距
   */
  innerLeftSpace?: LengthMetrics;

  /*
   * 设置项右内边距
   */
  innerRightSpace?: LengthMetrics;

  /*
   * 中间区左侧间距
   */
  leftMiddleSpace?: LengthMetrics;

  /*
   * 中间区右侧间距
   */
  rightMiddleSpace?: LengthMetrics;

  /*
   * 中间列间距，即title与result间距
   */
  middleRowSpace?: LengthMetrics;

  /*
   * 中间行间距，即title与desp间距
   */
  middleColumnSpace?: LengthMetrics;

  /*
   * 设置项内容区安全边距
   */
  safetyPadding?: LengthMetrics;

  /**
   * 不显示分割线
   */
  noNeedDivider?: boolean;

  /**
   * 无障碍组，设置为true时表示该组件及其所有子组件为一整个可以选中的组件，其子组件内容不播报（accessibilityLevel="yes"的子组件例外）
   */
  accessibilityGroup?: boolean;

  /**
   * 无障碍文本，用于屏幕朗读播报
   */
  accessibilityText?: Resource | string;

  /**
   * 无障碍提醒，用于自定义提醒用户当前组件支持什么操作，实现onClick的组件默认播报提醒"单指双击即可执行"，设置此属性后不再播报默认提醒
   */
  accessibilityDescription?: Resource | string;

  /**
   * 无障碍使能，用于自定义该组件是否支持无障碍
   */
  accessibilityLevel?: AccessibilityLevelType;
}

export enum ItemPos {
  ITEM_POS_START = 1,
  ITEM_POS_CENTER = 2,
  ITEM_POS_END = 4,
}

export interface SettingItemModel extends SettingBaseModel {
  type: ItemType;
  icon?: SettingIconModel;
  title?: SettingTextModel;
  topTitle?: SettingTextModel;
  titleIcon?: SettingIconModel;
  desc?: SettingTextModel;
  result?: SettingItemResultModel;
  detail?: SettingItemDetailModel;
  divider?: SettingItemDividerModel;
  layout?: SettingItemLayout;
  subId?: String;

  /*
   * 判断item是否不需要添加，不需要返回true
   */
  needHide?: () => boolean;

  /*
   * 设置项运行态事件接口，可避免走消息总线
   */
  onItemEvent?: (datas: Map<SettingStateType, SettingBaseState>) => void;

  /**
   * 点击事件回调接口
   * @param touchType
   */
  onTouchEvent?: (touchType: TouchType) => void;
}

export interface ComparableSettingItemModel extends SettingItemModel {
  /*
   * 本对象与dst进行大小比较，返回-1、0、1，如果排在dst之后则返回-1；未赋值将不进行排序
   */
  compare?: (dst: ComparableSettingItemModel) => number;
}

export class DefaultSettingItemModel implements SettingItemModel {
  public id: string = '';
  public type: ItemType = ItemType.ITEM_TYPE_STANDARD;

  private static instance: DefaultSettingItemModel;
  private constructor() {
  }
  public static get(): DefaultSettingItemModel {
    if (!DefaultSettingItemModel.instance) {
      DefaultSettingItemModel.instance = new DefaultSettingItemModel();
    }
    return DefaultSettingItemModel.instance;
  }
}