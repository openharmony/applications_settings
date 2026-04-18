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
import { SettingContentModel, SettingGroupModel } from './SettingGroupModel';
import { SettingIconModel, SettingMenuStyle } from './SettingItemModel';
import { SettingTabsModel } from './SettingTabsModel';

export enum PageType {
  /*
   * 自定义页面
   */
  PAGE_TYPE_CUSTOM = 0,

  /*
   * 标准页面
   */
  PAGE_TYPE_STANDARD = 1,

  /*
   * 首页
   */
  PAGE_TYPE_HOME = 2,

  /*
   * 模态页面，需绑定到设置项上
   */
  PAGE_TYPE_MODAL = 3,

  /*
   * 动态页面，支持动态配置Group组
   */
  PAGE_TYPE_DYNAMIC = 4,
}

export interface SettingPageLayout {
  /*
   * 页面背景颜色
   */
  backgroundColor?: ResourceColor;

  blurStyle?: BlurStyle;
  /*
   * 页面内间距
   */
  padding?: LocalizedPadding;
  /*
   * 页面宽高限制
   */
  constraintSize?: ConstraintSizeOptions;

  hideTitleBar?: boolean;

  barState?: BarState;
  /*
  * 页面菜单项排列顺序
  */
  pageAlign?: Alignment;
}

export interface ListScrollListener {
  onScrollStart?: () => void;
  onScrollStop?: () => void;
  onReachStart?: () => void;
  onScroll?: (scrollOffset: number, scrollState: ScrollState) => void;
}

export interface SettingPageMenu extends SettingIconModel {
  bindMenu?: MenuElement[];
  menuStyle?: SettingMenuStyle;
  onClick?: () => void;
  builder?: WrappedBuilder<[object]>;
  popup?: PopupOptions;
}

export interface SettingPageModel extends SettingBaseModel {
  url: string;
  type: PageType;
  title?: ResourceStr;
  titleBar?: SettingBaseModel;
  header?: SettingContentModel;
  footer?: SettingContentModel;
  layout?: SettingPageLayout;
  scrollListener?: ListScrollListener;
  menus?: SettingPageMenu[];
  fixedGroups?: SettingGroupModel[];
  groups?: SettingGroupModel[];
  groupForeground?: SettingContentModel;
  stickBottomContent?: SettingContentModel;
  tabs?: SettingTabsModel[];
  onTabSelected?: (selectedIndex: number) => void;
  titleIcon?: ResourceStr;
  closeIconAction?: SettingSheetTitleIcon;
  backIconAction?: SettingSheetTitleIcon;
  barState?: BarState;

  /*
   * 判断是否显示退出键，不显示返回false
   */
  showBackIcon?: boolean;

  /**
   * 当前已设置的走焦顺序
   */
  tempTabIndex?: number;

  /**
   * 选中的Tab页面
   */
  selectTabIndex?: number[];

  /**
   * 分帧加载总加载帧数
   */
  frameCount?: number;

  /**
   * 点击事件回调接口
   * @param touchType
   */
  onTouchEvent?: (touchType: TouchType) => void;

  /**
   * HdsNavDestination ux样式
   */
  hdsNavDestinationUx?: boolean;
}

export interface SettingSheetPageContext {
  itemComp: SettingBaseModel;
  pathStack?: NavPathStack;
  param?: object;
}

export interface SettingSheetTitleIcon {
  icon: ResourceStr;
  action: () => void;
}

export class DefaultSettingPageModel implements SettingPageModel {
  public id: string = '';
  public title: ResourceStr = '';
  public url: string = '';
  public type: PageType = PageType.PAGE_TYPE_STANDARD;

  private static instance: DefaultSettingPageModel;
  private constructor() {
  }
  public static get(): DefaultSettingPageModel {
    if (!DefaultSettingPageModel.instance) {
      DefaultSettingPageModel.instance = new DefaultSettingPageModel();
    }
    return DefaultSettingPageModel.instance;
  }
}
