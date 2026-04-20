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

import Want from '@ohos.app.ability.Want';
import { Controller, PushParam, UiRefresher } from '../../controller/Controller';
import { CustomMenuManager } from '../../../custom/CustomMenuManager';
import { PageController } from '../../controller/MenuController';
import { PageStyle, Style } from './ComponetStyle';
import { LifecycleOwner } from '../../lifecycle/Lifecycle';
import { AccessibilityLevelType } from '../../../utils/AccessibilityUtils';
import { LogUtil } from '../../../utils/LogUtil';
import { DynamicLoader } from '../../../utils/DynamicLoader';
import { ResourceUtil } from '../../../utils/ResourceUtil';

const TAG: string = 'Menu : ';
const IS_DEBUG: boolean = false;

/**
 * Controller构造器接口
 *
 * @since 2022-03-21
 */

export interface ControllerConstructorInter {
  createControllerConstructorInter: (menu: SettingsBaseMenu) => Controller;
}

/**
 * Menu父节点接口
 *
 * @since 2022-03-21
 */
export interface MenuParent {
  getParent(): MenuParent | undefined;

  getKey(): string;

  findMenu(key: string): SettingsBaseMenu | null;

  onChildVisibilityChanged(child: SettingsBaseMenu, isVisible: boolean): void;

  refreshChildren(): void;
}

export interface ServiceBaseEntry {}

export interface extraType {
  want?: Want,
  navEntryKey?: string,
  supportEapMethod?: Array<number>,
  isCurrentVisible?: boolean,
  supportMethod?: Array<Object>,
  listenMenuKey?: string
  selectMenuNameAndValMap?: Map<ResourceStr, number | string>,
  currentSelectedVal?: number,
  serviceState?: boolean,
  name?: string,
  pageUrl?: string,
  isSelected?: boolean,
  proxyMethod?: Object,
  value?: boolean | string | number,
  settingProperty?: string,
  isOn?: boolean,
  radioList?: Array<Object>,
  isClearTitle?: boolean,
  listenMenuKeyArray?: Array<string>,
  registerDataChangeKey?: string[],
  isNoneSelect?: boolean,
  index?: number,
  appIndex?: number,
}

export interface SettingsBaseMenuData {
  parent?: MenuParent;
  key?: string;
  isIconNeedColor?: boolean;
  index?: number;
  menuType?: string;
  style?: Style;
  icon?: ResourceStr | PixelMap;
  title?: ResourceStr;
  summaryImg?: ResourceStr;
  summary?: ResourceStr;
  group?: string;
  state?: ResourceStr;
  stateIcon?: ResourceStr;
  symbolIcon?: ResourceStr;
  startSymbolIcon?: ResourceStr;
  endSymbolIcon?: ResourceStr;
  targetPageUrl?: string;
  isSearchable?: boolean;
  searchKeyWords?: string;
  enable?: boolean;
  status?: boolean;
  controller?: ControllerConstructorInter;
  timestamp?: number;
  extra?: extraType | object | Object;
  pathInfos?: NavPathStack;
  navRouterParam?: PushParam;
  navHeaderStyle?: Style;
  textImg?: ResourceStr;
  badge?: number;
  isGrayed?: boolean;
  isNeedShowIcon?: boolean;
  isNeedShowRedPoint?: boolean;
  isShowConnected?: boolean;
  isSelected?: boolean;
  capabilities?: string;
  tabIndex?: number;
  focusable?: boolean;
  isAccountMenu?: boolean;
  buttonTittleLoading?: ResourceStr;
  appIndex?: number;
  accessibilityLevel?: AccessibilityLevelType;
  accessibilityGroup?: boolean;
  accessibilityDescription?: string;
  accessibilityText?: string;
  stateEffect?: boolean;
  opacity?: number | Resource;
  pressedColor?: ResourceColor;
}

/**
 * 基础Menu数据
 *
 * @since 2022-03-21
 */
export class SettingsBaseMenu implements SettingsBaseMenuData {
  /**
   * 菜单父亲节点
   */
  public parent?: MenuParent;
  /**
   * 菜单在页中的唯一标识符
   */
  public key?: string;
  /**
   * 左侧图标是否适配深色模式
   */
  public isIconNeedColor?: boolean;
  /**
   * 菜单在所在组的位置
   */
  public index?: number = 0;
  /**
   * 菜单类型
   */
  public menuType?: string;
  /**
   * 菜单样式
   */
  public style?: Style;
  /**
   * 图标
   */
  public icon?: ResourceStr | PixelMap;
  /**
   * 应用信息图标
   */
  public textImg?: ResourceStr;
  /**
   * 标题
   */
  public title?: ResourceStr;
  /**
   * 辅助文本图标
   */
  public summaryImg?: ResourceStr;
  /**
   * 辅助文本
   */
  public summary?: ResourceStr;
  /**
   * 辅助文本
   */
  public stateInfo?: ResourceStr;
  /**
   * 状态辅助文本
   */
  public state?: ResourceStr;

  public secondState?: ResourceStr;
  /**
   * 状态图标
   */
  public stateIcon?: ResourceStr;
  /**
   * Symbol状态图标
   */
  public symbolIcon?: ResourceStr;
  /**
   * Symbol状态图标
   */
  public startSymbolIcon?: ResourceStr;
  /**
   * Symbol状态图标
   */
  public endSymbolIcon?: ResourceStr;
  /**
   * 跳转目标页面
   */
  public targetPageUrl?: string;
  /**
   * 是否支持搜索
   */
  public isSearchable?: boolean;
  /**
   * 搜索关键字
   */
  public searchKeyWords?: string;
  /**
   * 按钮组名
   */
  public group?: string;
  /**
   * 是否可用
   */
  public enable?: boolean;
  /**
   * Controller的构造器
   */
  public controller?: ControllerConstructorInter;
  /**
   * 时间戳，标识新旧
   */
  public timestamp?: number = 0;
  /**
   * 应用类型
   */
  public appType?: string;
  /**
   * 状态
   */
  public status?: boolean;
  /**
   * 附加数据
   */
  public extra?: extraType | Object | object;
  public pathInfos?: NavPathStack;
  public navRouterParam?: PushParam;
  /**
   * Nav头部菜单样式
   */
  public navHeaderStyle?: Style;
  /**
   * 角标消息数
   */
  public badge?: number;

  /**
   * 用于演示样机，是否置灰
   */
  public isGrayed?: boolean;

  /**
   * 设置透明度
   */
  public opacity?: number | Resource;

  /**
   * wifi的hilink图标控件是否显示
   */
  public isNeedShowIcon?: boolean;

  /**
   * 菜单栏存在变化的红点标识
   */
  public isNeedShowRedPoint?: boolean;

  /**
   * 是否显示已连接风格
   */
  public isShowConnected?: boolean;

  /**
   * 是否选中
   */
  public isSelected?: boolean;

  public capabilities?: string;

  /**
   * 自定义组件tab键走焦能力
   */
  public tabIndex?: number;

  /**
   * 设置组件是否可获焦
   */
  public focusable?: boolean;

  /**
   * 是否账户菜单
   */
  public isAccountMenu?: boolean;

  /**
   * 应用分身 index
   */
  public appIndex?: number;

  /**
   * 加载中样式按钮
   */
  public buttonTittleLoading?: ResourceStr;

  /**
   * 是否朗读
   */
  public accessibilityLevel?: AccessibilityLevelType;

  /**
   * 是否为朗读组
   */
  public accessibilityGroup?: boolean;

  /**
   * 朗读描述
   */
  public accessibilityDescription?: string;

  /**
   * 朗读内容
   */
  public accessibilityText?: string;

  /**
   * 点击态颜色
   */
  public pressedColor?: ResourceColor;

  /**
   * 按钮是否开启按压态显示
   */
  public stateEffect?: boolean;

  constructor(menu?: Partial<SettingsBaseMenuData>) {
    if (!menu) {
      LogUtil.error(`${TAG} menu params cannot null`);
      return;
    }
    this.parent = menu.parent;
    this.key = menu.key;
    this.isIconNeedColor = menu.isIconNeedColor;
    this.index = menu.index ?? 0;
    this.menuType = menu.menuType;
    this.style = menu.style;
    this.icon = menu.icon;
    this.title = menu.title;
    this.summaryImg = menu.summaryImg;
    this.summary = menu.summary;
    this.state = menu.state;
    this.stateIcon = menu.stateIcon;
    this.symbolIcon = menu.symbolIcon;
    this.startSymbolIcon = menu.startSymbolIcon;
    this.endSymbolIcon = menu.endSymbolIcon;
    this.targetPageUrl = menu.targetPageUrl;
    this.isSearchable = menu.isSearchable;
    this.searchKeyWords = menu.searchKeyWords;
    this.enable = menu.enable ?? true;
    this.controller = menu.controller;
    this.timestamp = menu.timestamp ?? 0;
    this.extra = menu.extra;
    this.group = menu.group;
    this.pathInfos = menu?.pathInfos;
    this.navRouterParam = menu?.navRouterParam;
    this.navHeaderStyle = menu?.navHeaderStyle;
    this.textImg = menu?.textImg;
    this.status = menu?.status ?? true;
    this.badge = menu?.badge;
    this.isGrayed = menu?.isGrayed ?? false;
    this.isNeedShowIcon = menu?.isNeedShowIcon ?? false;
    this.isNeedShowRedPoint = menu?.isNeedShowRedPoint ?? false;
    this.isShowConnected = menu?.isShowConnected ?? false;
    this.isSelected = menu?.isSelected ?? false;
    this.capabilities = menu?.capabilities;
    this.tabIndex = menu?.tabIndex;
    this.focusable = menu?.focusable;
    this.isAccountMenu = menu?.isAccountMenu;
    this.buttonTittleLoading = menu?.buttonTittleLoading;
    this.appIndex = menu?.appIndex || 0;
    this.accessibilityLevel = menu?.accessibilityLevel;
    this.accessibilityGroup = menu?.accessibilityGroup;
    this.accessibilityDescription = menu?.accessibilityDescription;
    this.accessibilityText = menu?.accessibilityText;
    this.stateEffect = menu?.stateEffect ?? true;
    this.opacity = menu?.opacity;
    this.pressedColor = menu?.pressedColor;
  }

  getControllerInstance(uiRefresher: UiRefresher): Controller {
    let controllerInstance = this.getControllerFromPage(this.key as string);
    if (controllerInstance) {
      LogUtil.debug(`${TAG} found controllerInstance: ${this.getLogKey()}`);
      controllerInstance.aboutToDisappear();
    }

    controllerInstance = this.createController() as Controller;
    if (controllerInstance) {
      controllerInstance.bindUi(uiRefresher);
      controllerInstance.aboutToAppear();
    } else {
      LogUtil.warn(`${TAG} controller null, ${this.getLogKey()}`);
    }
    return controllerInstance;
  }

  /**
   * 页面跳转
   *
   * @param key: 页面key
   * @params params: 跳转参数
   */
  pushName(key: string, params: PushParam | undefined) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  /**
   * 页面跳转，指定动效为入场动效
   *
   * @param key: 页面key
   * @params params: 跳转参数
   */
  pushPath(key: string, param: PushParam | undefined) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPath({
        name: key,
        param: param
      }, {
        launchMode: LaunchMode.NEW_INSTANCE
      } as NavigationOptions);
    });
  }

  /**
   * 页面跳转
   *
   * @param key 页面key
   * @param params 跳转参数
   * @param onPop 回调函数
   */
  pushNameWithOnPop(key: string, params: Object, onPop: (popInfo: PopInfo) => void): void {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params, onPop);
    });
  }

  /**
   * 清空跳转路径
   *
   */
  clear() {
    this.pathInfos?.clear();
  }

  /**
   * 创建Controller示例
   */
  createController() {
    if (this.controller) {
      return this.controller.createControllerConstructorInter(this);
    } else {
      return null;
    }
  }

  /**
   * 层级变化回调，如父亲节点发生变化
   *
   * @param parent
   */
  onHierarchyChange(parent: MenuParent | undefined): void {
    if (this.parent != parent) {
      if (!parent) {
        this.deleteControllerFromPage(this.key as string);
      }
      this.parent = parent;
    }
  }

  toString(): string {
    return `key:${this.key}, timestamp:${this.timestamp}, summary: ${ResourceUtil.getStringSync(this.summary)}`;
  }

  toLogString(): string {
    return `key:${this.getLogKey()}, timestamp:${this.timestamp}`;
  }

  print(tag: string = ''): void {
    LogUtil.info(`${TAG} print-menu ${tag} ${this.toLogString()}`);
  }

  getLogKey(): string {
    return this.key as string;
  }

  getParent(): MenuParent {
    return this.parent as MenuParent;
  }

  getRoot(): RootMenu | null {
    let parent: MenuParent | undefined = this.getParent();

    if (!parent) {
      LogUtil.info(`${TAG} getRoot null`);
      return null;
    }

    while (parent?.getParent()) {
      parent = parent?.getParent();
    }

    return (parent instanceof RootMenu) ? parent : null;
  }

  addControllerToPage(key: string, controller: Controller): void {
    LogUtil.debug(`${TAG} addControllerToPage`);
    let root = this.getRoot();
    if (root) {
      root.addController(key, controller);
    }
  }

  deleteControllerFromPage(key: string): void {
    LogUtil.debug(`${TAG} deleteControllerFromPage ${this.getLogKey()}`);
    let root = this.getRoot();
    if (root) {
      root.deleteController(key);
    }
  }

  getControllerFromPage(key: string): Controller {
    let root = this.getRoot();
    let controller = root ? root.getController(key) : null;
    return controller as Controller;
  }

  getController(): Controller {
    return this.getControllerFromPage(this.key as string);
  }

  onVisibilityChange(isVisible: boolean): void {
    this.getParent()?.onChildVisibilityChanged(this, isVisible);
  }

  refreshUi(): void {
    this.getControllerFromPage(this.key as string)?.refreshUi();
  }

  isVisible(): boolean {
    let controller: Controller = this.getControllerFromPage(this.key as string);
    return controller ? controller.isVisibleStatus() : true;
  }

  setSummary(summary: ResourceStr): void {
    if (this.summary != summary) {
      this.summary = summary;
      this.refreshUi();
    }
  }

  setStyle(style: Style): void {
    if (this.style != style) {
      this.style = style;
      this.refreshUi();
    }
  }

  setIcon(icon: ResourceStr): void {
    if (this.icon != icon) {
      this.icon = icon;
      this.refreshUi();
    }
  }

  setSymbolIcon(symbolIcon: ResourceStr): void {
    if (this.symbolIcon != symbolIcon) {
      this.symbolIcon = symbolIcon;
      this.refreshUi();
    }
  }

  static printMenuList(menus: Array<SettingsBaseMenu>, tag: string = ''): void {
    for (let index = 0; index < menus.length; index++) {
      let menu: SettingsBaseMenu = menus[index];
      menu.print(tag);
    }
  }
}

export interface MenuGroupData extends SettingsBaseMenuData {
  pageStyle?: PageStyle;
}

/**
 * Menu数据组容器
 *
 * @since 2022-03-21
 */
export class MenuGroup extends SettingsBaseMenu implements MenuParent, MenuGroupData {
  public menus: Array<SettingsBaseMenu> = [];
  public pageStyle?: PageStyle;

  constructor(params?: Partial<MenuGroupData>, menus?: Array<SettingsBaseMenu>) {
    super(params);
    if (menus) {
      this.addMenus(menus);
    }
  }

  print(tag: string = ''): void {
    LogUtil.info(`${TAG} print-menu ${tag} ${this.toLogString()} length: ${this.menus.length}`);
    if (this.menus.length === 0) {
      return;
    }

    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      menu.print(tag + '    ');
    }
  }

  getParent(): MenuParent {
    return this.parent as MenuParent;
  }

  getKey(): string {
    return this.key as string;
  }

  getLogKey(): string {
    return this.getKey();
  }

  onChildVisibilityChanged(child: SettingsBaseMenu, isVisible: boolean): void {
    this.getController()?.updateVisibleStatus();
    this.refreshUi();
  }

  onHierarchyChange(parent: MenuParent | undefined): void {
    super.onHierarchyChange(parent as MenuParent);
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      menu.onHierarchyChange(this as MenuParent);
    }
  }

  addMenuAndSort(addMenu: SettingsBaseMenu): void {
    this.addMenu(addMenu);
    this.sortSelf();
  }

  addMenu(addMenu?: SettingsBaseMenu): void {
    if (!addMenu || !addMenu.key) {
      LogUtil.error(`${TAG} addMenu or key empty`);
      return
    }

    if (!addMenu.index) {
      addMenu.index = this.menus.length;
    }

    this.menus.push(addMenu);
    addMenu.onHierarchyChange(this as MenuParent);
  }

  addMenuToShift(addMenusToShift?: SettingsBaseMenu): void {
    if (!addMenusToShift || !addMenusToShift.key) {
      LogUtil.error(`${TAG} addMenusToShift or key empty`);
      return;
    }
    if (!addMenusToShift.index) {
      addMenusToShift.index = this.menus.length;
    }
    this.menus.unshift(addMenusToShift);
    addMenusToShift.onHierarchyChange(this as MenuParent);
  }

  removeMenu(key: string): boolean {
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      if (menu.key === key) {
        this.menus.splice(index, 1);
        if (menu instanceof MenuGroup) {
          menu.clear(false);
        }
        menu.onHierarchyChange(undefined);
        return true;
      }
    }
    return false;
  }

  /**
   * 更新菜单数据
   *
   * @param updateMenus 新的菜单数据
   */
  updateMenus(updateMenus: Array<SettingsBaseMenu>): void {
    let lastMenus = new Set(this.menus.map(menu => menu.toString()));
    this.menus = [];

    if (!updateMenus || updateMenus.length === 0) {
      LogUtil.info(`${TAG} updateMenus empty`);
      return
    }
    for (let updateMenu of updateMenus) {
      if (updateMenu) {
        this.menus.push(updateMenu);
        if (!lastMenus.has(updateMenu.toString())) {
          updateMenu.onHierarchyChange(this as MenuParent);
        }
      }
    }
    LogUtil.info(`${TAG} old size: ${lastMenus.size}, new size: ${this.menus.length}`);
  }

  /**
   * 清空菜单数据
   *
   * @param isOnlyContent 是否只清空内容区
   */
  clear(isOnlyContent: boolean = true): void {
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      if (menu instanceof MenuGroup) {
        menu.clear(isOnlyContent);
      }
      menu.onHierarchyChange(undefined);
    }
    this.menus = [];
  }

  addMenusAndSort(addMenus: Array<SettingsBaseMenu>): void {
    this.addMenus(addMenus);
    this.sort();
  }

  addMenus(addMenus: Array<SettingsBaseMenu>): void {
    if (!addMenus || addMenus.length === 0) {
      LogUtil.warn(`${TAG} addMenus empty ${addMenus?.length}`);
      return
    }

    for (let index = 0; index < addMenus.length; index++) {
      let menu: SettingsBaseMenu = addMenus[index];
      if (CustomMenuManager.getInstance().isMenuHide(menu.key)) {
        continue;
      }
      this.addMenu(menu);
    }
  }

  addMenusToShift(addMenusToShifts: Array<SettingsBaseMenu>): void {
    if (!addMenusToShifts || addMenusToShifts.length == 0) {
      return;
    }

    for (let index = 0; index < addMenusToShifts.length; index++) {
      let menu: SettingsBaseMenu = addMenusToShifts[index];
      if (CustomMenuManager.getInstance().isMenuHide(menu.key)) {
        continue;
      }
      this.addMenuToShift(menu);
    }
  }

  getMenus(): Array<SettingsBaseMenu> {
    return this.menus;
  }

  private sortSelf(): void {
    if (this.menus.length === 0) {
      LogUtil.info(`${TAG} sort menus empty`);
      return;
    }
    this.menus.sort(this.compareMenu);
  }

  sort(): void {
    if (this.menus.length === 0) {
      LogUtil.info(`${TAG} sort menus empty`);
      return;
    }
    this.sortSelf();

    // sort children group.
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      if (menu instanceof MenuGroup) {
        menu.sort();
      }
    }
  }

  private compareMenu(menu1: SettingsBaseMenu, menu2: SettingsBaseMenu) {
    if (!menu1) {
      return -1;
    }
    if (!menu2) {
      return 1;
    }
    let a = menu1?.index as number;
    let b = menu2?.index as number;
    return a - b;
  }

  findMenu(key: string): SettingsBaseMenu | null {
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      if (menu.key === key) {
        return menu;
      }
      if (menu instanceof MenuGroup) {
        let foundMenu = menu.findMenu(key);
        if (foundMenu) {
          return foundMenu;
        }
      }
    }
    return null;
  }

  refreshChildren(): void {
    for (let index = 0; index < this.menus.length; index++) {
      let menu: SettingsBaseMenu = this.menus[index];
      menu?.refreshUi();
      if (menu instanceof MenuGroup) {
        return menu.refreshChildren();
      }
    }
  }
}

export interface MenuSectionData extends MenuGroupData {
  headerMenu?: MenuGroup;
  footerMenu?: MenuGroup;
}

/**
 * Menu数据分段
 *
 * @since 2022-03-21
 */
export class MenuSection extends MenuGroup {
  private headerMenu?: MenuGroup;
  private footerMenu?: MenuGroup;

  constructor(params?: Partial<MenuSectionData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (params) {
      this.setHeader(params.headerMenu as MenuGroup);
      this.setFooter(params.footerMenu as MenuGroup);
    }
  }

  setHeader(headerMenu?: MenuGroup): void {
    if (this.headerMenu) {
      this.headerMenu.onHierarchyChange(undefined);
    }
    this.headerMenu = headerMenu;
    if (headerMenu) {
      headerMenu.onHierarchyChange(this as MenuParent);
    }
  }

  getHeader(): MenuGroup {
    return this.headerMenu as MenuGroup;
  }

  setFooter(footerMenu?: MenuGroup): void {
    if (this.footerMenu) {
      this.footerMenu.onHierarchyChange(undefined);
    }
    this.footerMenu = footerMenu;
    if (footerMenu) {
      footerMenu.onHierarchyChange(this as MenuParent);
    }
  }

  getFooter(): MenuGroup {
    return this.footerMenu as MenuGroup;
  }

  findMenu(key: string): SettingsBaseMenu | null {
    let menu = super.findMenu(key);
    if (menu) {
      return menu;
    }
    menu = this.headerMenu?.findMenu(key) as SettingsBaseMenu;
    if (menu) {
      return menu;
    }
    return this.footerMenu?.findMenu(key) as SettingsBaseMenu;
  }

  clear(isOnlyContent: boolean = true): void {
    if (isOnlyContent) {
      super.clear(isOnlyContent);
      return;
    }
    this.headerMenu?.clear(isOnlyContent);
    this.footerMenu?.clear(isOnlyContent);
  }

  refreshChildren(): void {
    this.headerMenu?.refreshChildren();
    super.refreshChildren();
    this.footerMenu?.refreshChildren();
  }

  sort(): void {
    this.headerMenu?.sort();
    super.sort();
    this.footerMenu?.sort();
  }

  print(tag: string = ''): void {
    this.headerMenu?.print('Header : ');
    super.print(`${tag} Menus : `);
    this.footerMenu?.print('Footer : ');
  }
}

export interface MenuPageData extends MenuSectionData {
  pageUrl?: string;
  targetPageUrl?: string;
  isShowBack?: boolean;
  isShowAbout?: boolean;
  isShowClose?: boolean;
  topAreaHeight?: number;
  titleMaxLine?: number;
  isStartAbility?: boolean;
  isPrivacy?: boolean;
  isNavigation?: boolean;
  showHeader?: boolean;
  isOutPage?: boolean;
  scrollable?: boolean;
}

/**
 * Menu数据页
 *
 * @since 2022-03-21
 */
@Observed
export class MenuPage extends MenuSection {
  public pageUrl: string = '';
  public isShowBack?: boolean;
  public isShowAbout?: boolean;
  public isShowClose?: boolean;
  public topAreaHeight?: number;
  public titleMaxLine?: number;
  public isStartAbility?: boolean;
  public isPrivacy?: boolean;
  public isNavigation?: boolean;
  public showHeader: boolean = true;
  public isOutPage: boolean = false;
  public scrollable?: boolean = true;

  constructor(params?: Partial<MenuPageData>, menus?: Array<SettingsBaseMenu>) {
    super(params, menus);
    if (params) {
      this.isNavigation = params.isNavigation ?? false;
      this.pageUrl = params.pageUrl as string;
      this.targetPageUrl = params.targetPageUrl as string;
      this.isShowBack = params.isShowBack;
      this.isShowAbout = params.isShowAbout;
      this.isShowClose = params.isShowClose;
      this.topAreaHeight = params.topAreaHeight;
      this.titleMaxLine = params.titleMaxLine;
      this.isStartAbility = params.isStartAbility;
      this.showHeader = params?.showHeader ?? true;
      this.isOutPage = params?.isOutPage ?? false;
      this.scrollable = params?.scrollable ?? true;
      if (!this.key) {
        this.key = this.pageUrl;
        if (!this.controller) {
          this.controller = {
            createControllerConstructorInter: PageController.createPageController,
          };
        }
      }
    }
  }

  onChildVisibilityChanged(child: SettingsBaseMenu, isVisible: boolean): void {
    this.getParent()?.onChildVisibilityChanged(child, isVisible);
  }
}

/**
 * 根Menu数据
 *
 * @since 2022-03-21
 */
export abstract class RootMenu implements MenuParent {
  abstract getLifecycleOwner(): LifecycleOwner;

  abstract getParent(): MenuParent | undefined;

  abstract findMenu(key: string): SettingsBaseMenu;

  abstract refreshChildren(): void;

  abstract onChildVisibilityChanged(child: SettingsBaseMenu, isVisible: boolean): void;

  abstract isFirstVisibleChild(child: SettingsBaseMenu): boolean;

  abstract isFirstVisibleContentChild(child: SettingsBaseMenu): boolean;

  abstract getFirstVisibleMenu(menu: SettingsBaseMenu): SettingsBaseMenu | undefined;

  abstract getListFirstVisibleMenu(menus: SettingsBaseMenu[]): SettingsBaseMenu | undefined;

  abstract getKey(): string;

  abstract getMenuPage(): MenuPage;

  abstract addController(key: string, controller: Controller): void;

  abstract deleteController(key: string): void;

  abstract getController(key: string): Controller;

  abstract getControllers(): IterableIterator<Controller>;

  abstract scrollToIndex(index: number): void;

  abstract openDialog(menuPage: MenuPage, autoCancel?: boolean): void;

  abstract closeDialog(): void;

  abstract closeSelf(data?: Object | undefined): void;

  abstract registerControllerObserver(changerKey: string, observerKey: string): void;

  abstract unRegisterControllerObserver(changerKey: string, observerKey: string): void;

  abstract publishControllerDataChange(changerKey: string, data: Object | undefined): void;

  abstract scrollEdge(edge: Edge): void;

  abstract getDialogControllersCount(): number;
}

/**
 * 铃声模式
 *
 * @since 2024-01-06
 */
export enum AudioRingMode {
  RINGER_MODE_SILENT = 0,
  RINGER_MODE_VIBRATE = 1,
  RINGER_MODE_NORMAL = 2,
}