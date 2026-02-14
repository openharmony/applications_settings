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

interface MenuEntryData {
  key: string;
  title: string;
  state?: boolean;
  menuType: string;
  style?: MenuStyle;
  icon?: ResourceStr | PixelMap;
  subTitle?: string;
  onMenuClick?: (index: number) => void;
  onSwitchChanged?: (value: boolean, index: number) => void;
  enabled?: boolean;
  isTouch?: boolean;
  tabIndex?: number;
  isNeedTouchIntercept?: boolean;
  touchInterceptCallback?: () => void;
}

const TAG: string = 'phoneMenuEntry';

/**
 * 子菜单描述
 */
@Observed
export class MenuEntry {
  constructor(params: MenuEntryData) {
    this.key = params.key;
    this.title = params.title;
    this.state = params.state;
    this.menuType = params.menuType;
    this.style = params.style;
    this.icon = params.icon;
    this.subTitle = params.subTitle;
    this.onMenuClick = params.onMenuClick;
    this.onSwitchChanged = params.onSwitchChanged;
    this.enabled = params.enabled;
    this.isTouch = params.isTouch;
    this.tabIndex = params.tabIndex;
    this.isNeedTouchIntercept = params.isNeedTouchIntercept;
    this.touchInterceptCallback = params.touchInterceptCallback;
  }

  /**
   * key，触发刷新用
   */
  public key: string = '';
  /**
   * 标题
   */
  public title: string = '';
  /**
   * switch状态
   */
  public state?: boolean;
  /**
   * 菜单类型
   */
  public menuType: string = '';
  /**
   * 菜单样式
   */
  public style?: MenuStyle;
  /**
   * 图标
   */
  public icon?: ResourceStr | PixelMap;
  /**
   * 右侧数值
   */
  public subTitle?: string = '';
  /**
   * 菜单点击回调
   */
  public onMenuClick?: (index: number) => void;
  /**
   * Switch状态切换回调
   */
  public onSwitchChanged?: (value: boolean, index: number) => void;
  /**
   * toggle禁用状态
   */
  public enabled?: boolean = true;
  /**
   * switch状态
   */
  public isTouch?: boolean;
  /**
   * 自定义组件tab键走焦能力
   */
  public tabIndex?: number;
  /**
   *  是否禁用toggle默认行为
   */
  public isNeedTouchIntercept?: boolean = false;
  /**
   *  禁用toggle后的toggle的行为函数
   */
  public touchInterceptCallback?: () => void = () => {};
}

/**
 * 菜单类型
 */
export enum EntryType {
  /**
   * 纯文本菜单
   */
  TEXT = 'Text',
  /**
   * 文本 + >
   */
  ENTRY = 'Entry',
  /**
   * 文本 + 开关
   */
  SWITCH = 'Switch',
  /**
   * 文本 + 值 + >
   */
  MULTI_ENTRY = 'MultiEntry',
  /**
   * 指纹识别
   */
  IDENTIFY_ENTRY = 'IdentifyEntry',
  /**
   * 屏下指纹识别
   */
  UNDER_IDENTIFY_ENTRY = 'UnderIdentifyEntry'
}

interface ObservedMenuEntryData {
  visible?: boolean;
  showHeader?: boolean;
  headerText?: string;
  menus: MenuEntry[];
  style?: MenuStyle;
}

/**
 * Observed MenuComponent
 */
@Observed
export class ObservedMenuEntry {
  constructor(data?: ObservedMenuEntryData) {
    this.visible = data?.visible;
    this.showHeader = data?.showHeader;
    this.headerText = data?.headerText;
    this.menus = data?.menus ?? [];
  }

  /**
   * 是否显示
   */
  public visible?: boolean;
  /**
   * 显示标题
   */
  public showHeader?: boolean;
  /**
   * 标题
   */
  public headerText?: string;
  /**
   * 菜单集合
   */
  public menus: MenuEntry[] = [];
}

/**
 * 菜单样式
 */
export interface MenuStyle {
  /**
   * 字体大小
   */
  fontSize?: number | string | Resource;

  /**
   * 字体颜色
   */
  fontColor?: ResourceColor | string;

  /**
   * 字体粗细
   */
  fontWeight?: FontWeight | number | string;
}