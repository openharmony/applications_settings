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

import router from '@ohos.router';
import bundle from '@ohos.bundle';
import bundleManager from '@ohos.bundle.bundleManager';
import Want from '@ohos.app.ability.Want';
import systemParameter from '@ohos.systemparameter';
import {
  SettingsBaseMenu,
  MenuGroup,
  MenuPage,
  extraType,
  AudioRingMode
} from '../model/menu/SettingsMenu';
import { Controller, PushParam, UiRefresher } from './Controller';
import { LogUtil } from '../../utils/LogUtil';
import { AbilityUtils } from '../../utils/AbilityUtils';
import { HiSysEventUtil } from '../../systemEvent/HiSysEventUtil';
import { NavEntryKey } from '../../utils/Consts';
import { DynamicLoader } from '../../utils/DynamicLoader';
import { PackagesConstant } from '../../constant/PackagesConstant';
import { CheckEmptyUtils } from '../../utils/CheckEmptyUtils';
import { DeviceStateUtils } from '../../utils/BaseUtils';
import { SystemParamUtil } from '../../utils/SystemParamUtil';
import { HiSysApplicationsAndServicesEventGroup } from '../../systemEvent/BehaviorEventConsts';

const ENTER_EXTERNAL_ENTRY: string = 'enter_external_entry';
const ENTER_INTERNAL_BUTTON: string = 'enter_internal_button';
const SLIDER_MAX_100: number = 100;
const SLIDER_VALUE_0: number = 0;
const SLIDER_STEP_1: number = 1;
export const PRODUCT_MODEL: string = 'const.product.model';
export const PRODUCT_MODEL_EMULATOR: string = 'emulator';
export const PRODUCT_DEVICE_TYPE: string = 'const.product.devicetype';
export const PRODUCT_DEVICE_TYPE_PHONE: string = 'phone';
export const PRODUCT_CPU_ABILITST: string = 'const.product.cpu.abilist';
export const PRODUCT_CPU_ABILITST_X86_64: string = 'x86_64';
export const DORMANCY_SETTINGS: string = 'dormancy_settings';
export const VASSISTANT_GROUP: string = 'vassistant_group';
const DISPLAY_NAME_SYS_PARAM_KEY: string = 'const.product.software.version.name';
const DEVELOP_VERSION: string = 'Developer';
const SYSTEM_NAME: string = 'system_name';
const DOUBLE_SPACE_PARAM_KEY = 'persist.space_mgr_service.enterprise_space_enable';

/**
 * 双空间参数
 */
enum DoubleSpaceParamEnum {
  DOUBLE_SPACE = 'true',
  NORMAL_VERSION = 'false',
}

/**
 * 基础菜单控制器
 *
 * @since 2022-03-21
 */
export class MenuController extends Controller {
  public tag: string = 'MenuController : ';
  public menu: SettingsBaseMenu;
  protected isRegister: boolean = false;
  protected isVisible: boolean = true;
  private isRender: boolean = true;
  private uiRefresher: UiRefresher | null = null;
  private changeFlag: boolean = false;
  protected navPathInfo: NavPathStack | undefined | null = undefined;
  protected navRouterParam: PushParam | undefined | null = undefined
  public firstMenu: SettingsBaseMenu | undefined = undefined;
  public isRespondTouchEvent: boolean = true;
  public isClicked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super();
    this.menu = menu;
  }

  static CreateMenuController(menu: SettingsBaseMenu): Controller {
    return new MenuController(menu);
  }

  /**
   * 控制器的key就是菜单的key,有敏感信息时不允许打印，打印使用getLogKey
   */
  getKey(): string {
    return this.menu?.key as string;
  }

  /**
   * 控制器的log key就是菜单的log key
   */
  getLogKey(): string {
    return this.menu?.getLogKey();
  }

  /**
   * 触发刷新一次UI
   */
  refreshUi(): void {
    this.uiRefresher?.refreshUi();
    let currentFirstMenu: SettingsBaseMenu | undefined = this.getFirstMenu();
    if (this.firstMenu && currentFirstMenu && this.firstMenu !== currentFirstMenu) {
      this.firstMenu.getController()?.refreshUi();
      currentFirstMenu.getController()?.refreshUi();
      this.firstMenu = currentFirstMenu;
    }
  }

  refreshFontStyle(): void {
    this.uiRefresher?.refreshFontStyle();
  }

  onKeyEvent(event: KeyEvent): void {
    LogUtil.info(`${this.tag} onKeyEvent `);
  }

  onMouseEvent(event: MouseEvent): void {
    LogUtil.info(`${this.tag} onMouseEvent `);
  }

  /**
   * 绑定当前UI
   *
   * @param uiRefresher UI刷新器
   */
  bindUi(uiRefresher: UiRefresher | null): void {
    this.uiRefresher = uiRefresher as UiRefresher;
  }

  aboutToAppear(): void {
    LogUtil.debug(`${this.tag} aboutToAppear ${this.getLogKey()}`);
    this.menu?.addControllerToPage(this.getKey(), this);
    this.updateStatus();
    this.registerDataChangeSafety();
    this.firstMenu = this.getFirstMenu();
  }

  aboutToDisappear(): void {
    LogUtil.debug(`${this.tag} aboutToDisappear ${this.getLogKey()}`);
    this.bindUi(null);
    this.menu?.deleteControllerFromPage(this.getKey());
    this.unRegisterDataChangeSafety();
  }

  onPageDestroy(): void {
    this.unRegisterDataChangeSafety();
  }

  onMenuClick(): boolean {
    return false;
  }

  onMenuIconClick(): boolean {
    return false;
  }

  updateStatus(): void {
    this.updateVisibleStatus();
  }

  updateVisibleStatus(): boolean {
    let isVisible = this.getCurrentVisibleStatus();
    this.setVisible(isVisible);
    return this.isVisible;
  }

  /**
   * 获取实时的显隐状态
   */
  getCurrentVisibleStatus(): boolean {
    return this.isVisible;
  }

  /**
   * 获取保存的显隐状态
   */
  isVisibleStatus(): boolean {
    return this.isVisible;
  }

  /**
   * 设置显隐状态
   */
  setVisible(isVisible: boolean): void {
    if (this.isVisible !== isVisible) {
      this.isVisible = isVisible;
      this.menu?.onVisibilityChange(this.isVisible);
    }
    this.uiRefresher?.setVisible(this.isVisible);
  }

  /**
   * 设置uiRefresher显隐状态
   */
  setRefresherVisible(isVisible: boolean) {
    this.uiRefresher?.setVisible(isVisible);
  }

  /**
   * 设置是否渲染
   *
   * @param isRender 是否渲染标记位
   */
  setRender(isRender: boolean): void {
    if (this.isRender !== isRender) {
      this.isRender = isRender;
    }
    this.uiRefresher?.setRender(this.isRender);
  }

  /**
   * 刷新Render值
   */
  refreshRender(): void {
    this.uiRefresher?.setRender(!this.uiRefresher.isRender);
  }

  private registerDataChangeSafety(): void {
    if (this.isRegister) {
      return;
    }
    this.registerDataChange();
    this.isRegister = true;
  }

  private unRegisterDataChangeSafety(): void {
    if (!this.isRegister) {
      return;
    }
    this.unRegisterDataChange();
    this.isRegister = false;
  }

  private getFirstMenu():SettingsBaseMenu | undefined {
    if (!this.menu) {
      return undefined;
    }
    if (this.menu instanceof MenuGroup) {
      for (let menu of this.menu.menus) {
        if (menu instanceof MenuGroup) {
          continue;
        } else {
          return menu;
        }
      }
    }
    return undefined;
  }

  /**
   * 注册事件监听时使用
   */
  protected registerDataChange(): void {
  }

  /**
   * 反注册事件监听时使用
   */
  protected unRegisterDataChange(): void {
  }

  /**
   * 注册当前页其他Controller的数据变化监听
   */
  registerControllerDataChange(controllerKey: string): void {
    this.menu?.getRoot()?.registerControllerObserver(controllerKey, this.getKey());
  }

  /**
   * 反注册当前页其他Controller的数据变化监听
   */
  unRegisterControllerDataChange(controllerKey: string): void {
    this.menu?.getRoot()?.unRegisterControllerObserver(controllerKey, this.getKey());
  }

  /**
   * 发布数据变化，其他正在监听的Controller会收到onDataChange回调
   *
   * @param data
   */
  publishDataChange(data: Object | undefined): void {
    this.menu?.getRoot()?.publishControllerDataChange(this.getKey(), data);
  }

  /**
   * 当前页其他Controller的数据变化回调
   *
   * @param fromKey 消息发送的Controller的Key
   * @param data 消息内容
   */
  onDataChange(fromKey: string, data: Object): void {
    LogUtil.info(`${this.tag} onDataChange `);
  }

  /**
   * 被其他Controller监听时的回调
   *
   * @param observerKey 其他正在监听的Controller的key
   */
  onRegisteredByObserver(observerKey: string): void {
    LogUtil.info(`${this.tag} onRegisteredByObserver `);
  }

  scrollToIndex(index: number): void {
    this.menu?.getRoot()?.scrollToIndex(index);
  }

  scrollEdge(edge: Edge): void {
    this.menu?.getRoot()?.scrollEdge(edge);
  }

  /**
   * 打开当前页面的弹框
   */
  openDialog(menuPage: MenuPage, autoCancel?: boolean): void {
    this.menu?.getRoot()?.openDialog(menuPage, autoCancel);
  }

  /**
   * 关闭当前页面的弹框
   */
  closeDialog(): void {
    this.menu?.getRoot()?.closeDialog();
  }

  /**
   * 关闭自己显示在的弹框
   */
  closeSelf(data?: Object): void {
    this.menu?.getRoot()?.closeSelf(data);
  }

  handleHoverButtonClick(): void {
    LogUtil.info(`${this.tag} handleHoverButtonClick `);
  }

  handleHoverEvent(isHovered: boolean): void {
    LogUtil.info(`${this.tag} handleHoverEvent `);
  }

  isComponentHovered(): boolean {
    return false;
  }

  /**
   * 获取menu当前的显隐状态
   *
   * @param menu 菜单数据
   */
  static isMenuVisible(menu: SettingsBaseMenu): boolean {
    let controller: Controller | undefined = menu?.getRoot()?.getController(menu?.key as string);
    if (!controller) {
      return true;
    }
    return controller.isVisibleStatus();
  }

  /**
   * 适配arkui新框架的刷新接口，某些情况下refreshUi无法刷新的时候需要使用该方法
   */
  notifyChange(): void {
    this.changeFlag = !this.changeFlag;
  }
}

export class PwdLinkHwAccountMenuController extends MenuController {
  public isRealNameFlagShow: boolean = false;
  public realAnonymousName: string = '';

  static CreatePwdLinkHwAccountMenuController(menu: SettingsBaseMenu): Controller {
    return new PwdLinkHwAccountMenuController(menu);
  }

  /**
   * 获取实名标识的显隐状态
   */
  getRealNameFlagShowStatus(): boolean {
    LogUtil.info(`${this.tag} getRealNameFlagShowStatus isRealNameFlagShow: ${this.isRealNameFlagShow}`);
    return this.isRealNameFlagShow;
  }

  /**
   * 设置实名标识的显隐状态
   */
  setRealNameFlagShow(isVisible: boolean): void {
    if (this.isRealNameFlagShow !== isVisible) {
      this.isRealNameFlagShow = isVisible;
    }
  }

  /**
   * 获取实名标识的显隐状态
   */
  getRealAnonymousName(): string {
    return this.realAnonymousName;
  }

  /**
   * 设置实名标识的显隐状态
   */
  setRealAnonymousName(realAnonymousName: string): void {
    this.realAnonymousName = realAnonymousName;
  }
}

export class CanvasMenuController extends MenuController {
  public tag: string = 'CanvasMenuController : ';
  protected renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  protected canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);

  static CreateCanvasMenuController(menu: SettingsBaseMenu): Controller {
    return new CanvasMenuController(menu);
  }

  public getCanvasRenderingContext(): CanvasRenderingContext2D {
    return this.canvasRenderingContext;
  }

  onCanvasReady() {
    LogUtil.info(`${this.tag} onCanvasReady`);
  }

  onCanvasDisappear() {
    LogUtil.info(`${this.tag} onCanvasDisappear`);
  }
}

/**
 * 开关菜单控制器
 *
 * @since 2022-03-21
 */
export class SwitchMenuController extends MenuController {
  public tag: string = 'SwitchMenuController : ';
  public isChecked: boolean = true;
  private isToggleEnable: boolean = true;

  updateStatus(): void {
    LogUtil.info(`${this.tag} updateStatus`);
    super.updateStatus();
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    let isToggleEnable = this.updateToggleState();
    this.setToggleState(isToggleEnable);
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    return this.isChecked;
  }

  protected updateToggleState(): boolean {
    return this.isToggleEnable;
  }

  onToggleChange(isOn: boolean): boolean | undefined {
    LogUtil.info(`${this.tag} onToggleChange ${isOn}`);

    // isOn 可能是 0/1 , 必须转换成boolean值 true/false, 否则开关控件不兼容，有异常
    let booleanValue = Boolean(isOn).valueOf();

    if (!this.handleCheckedChange(booleanValue)) {
      LogUtil.info(`${this.tag} handleCheckedChange fail`);
      this.refreshUi();
      return false;
    }

    this.isChecked = booleanValue;
    return true;
  }

  /**
   * 返回开关的保存状态
   */
  getChecked(): boolean {
    LogUtil.info(`${this.tag} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  getToggleState(): boolean {
    LogUtil.info(`${this.tag} getToggleState ${this.isToggleEnable}`);
    return this.isToggleEnable;
  }

  /**
   * 设置开关的状态
   */
  setChecked(isChecked: boolean): void {
    LogUtil.info(`${this.tag} setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.info(`${this.tag} setChecked, refresh : ${this.isChecked}`);
      this.refreshUi();
    }
  }

  setToggleState(isToggleEnable: boolean, isRequestFocus: boolean = false): void {
    LogUtil.info(`${this.tag} setToggleState ${isToggleEnable}`);
    if (this.isToggleEnable !== isToggleEnable) {
      this.isToggleEnable = isToggleEnable;
      LogUtil.info(`${this.tag} setToggleState, refresh : ${this.isToggleEnable}`);
      if (isRequestFocus) {
        LogUtil.info(`${this.tag} requestFocus entry_toggle_${this.menu.key}`);
        focusControl.requestFocus(`entry_toggle_${this.menu.key}`);
      }
      this.refreshUi();
    }
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    return true;
  }
}

/**
 * 页控制器
 *
 * @since 2023-02-27
 */
@Observed
export class PageController extends MenuController {
  public tag: string = 'PageController : ';

  static createPageController(menu: SettingsBaseMenu): Controller {
    return new PageController(menu);
  }
}

/**
 * 滑动条菜单控制器
 *
 * @since 2022-03-21
 */
export class SliderMenuController extends MenuController {
  public tag: string = 'SliderMenuController : ';

  protected sliderValue: number = SLIDER_VALUE_0;

  getSliderMin(): number {
    return 0;
  }

  /**
   * UX设计指定大小
   * @returns
   */
  getSliderMax(): number {
    return SLIDER_MAX_100;
  }

  getSliderStep(): number {
    return SLIDER_STEP_1;
  }

  /**
   * 保存值
   */
  getSliderValue(): number {
    return this.sliderValue;
  }

  /**
   * 实时值
   */
  protected updateSliderValue(): number {
    return this.sliderValue;
  }

  /**
   * 设置当前值
   *
   * @param sliderValue
   */
  setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue;
      this.refreshUi();
    }
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    this.sliderValue = sliderValue;
    return true;
  }

  updateStatus(): void {
    super.updateStatus();
    this.setSliderValue(this.updateSliderValue());
  }

  onStartIconClick(): void {
  }

  onEndIconClick(): void {
  }
}

/**
 * 输入框菜单控制器
 *
 * @since 2022-03-21
 */
export class TextInputMenuController extends MenuController {
  public tag: string = 'TextInputMenuController : ';
  private textInputController: TextInputController = new TextInputController();

  onTextInputChange(input: string): void {
    LogUtil.info(`${this.tag} onTextInputChange `);
  }

  onEditChange(isEditing: boolean): void {
    LogUtil.info(`${this.tag} onEditChange `);
  }

  onSubmit(enterKey: EnterKeyType): void {
    LogUtil.info(`${this.tag} onSubmit `);
  }

  setTextInputController(textInputController: TextInputController): void {
    this.textInputController = textInputController;
  }

  getTextInputController(): TextInputController {
    return this.textInputController;
  }
}

/**
 * 密码圆圈菜单控制器
 *
 * @since 2023-01-10
 */
export class PasswordCircleController extends MenuController {
  public tag: string = 'PasswordCircleController : ';
  protected maxLength: number = 6;

  getTextInputKey(): string {
    return '';
  }

  onTextInputChange(input: string): void {
    LogUtil.info(`${this.tag} onTextInputChange `);
  }

  onSubmit(enterKey: EnterKeyType): void {
    LogUtil.info(`${this.tag} onSubmit `);
  }

  getPasswordCircle(): Array<string> {
    return [];
  }

  getPassword(): string {
    return '';
  }

  setMaxLength(maxLength: number): void {
    this.maxLength = maxLength;
  }

  getMaxLength(): number {
    return this.maxLength;
  }

  isFocus(): boolean {
    return true;
  }
}

/**
 * 按钮菜单控制器，最多支持3个按钮
 *
 * @since 2022-03-21
 */
export class ButtonMenuController extends MenuController {
  public tag: string = 'ButtonMenuController : ';

  onButton1Click(): void {
    if (this.menu?.targetPageUrl) {
      HiSysEventUtil.reportButtonEvent(ENTER_INTERNAL_BUTTON, this.menu.targetPageUrl);
      router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  onButton2Click(): void {
    LogUtil.info(`${this.tag} onButton2Click `);
  }

  onButton3Click(): void {
    LogUtil.info(`${this.tag} onButton3Click `);
  }

  isButton1Enabled(): boolean {
    return true;
  }

  isButton2Enabled(): boolean {
    return true;
  }

  isButton3Enabled(): boolean {
    return true;
  }

  onKeyEvent(event: KeyEvent): void {
    LogUtil.info(`${this.tag} onKeyEvent `);
  }
}

export class NavButtonMenuController extends ButtonMenuController {
  onButton1Click(): void {
    if (this.menu?.targetPageUrl) {
      HiSysEventUtil.reportButtonEvent(ENTER_INTERNAL_BUTTON, this.menu.targetPageUrl);
      this.menu.pushName(this.menu.key as string, undefined);
    }
  }
}

/**
 * Dialog中的按钮菜单控制器
 *
 * @since 2022-11-14
 */
export class DialogButtonMenuController extends ButtonMenuController {
  public tag: string = 'DialogButtonMenuController : ';

  static CreateDialogButtonMenuController(menu: SettingsBaseMenu): Controller {
    return new DialogButtonMenuController(menu);
  }

  onButton1Click(): void {
    super.onButton1Click();
    this.closeSelf();
  }

  onButton2Click(): void {
    super.onButton2Click();
    this.closeSelf();
  }

  onButton3Click(): void {
    super.onButton3Click();
    this.closeSelf();
  }
}

/**
 * 跳转功能的按钮菜单控制器
 *
 * @since 2022-12-30
 */
export class JumpButtonMenuController extends ButtonMenuController {
  public tag: string = 'JumpButtonMenuController : ';

  onButton1Click(): void {
    let message: string = `bundleName: ${(this.menu?.extra as Want)?.bundleName}; abilityName: ${
    (this.menu?.extra as Want)?.abilityName}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    if ((this.menu?.extra as Want)?.bundleName && (this.menu?.extra as Want)?.abilityName) {
      AbilityUtils.startAbility({
        bundleName: (this.menu?.extra as Want)?.bundleName,
        abilityName: (this.menu?.extra as Want)?.abilityName,
      });
    }
  }
}

/**
 * 菜单组控制器
 *
 * @since 2022-03-21
 */
export class MenuGroupController extends MenuController {
  public tag: string = 'MenuGroupController : ';

  static CreateMenuGroupController(menu: SettingsBaseMenu): Controller {
    return new MenuGroupController(menu);
  }

  clearChildren(): void {
    if (this.menu instanceof MenuGroup) {
      this.menu.clear();
    }
  }

  addChildren(addMenus: Array<SettingsBaseMenu>): void {
    if (this.menu instanceof MenuGroup) {
      this.menu.addMenus(addMenus);
    }
  }

  addChildrenToShift(unshiftMenu: Array<SettingsBaseMenu>): void {
    if (this.menu instanceof MenuGroup) {
      this.menu.addMenusToShift(unshiftMenu);
    }
  }

  removeChildren(key: string): void {
    if (this.menu instanceof MenuGroup) {
      this.menu.removeMenu(key);
    }
  }

  findChild(key: string): SettingsBaseMenu | null {
    if (this.menu instanceof MenuGroup) {
      return this.menu.findMenu(key);
    }
    LogUtil.error(`${this.tag} menu not MenuGroup`);
    return null;
  }

  getChildren(): Array<SettingsBaseMenu> {
    if (this.menu instanceof MenuGroup) {
      return this.menu.getMenus();
    }
    return [];
  }

  refreshChildren(): void {
    if (this.menu instanceof MenuGroup) {
      return this.menu.refreshChildren();
    }
  }
}

/*
 *CircleController抽象类
 *
 */
export abstract class CommonCircleController extends MenuGroupController {
  public message?: string;
  public totalBytes?: string;
  public usedBytes?: string;
  public freeBytes?: string;
  public proportion?: number;
  public categoryValues?: number[];
  public totalValue?: number;
  public valueColors?: (ResourceColor | LinearGradient)[];
}

/**
 * 内容空的时候自动隐藏菜单组控制器
 *
 * @since 2022-06-25
 */
export class EmptyInvisibleController extends MenuGroupController {
  public tag: string = 'EmptyInvisibleController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateEmptyInvisibleController(menu: SettingsBaseMenu): Controller {
    return new EmptyInvisibleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    let name: string = systemParameter.getSync(DISPLAY_NAME_SYS_PARAM_KEY);
    if (name.includes(DEVELOP_VERSION)) {
      this.removeChildren(SYSTEM_NAME);
    }
    this.removeHomePageMenusInEmulator();
    this.setVisible((this.getChildren().length === 0) ? false : true);
  }

  private removeHomePageMenusInEmulator(): void {
    let productModel: string = systemParameter.getSync(PRODUCT_MODEL);
    LogUtil.info(`${this.tag} product model : ${productModel}`);
    if (productModel === PRODUCT_MODEL_EMULATOR) {
      let productDeviceType: string = systemParameter.getSync(PRODUCT_DEVICE_TYPE);
      let productCpuAbilist: string = systemParameter.getSync(PRODUCT_CPU_ABILITST);
      LogUtil.info(`${this.tag} product devicetype : ${productDeviceType}`);
      LogUtil.info(`${this.tag} product cpu ablilist : ${productCpuAbilist}`);
      this.removeChildren(NavEntryKey.BLUETOOTH_ENTRY);
      this.removeChildren(NavEntryKey.MOBILE_ENTRY);
      this.removeChildren(NavEntryKey.MORE_CONNECTION_ENTRY);
      this.removeChildren(NavEntryKey.USERS_ACCOUNT_ENTRY);
      this.removeChildren(NavEntryKey.DEVELOP_OPTION_ENTRY);
      this.removeChildren(NavEntryKey.PRIVACY_ENTRY);
      if (productDeviceType === PRODUCT_DEVICE_TYPE_PHONE) {
        this.removeChildren(NavEntryKey.BRIGHTNESS_GROUP_ENTRY);
        this.removeChildren(NavEntryKey.SCREEN_GROUP_ENTRY);
        this.removeChildren(NavEntryKey.SCREEN_SETTING_ENTRY);
        this.removeChildren(NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS);
        this.removeChildren(NavEntryKey.VERSION);
      }
    }
  }

  getCurrentVisibleStatus(): boolean {
    if (!(this.menu instanceof MenuGroup)) {
      return this.isVisibleStatus();
    }
    for (let menu of this.menu.getMenus()) {
      if (menu.isVisible()) {
        return true;
      }
    }
    return false;
  }

  removeMenuGroup(menuKey: string): void {
    if (this.getChildren().length !== 0 || CheckEmptyUtils.isEmpty(menuKey)) {
      return;
    }

    let homePageMenu = this.menu.parent as Object as SettingsBaseMenu;
    if (!homePageMenu) {
      return;
    }

    let controller = homePageMenu.getController() as MenuController;
    if (controller?.menu instanceof MenuGroup) {
      LogUtil.info(`${this.tag} remove menu group: ${menuKey}`);
      (controller.menu as MenuGroup).removeMenu(menuKey);
      controller.refreshUi();
    }
  }
}

/**
 * 重置和克隆自动隐藏菜单组控制器
 *
 * @since 2024-05-05
 */
export class ResetCloneInvisibleController extends MenuGroupController {
  public tag: string = 'EmptyInvisibleController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateResetCloneInvisibleController(menu: SettingsBaseMenu): Controller {
    return new ResetCloneInvisibleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.setVisible((this.getChildren().length === 0) ? false : true);
    this.removeMenuGroup('reset_clone_group');
  }

  getCurrentVisibleStatus(): boolean {
    if (!(this.menu instanceof MenuGroup)) {
      return this.isVisibleStatus();
    }
    for (let menu of this.menu.getMenus()) {
      if (menu.isVisible()) {
        return true;
      }
    }
    return false;
  }

  removeMenuGroup(menuKey: string): void {
    if (this.getChildren().length !== 0 || CheckEmptyUtils.isEmpty(menuKey)) {
      return;
    }

    let homePageMenu = this.menu.parent as Object as SettingsBaseMenu;
    if (!homePageMenu) {
      return;
    }

    let controller = homePageMenu.getController() as MenuController;
    if (controller?.menu instanceof MenuGroup) {
      LogUtil.info(`${this.tag} remove menu group: ${menuKey}`);
      (controller.menu as MenuGroup).removeMenu(menuKey);
      controller.refreshUi();
    }
  }
}

export class LoadingChangeData {
  public isLoading: boolean;

  constructor(isLoading: boolean) {
    this.isLoading = isLoading;
  }
}

/**
 * 内容空的时候自动隐藏菜单组控制器
 * 模拟器模式隐藏部分菜单
 */
export class EmulatorMenuController extends MenuGroupController {
  public tag: string = 'EmulatorMenuController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateEmulatorMenuController(menu: SettingsBaseMenu): Controller {
    return new EmulatorMenuController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.removeHomePageMenusInEmulator();
  }

  private removeHomePageMenusInEmulator(): void {
    let productModel: string = systemParameter.getSync(PRODUCT_MODEL);
    LogUtil.info(`${this.tag} product model : ${productModel}`);
    if (productModel === PRODUCT_MODEL_EMULATOR) {
      this.removeChildren(NavEntryKey.BLUETOOTH_ENTRY);
      this.removeChildren(NavEntryKey.MOBILE_ENTRY);
      this.removeChildren(NavEntryKey.MORE_CONNECTION_ENTRY);
      this.removeChildren(NavEntryKey.USERS_ACCOUNT_ENTRY);
      this.removeChildren(NavEntryKey.DEVELOP_OPTION_ENTRY);
      this.removeChildren(NavEntryKey.PRIVACY_ENTRY);
      this.removeChildren(DORMANCY_SETTINGS);
    }
    let isDoubleSpaceParam = SystemParamUtil.getParam(DOUBLE_SPACE_PARAM_KEY, DoubleSpaceParamEnum.NORMAL_VERSION);
    if (isDoubleSpaceParam === DoubleSpaceParamEnum.DOUBLE_SPACE) {
      this.removeChildren(NavEntryKey.USER_SETTING_ENTRY);
    }
  }

  getCurrentVisibleStatus(): boolean {
    if (!(this.menu instanceof MenuGroup)) {
      return this.isVisibleStatus();
    }
    for (let menu of this.menu.getMenus()) {
      if (menu.isVisible()) {
        return true;
      }
    }
    return false;
  }
}

/**
 * 加载菜单控制器
 *
 * @since 2022-03-21
 */
export class LoadingMenuController extends MenuController {
  public isLoading: boolean = true;

  onDataChange(fromKey: string, data: Object): void {
    if (data instanceof LoadingChangeData) {
      if (fromKey === 'bluetooth_list_group') {
        LogUtil.info(`onDataChange, menu key: bluetooth_list_group`);
        AppStorage.setOrCreate('btListLoadingVisible', data.isLoading as boolean);
      } else {
        this.isLoading = data.isLoading;
        this.refreshUi();
      }
    }
  }

  isLoadingVisible(): boolean {
    return this.isLoading;
  }
}

/**
 * 加载菜单父菜单控制器
 *
 * @since 2022-03-21
 */
export class LoadingGroupController extends MenuGroupController {
  public tag: string = 'LoadingGroupController : ';
  public isLoading: boolean = true;

  setLoading(isLoading: boolean): void {
    if (this.isLoading !== isLoading) {
      this.isLoading = isLoading;
      this.publishDataChange(new LoadingChangeData(this.isLoading));
    }
  }
}

/**
 * 单选卡片控制器
 *
 * @since 2022-05-28
 */
export class RadioMenuController extends MenuController {
  public tag: string = 'RadioMenuController : ';
  public isChecked: boolean = false;

  onRadioChange(isChecked: boolean): void {
    LogUtil.info(`${this.tag} onRadioChange ${isChecked}`);
  }

  setRadio(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      this.refreshUi();
    }
  }
}

/**
 * 简易音量控制器
 *
 * @since 2024-01-06
 */
export class SimpleVolumeMenuController extends MenuController {
  public tag: string = 'SimpleVolumeMenuController : ';
  public audioRingMode: AudioRingMode = AudioRingMode.RINGER_MODE_NORMAL;

  onRadioChange(ringMode?: AudioRingMode): void {
    LogUtil.info(`${this.tag} onRadioChange ${ringMode}`);
  }
}

/**
 * 跳转控制器
 *
 * @since 2022-10-10
 */
export class JumpController extends MenuController {
  public tag: string = 'JumpController : ';

  static CreateJumpController(menu: SettingsBaseMenu): Controller {
    return new JumpController(menu);
  }

  onMenuClick(): boolean {
    let message: string = `bundleName: ${(this.menu?.extra as extraType)?.want?.bundleName}; abilityName: ${(this.menu?.extra as extraType)?.want?.abilityName}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    if ((this.menu?.extra as extraType)?.want?.bundleName && (this.menu?.extra as extraType)?.want?.abilityName) {
      LogUtil.info(`${this.tag} ${(this.menu?.extra as extraType)?.want?.bundleName} ${(this.menu?.extra as extraType)?.want?.abilityName} ${(this.menu?.extra as extraType)?.navEntryKey}`);
      AbilityUtils.startAbilityForResult({
        bundleName: (this.menu?.extra as extraType)?.want?.bundleName,
        abilityName: (this.menu?.extra as extraType)?.want?.abilityName,
        action: (this.menu?.extra as extraType)?.want?.action,
        uri: (this.menu?.extra as extraType)?.navEntryKey,
        parameters: (this.menu?.extra as extraType)?.want?.parameters,
      }, () => {
        this.onMenuClickCallback();
      });
      return true;
    }
    return false;
  }

  onMenuClickCallback(): void {
    LogUtil.info(`${this.tag} onMenuClickCallback `);
  }

  updateStatus(): void {
    if ((this.menu?.extra as extraType)?.want?.bundleName && (this.menu?.extra as extraType)?.want?.abilityName) {
      let bundleName: string = (this.menu?.extra as extraType)?.want?.bundleName as string;
      let abilityName: string = (this.menu?.extra as extraType)?.want?.abilityName as string;
      bundle.getAbilityInfo(bundleName, abilityName)
        .then((data) => {
          this.setVisible(true);
        })
        .catch((error: Error) => {
          this.setVisible(false);
          LogUtil.error(`ability is invisible. Cause: message: ${error.message}`);
        });
    }
  }
}


/**
 * 拉起市场应用控制器
 *
 * @since 2023-11-2
 */
export class JumpAbilityController extends MenuController {
  public tag: string = 'JumpAbilityController : ';

  static CreateJumpAbilityController(menu: SettingsBaseMenu): Controller {
    return new JumpAbilityController(menu);
  }

  onMenuClick(): boolean {
    let parameter = (this.menu?.extra as extraType)?.want?.uri
    if (parameter) {
      AbilityUtils.startAbilityForResult({
        bundleName: (this.menu?.extra as extraType)?.want?.bundleName,
        abilityName: (this.menu?.extra as extraType)?.want?.abilityName,
        uri: (this.menu?.extra as extraType)?.want?.uri,
        parameters: (this.menu?.extra as extraType)?.want?.parameters,
      }, () => {
        this.onMenuClickCallback();
      });
      return true;
    }
    return false;
  }

  onMenuClickCallback(): void {
    LogUtil.info(`${this.tag} onMenuClickCallback `);
  }
}


/**
 * 跳转控制器
 *
 * @since 2022-10-10
 */
export class JumpServiceExtensionController extends MenuController {
  public tag: string = 'JumpServiceExtensionController : ';

  static CreateJumpServiceExtensionController(menu: SettingsBaseMenu): Controller {
    let bundleName: string = (menu?.extra as extraType)?.want?.bundleName as string;
    let abilityName: string = (menu?.extra as extraType)?.want?.abilityName as string;
    if (bundleName === 'com.ohos.ouc' && abilityName === 'ServiceExtAbility') {
      menu.enable = false;
    }
    return new JumpServiceExtensionController(menu);
  }

  onMenuClick(): boolean {
    let message: string = `bundleName: ${(this.menu?.extra as extraType)?.want?.bundleName}; abilityName: ${(this.menu?.extra as extraType)?.want?.abilityName}`;
    HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
    if ((this.menu?.extra as extraType)?.want?.bundleName && (this.menu?.extra as extraType)?.want?.abilityName) {
      LogUtil.info(`${this.tag} ${(this.menu?.extra as extraType)?.want?.bundleName} ${(this.menu?.extra as extraType)?.want?.abilityName} ${(this.menu?.extra as extraType)?.navEntryKey}`);
      AbilityUtils.startAbility({
        bundleName: (this.menu?.extra as extraType)?.want?.bundleName,
        abilityName: (this.menu?.extra as extraType)?.want?.abilityName,
        action: (this.menu?.extra as extraType)?.want?.action,
        uri: (this.menu?.extra as extraType)?.navEntryKey,
        parameters: (this.menu?.extra as extraType)?.want?.parameters,
      }, () => {
        this.onMenuClickCallback();
      });
      return true;
    }
    return false;
  }

  onMenuClickCallback(): void {
    LogUtil.info(`${this.tag} onMenuClickCallback `);
  }
}

/**
 * UXExtension跳转控制器
 * extra: {
 *   navEntryKey: '跳转页面',
 *   want: {
 *     parameters: {
 *       pushParams: 跳转参数
 *     },
 *   }
 * }
 *
 * @since 2023-9-26
 */
export class UIExtensionJumpController extends MenuController {
  public tag: string = 'UIExtensionJumpController : ';

  static CreateUIExtensionJumpController(menu: SettingsBaseMenu): Controller {
    return new UIExtensionJumpController(menu);
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick`);
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    if (pathInfoStack && this.menu?.extra) {
      let extraInfo = this.menu.extra as extraType;
      if (extraInfo.navEntryKey === undefined) {
        return false;
      }
      if (this.menu.key === 'app_info_notification') {
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.ENTRY_NOTIFICATION_DETAILS)
      }
      LogUtil.info(`${this.tag} route to ${extraInfo.navEntryKey}`)
      DynamicLoader.getInstance().fire(extraInfo.navEntryKey).then(() => {
        let message: string = `bundleName: ${extraInfo.want?.bundleName}; abilityName: ${extraInfo.want?.abilityName}`;
        HiSysEventUtil.reportEntryEvent(ENTER_EXTERNAL_ENTRY, message);
        pathInfoStack?.pushPathByName(extraInfo?.navEntryKey, this.getPushParams(extraInfo));
      });
      return true;
    }
    return false;
  }

  getPushParams(extraInfo: extraType): PushParam | undefined {
    if (extraInfo.want?.parameters?.pushParams) {
      return new PushParam(extraInfo.want?.parameters?.pushParams);
    }
    return undefined;
  }

  onMenuClickCallback(): void {
    LogUtil.info(`${this.tag} onMenuClickCallback `);
  }
}

/**
 * 勾选菜单控制器
 *
 * @since 2023-06-19
 */
export class CheckboxMenuController extends MenuController {
  onMenuChange(value: boolean): void {
    LogUtil.info(`CheckboxMenuController, checkbox state: ${value}`);
  }
}

/**
 * 多选菜单控制器
 *
 * @since 2023-12-02
 */
export class MultiCheckboxMenuController extends MenuController {
  public isSelected: boolean = false;

  onMenuChange(value: boolean): void {
    LogUtil.info(`CheckboxMenuController, checkbox state: ${value}`);
  }

  setCheckBox(isSelected: boolean): void {
    if (this.isSelected !== isSelected) {
      this.isSelected = isSelected;
      this.refreshUi();
    }
  }
}

/**
 * 已配对设备类型控制器
 *
 * @since 2024-03-25
 */
export class BondDeviceTypeController extends MenuController {
  getRemoteDeviceType(): Promise<number> {
    return Promise.resolve(0);
  }
}

export class NavCheckboxMenuController extends MenuController {
  public selected: boolean = false;

  onCheckboxChange(value: boolean): void {
    LogUtil.info(`CheckboxMenuController, checkbox state: ${value}`);
  }

  setCheckBox(isSelected: boolean): void {
    if (this.selected !== isSelected) {
      this.selected = isSelected;
      this.refreshUi();
    }
  }
}

/**
 * 辅助功能快捷键系统弹窗菜单控制器
 *
 * @since 2023-12-02
 */
export class MultiCheckImageMenuController extends MenuController {
  public isSelected: boolean = false;

  onMenuChange(value: boolean): void {
    LogUtil.info(`ImageMenuController, checkImage state: ${value}`);
  }
}

/**
 * 可变标题的按钮菜单控制器
 *
 * @since 2023-06-20
 */
export class ButtonWithVariableTitleMenuController extends MenuController {
  onButtonClick(): void {
    if (this.menu?.targetPageUrl) {
      HiSysEventUtil.reportButtonEvent(ENTER_INTERNAL_BUTTON, this.menu.targetPageUrl);
      router.push({
        url: this.menu.targetPageUrl,
      });
    }
  }

  setTitle(timeLeft: number): ResourceStr | undefined {
    return undefined;
  }

  isButtonEnabled(): boolean {
    return true;
  }
}

/**
 * 不响应touch事件的菜单控制器
 *
 * @since 2023-08-23
 */
export class UnRespondTouchController extends MenuController {
  aboutToAppear(): void {
    super.aboutToAppear();
    this.isRespondTouchEvent = false;
  }
}


@Observed
export class DialogChainTextInputController extends TextInputMenuController {
  public tag: string = 'DialogChainTextInputController : ';
  public isChecked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateDialogChainTextInputController(menu: SettingsBaseMenu): Controller {
    return new DialogChainTextInputController(menu);
  }

  protected registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange `);
    this.registerControllerDataChange('bluetooth_PinConsist_message');
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange `);
    this.unRegisterControllerDataChange('bluetooth_PinConsist_message');
  }

  onDataChange(fromKey: string, data: boolean): void {
    LogUtil.info(`${this.tag} onDataChange data:${data}`);
    this.isChecked = data;
    this.refreshUi();
  }

  onTextInputChange(input: string): void {
    LogUtil.info(`${this.tag} onTextInputChange `);
    this.publishDataChange(input);
  }
}

@Observed
export class PinRequiredTextInputController extends TextInputMenuController {
  public tag: string = 'PinRequiredTextInputController : ';
  public isChecked: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreatePinRequiredTextInputController(menu: SettingsBaseMenu): Controller {
    return new PinRequiredTextInputController(menu);
  }

  onTextInputChange(input: string): void {
    LogUtil.info(`${this.tag} onTextInputChange `);
    this.publishDataChange(input);
  }
}

@Observed
export class DialogChainCheckboxController extends CheckboxMenuController {
  static CreateDialogChainCheckboxController(menu: SettingsBaseMenu): Controller {
    return new DialogChainCheckboxController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  publishDataChange(data: Object): void {
    this.menu?.getRoot()?.publishControllerDataChange(this.getKey(), data);
  }
}

@Observed
export class SingleChoiceListController extends MenuController {
  public tag: string = 'SingleChoiceListController : ';

  static SingleChoiceListController(menu: SettingsBaseMenu): Controller {
    return new SingleChoiceListController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onSelectMenuChanged(key: number): void {
    LogUtil.info(`onSelectMenuChanged, select key: ${key}`);
  }

  onBindMenuAppear(): void {
    LogUtil.info(`${this.tag} onBindMenuAppear`);
  }

  onBindMenuDisAppear(): void {
    LogUtil.info(`${this.tag} onBindMenuDisAppear`);
  }
}

/**
 * 图案密码菜单控制器
 *
 * @since 2024-06-24
 */
export class PatternPasswordController extends MenuController {
  public tag: string = 'PatternPasswordController : ';
  protected patternLockController: PatternLockController = new PatternLockController();

  public setPatternLockController(patternLockController: PatternLockController) {
    this.patternLockController = patternLockController;
  }

  public getPatternLockController(): PatternLockController {
    return this.patternLockController;
  }

  public onPatternComplete(input: Array<number>): void {
  }

  public onDotConnect(index: number): void {
  }
}