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

import { SettingBaseModel } from './SettingBaseModel';
import { SettingItemModel, SettingTextStyle } from './SettingItemModel';

export enum GroupType {
  /*
   * 自定义类型
   */
  GROUP_TYPE_CUSTOM = 0,

  /*
   * 标准类型，items固定，需在配置中定义
   */
  GROUP_TYPE_STANDARD = 1,

  /*
   * 动态类型，items数据动态获取，需要实现数据注入接口
   */
  GROUP_TYPE_DYNAMIC = 2,

  /*
   * 动态懒加载类型，items数据动态获取，需要实现数据懒加载接口
   */
  GROUP_TYPE_DYNAMIC_LAZY = 3,

  /*
   * 动态懒加载压缩类型，items数据动态获取，需要实现数据懒加载接口，初始处于页面收缩状态仅显示部分数据
   * 需在配置中定义收缩属性(默认显示行数、显示顺序)
   */
  GROUP_TYPE_DYNAMIC_LAZY_SHRINK = 4,
}

export interface SettingContentTextStyle extends SettingTextStyle {
  height?: Length;
  textAlign?: TextAlign;
  justifyContent?: FlexAlign;
  padding?: LocalizedPadding;
}

export interface SettingContentModel extends SettingBaseModel {
  content?: ResourceStr;
  style?: SettingContentTextStyle;
}

export interface SettingGroupShrinkOrder {
  orderName: ResourceStr;
  orderCompareFunc: Function;
}

export interface GroupDividerStyle {
  strokeWidth?: Length;
  color?: ResourceColor;
  startMargin?: Length;
  endMargin?: Length;
}

export interface SettingGroupLayout {
  // 白框背景
  backgroupColor?: ResourceColor;
  // 白框圆角
  borderRadius?: Length;
  // 白框内边距
  padding?: LocalizedPadding;
  // group间外边距
  margin?: LocalizedPadding;
  // group item之间分割线样式, 未定义则使用SettingItemStandard自定义分割线，不可混用
  dividerStyle?: GroupDividerStyle;
}

export interface SettingGroupModel extends SettingBaseModel {
  type: GroupType;
  header?: SettingContentModel;
  footer?: SettingContentModel;
  items?: SettingItemModel[];
  shrink?: SettingGroupShrinkOrder[];
  layout?: SettingGroupLayout;

  /*
   * 判断group是否需要隐藏，需要返回true
   */
  needHide?: boolean;

  /*
   * 分帧加载时，group加载的目标帧
   */
  targetFrame?: number;
}

export class DefaultSettingGroupModel implements SettingGroupModel {
  public id: string = '';
  public type: GroupType = GroupType.GROUP_TYPE_STANDARD;

  private static instance: DefaultSettingGroupModel;
  private constructor() {
  }
  public static get(): DefaultSettingGroupModel {
    if (!DefaultSettingGroupModel.instance) {
      DefaultSettingGroupModel.instance = new DefaultSettingGroupModel();
    }
    return DefaultSettingGroupModel.instance;
  }
}