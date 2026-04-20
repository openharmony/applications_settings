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

import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import display from '@ohos.display';
import measure from '@ohos.measure';
import window from '@ohos.window';
import plugin from '@ohos.pluginComponent';
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import Want from '@ohos.app.ability.Want';
import { emitter } from '@kit.BasicServicesKit';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import Settings from '@ohos.settings';
import uiAppearance from '@ohos.uiAppearance';
import { PackagesConstant } from '../constant/PackagesConstant';
import { LogUtil } from '../utils/LogUtil';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';
import { DeviceUtil } from '../utils/BaseUtils';
import { DisplayConstant } from '../constant/DisplayConstant';
import { DisplayManager, EVENT_ID_FOLD_STATUS_CHANGE } from '../displaymanager/DisplayManager';
import { EVENT_ID_ON_WINDOW_STAGE_CHANGED } from '../event/types';
import { ResourceUtil } from '../utils/ResourceUtil';
import { MainConstants } from '../constant/MainConstants';

const TAG: string = 'WindowManager : ';

const WINDOW_BACKGROUND_COLOR: string = '#F1F3F5';
const WINDOW_DEFAULT_CORNERS: number = 24;
const WINDOW_BG_WHITE: string = '#FFFFFF';
const WINDOW_BG_BLACK: string = '#000000';
const WINDOW_BG_APP: string = '#F1F3F5';
const VP_TO_PX_SCALE: number = 160;
const COLOR_MODE_DARK: number = 0;
const DIALOG_WINDOW_ULTRA_THICK_WHITE: string = '#F1F3F5';
const DIALOG_WINDOW_ULTRA_THICK_BLACK: string = '#202224';
const SETTINGS_NAVBAR_WIDTH_MIN : number = 280;
const SETTINGS_NAVBAR_WIDTH_MAX : number = 344;
const SETTINGS_NAVBAR_RATIO : number = 0.3337;
const SETTINGS_CONTENT_WIDTH : number = 1080;
const SETTINGS_CONTENT_DISTANCE : number = 24;
const GRID_ROW_MARGIN: number = 48;
const GRID_ROW_GUTTER: number = 24;
const GRID_ROW_COLUMNS: number = 12;
const GRID_COLUMN_HOME_SPAN: number = 4.5;
const GRID_COLUMN_HOME_GUTTER_WIDTH: number = GRID_ROW_GUTTER * 4;
const GRID_CONTENT_MARGIN_RATIO: number = 0.75;
const GRID_COLUMN_WIDTH_KEY: string = 'grid_row_column_width_key';
const GRID_ROW_HOME_WIDTH_KEY: string = 'grid_row_home_width_key';
const GRID_ROW_MARGIN_FULL_PAGE_KEY: string = 'grid_row_margin_full_page_key';


export interface WindowInfo {
  name: string,
  width: number,
  height: number,
  windowType: number,
  loadContent: string,
  radius?: number,
}

/**
 * 主窗口系统规避区域参数
 */
export interface AvoidAreaParams {
  type: window.AvoidAreaType,
  area: window.AvoidArea
}

interface PushParametersI extends plugin.PushParameters {
  owner: Want;
}

/**
 * 避让区方向
 */
export enum AvoidAreaDirect {
  TOP,
  BOTTOM
}

export enum BreakPoint {
  SM = 'sm',
  LG = 'lg',
  MD = 'md'
}

export enum LayoutConstants {
  WIDTH_RATIO = 0.4,
  A_MIN_WIDTH = 280,
  A_MAX_WIDTH = 480,
  B_MIN_WIDTH = 360,
  SM_MAX_WIDTH = 600,
  MD_MAX_WIDTH = 962,
}

/**
 * 窗口功能管理类
 *
 * @since 2022-12-30
 */
export class WindowManager {
  private mainWindow: window.Window | null = null;
  private currentBreakingPoint: BreakPoint = BreakPoint.SM;

  /**
   * 获取窗口管理类对象
   *
   * @return 窗口管理类对象单一实例
   */
  static getInstance(): WindowManager {
    if (AppStorage.get<WindowManager>('WindowManager') == null) {
      AppStorage.setOrCreate<WindowManager>('WindowManager', new WindowManager());
    }
    return AppStorage.get<WindowManager>('WindowManager') as WindowManager;
  }

  /**
   * 调整窗口属性，包括宽，高，位置，加载内容等
   */
  private async adjustWindowParam(win: window.Window, windowInfo: WindowInfo): Promise<void> {
    try {
      win.setCornerRadius(windowInfo.radius ?? WINDOW_DEFAULT_CORNERS);
      await this.resizeWindow(win, windowInfo.width, windowInfo.height);
      await win.setUIContent(windowInfo.loadContent);
    } catch (businessError) {
      LogUtil.error(`${TAG} adjustWindowParam error: ${businessError?.message}`);
    }
  }

  async resizeWindow(win: window.Window, width: number, height: number): Promise<void> {
    if (!win) {
      return;
    }

    try {
      let windowRect = win.getWindowProperties().windowRect;
      if (windowRect.width === width && windowRect.height === height) {
        LogUtil.info(`${TAG} window size is same, don't need resize`);
        return;
      }
      await win.resize(width, height);
      let dis = display.getDefaultDisplaySync();
      let moveWidth: number = (dis.width - width) / 2;
      let moveHeight: number = (dis.height - height) / 2;
      LogUtil.info(`${TAG} resizeWindow moveWindowTo, height: ${moveWidth}, width: ${moveHeight}`);
      await win.moveWindowTo(moveWidth, moveHeight);
    } catch (businessError) {
      LogUtil.error(`${TAG} resizeWindow error: ${businessError?.message}`);
    }
  }

  /**
   * 创建一个新的窗口
   */
  async createWindow(context: Context, windowInfo: WindowInfo): Promise<window.Window | void> {
    if (!windowInfo) {
      return;
    }
    LogUtil.info(`${TAG} createWindow, name: ${windowInfo.name} windowType: ${windowInfo.windowType}  loadContent: ${windowInfo.loadContent}`);
    let config: window.Configuration = { name: windowInfo.name, windowType: windowInfo.windowType, ctx: context };
    let win: window.Window;
    try {
      win = await window.createWindow(config);
      await this.adjustWindowParam(win, windowInfo);
      win.setShadow(50, '#4d000000', 0, 10);
      WindowManager.setWindowBackgroundColor(WindowManager.getDialogWindowBackgroundColor(), win);
      await win.show();
      return win;
    } catch (businessError) {
      LogUtil.error(`${TAG} createWindow error: ${businessError?.message}`);
    }
  }

  createWindowIfAbsent(context: Context, windowInfo: WindowInfo, isPrivacyMode: boolean = false): void {
    if (!windowInfo) {
      return;
    }
    LogUtil.info(`${TAG} create, name ${windowInfo.name}`);
    window.find(windowInfo.name).then(win => {
      this.adjustWindowParam(win, windowInfo).then(() => {
        win.setShadow(50, '#4d000000', 0, 10);
        WindowManager.setWindowBackgroundColor(WindowManager.getDialogWindowBackgroundColor(), win);
        win.show();
        if (isPrivacyMode) {
          this.setWindowPrivacyMode(win, true);
        }
      })
    }).catch((error: BusinessError) => {
      LogUtil.info(`${TAG} ${windowInfo?.name} window is not created, because ${error}`);
      this.createWindow(context, windowInfo).then((win) => {
        if (isPrivacyMode) {
          this.setWindowPrivacyMode(win as window.Window, true);
        }
      });
    });
  }

  changeMainWindowColor(bgColor: string): void {
    this.getMainWindow();
    this.mainWindow?.setWindowBackgroundColor(bgColor);
  }

  async showWindow(name: string): Promise<void> {
    let win = this.findWindow(name);
    if (!win) {
      LogUtil.info(`${TAG} showWindow, window is null`);
      return;
    }
    LogUtil.info(`${TAG} showWindow, show the name: ${name}`);
    try {
      await win.showWindow();
    } catch (error) {
      LogUtil.error(`${TAG} show window error, because ${error}`);
    }
  }

  async hideWindow(name: string): Promise<void> {
    let win = this.findWindow(name);
    if (!win) {
      LogUtil.info(`${TAG} hideWindow, window is null`);
      return;
    }
    LogUtil.info(`${TAG} hideWindow, hide the name: ${name}`);
    try {
      await win.hide();
    } catch (error) {
      LogUtil.error(`${TAG} hide window error, because ${error}`);
    }
  }

  async destroyWindow(name: string, isPrivacyMode: boolean = false): Promise<void> {
    let win = this.findWindow(name);
    if (!win) {
      LogUtil.info(`${TAG} destroyWindow, window is null`);
      return;
    }
    LogUtil.info(`${TAG} destroyWindow, destroy the name: ${name}`);
    try {
      await win.destroyWindow();
      this.setWindowPrivacyMode(win, isPrivacyMode);
    } catch (error) {
      LogUtil.error(`${TAG} destory window error, because ${error}`);
    }
  }

  findWindow(name: string): window.Window {
    try {
      return window.findWindow(name);
    } catch (error) {
      LogUtil.error(`${TAG} ${name} window is not found, because ${error}`);
    }
    return window.findWindow(name);
  }

  static isWindowShowing(name: string): boolean {
    try {
      return window.findWindow(name).isWindowShowing();
    } catch (error) {
      LogUtil.error(`${TAG} ${name} window is not found, because ${error}`);
    }
    return false;
  }

  static async setNavBarWidth(width: number): Promise<void> {
    LogUtil.info(`${TAG} size.width is ${width}`);
    try {
      WindowManager.getInstance().updateBreakPointByWindWidth(px2vp(width))
      let task: taskpool.Task = new taskpool.Task(getNavBarWidth, width);
      let calNavBarWidth: number = await taskpool.execute(task, taskpool.Priority.MEDIUM) as number;
      AppStorage.setOrCreate('calNavBarWidth', calNavBarWidth);
      LogUtil.info(`${TAG} navigation bar width: ${calNavBarWidth}`);
    } catch (error) {
      LogUtil.error(`${TAG} getNavBarWidth task pool failed: ${error?.message}`);
    }
  }

  /**
   * 根据当前窗口宽度获取PC设置nav宽度
   *
   * @param currentWindowWidth 当前窗口宽度
   * @returns 设置nav宽度
   */
  static getPcSettingsNavBarWidth(currentWindowWidth: number): number {
    let width: number = currentWindowWidth * SETTINGS_NAVBAR_RATIO;
    if (Number.isNaN(width) || width < SETTINGS_NAVBAR_WIDTH_MIN) {
      width = SETTINGS_NAVBAR_WIDTH_MIN;
    } else if (width > SETTINGS_NAVBAR_WIDTH_MAX) {
      width = SETTINGS_NAVBAR_WIDTH_MAX;
    }
    return width;
  }

  /**
   * 根据当前窗口宽度获取PC设置NavDestination的左右padding
   *
   * @param currentWindowWidth 当前窗口宽度
   * @returns 设置NavDestination的左右padding
   */
  static getPcSettingsPagePadding(currentWindowWidth: number): number {
    let more: number = currentWindowWidth - SETTINGS_NAVBAR_WIDTH_MAX - SETTINGS_CONTENT_WIDTH -
      SETTINGS_CONTENT_DISTANCE * 2;
    return more > 0 ? more / 2 : 0;
  }

  /**
   * 根据宽度计算当前的断点类型，当断点类型发生改变则触发分栏宽度刷新
   * @param windowWidth 单位为vp
   */
  public updateBreakPointByWindWidth(windowWidthVp: number): void {
    LogUtil.info(`${TAG} updateBreakPointByWindWidth, windowWidthVp: ${windowWidthVp}`);
    if (!windowWidthVp) {
      return;
    }
    let newBreakpoint: BreakPoint;
    if (windowWidthVp < LayoutConstants.SM_MAX_WIDTH) {
      newBreakpoint = BreakPoint.SM; // 竖屏手机
    } else if (windowWidthVp < LayoutConstants.MD_MAX_WIDTH) {
      newBreakpoint = BreakPoint.MD; // 折叠屏
    } else {
      newBreakpoint = BreakPoint.LG; // 超大屏幕
    }
    if (this.currentBreakingPoint !== newBreakpoint) {
      // 记录当前断点值
      this.currentBreakingPoint = newBreakpoint;
      this.updateNavBarWidth(windowWidthVp);
    }
    LogUtil.info(`${TAG} updateBreakPointByWindWidth currentBreakingPoint: ${this.currentBreakingPoint}`);
  }

  private updateNavBarWidth(windowWidthVp: number): void {
    let navBarWidth: number = windowWidthVp * LayoutConstants.WIDTH_RATIO;
    if (this.currentBreakingPoint === BreakPoint.LG) {
      navBarWidth = LayoutConstants.A_MAX_WIDTH;
      AppStorage.setOrCreate('navBarWidth', navBarWidth);
    } else if (this.currentBreakingPoint === BreakPoint.MD) {
      AppStorage.setOrCreate('navBarWidth', navBarWidth);
    }
    LogUtil.info(`${TAG} setNavBarWidth winWidth: ${this.currentBreakingPoint} ${windowWidthVp} ${navBarWidth}`);
  }

  /**
   * 设置沉浸式状态栏
   *
   * @param stage 窗口管理器
   * @param properties 状态栏属性
   * @param bgColor 状态栏背景
   */
  static setSystemBarProperties(stage: window.WindowStage, properties: window.SystemBarProperties, bgColor: string) {
    if (!stage || !properties) {
      return;
    }
    stage.getMainWindow().then(windowInstance => {
      windowInstance.setWindowSystemBarProperties(properties);
      windowInstance.setWindowBackgroundColor(bgColor);
    })
  }

  /**
   * 设置沉浸式状态栏,不设置背景色
   *
   * @param stage 窗口管理器
   * @param properties 状态栏属性
   * @param bgColor 状态栏背景
   */
  static setSystemBarPropertiesOnly(stage: window.WindowStage, properties: window.SystemBarProperties) {
    if (!stage || !properties) {
      return;
    }
    stage.getMainWindow().then(windowInstance => {
      windowInstance.setWindowSystemBarProperties(properties);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} setSystemBarPropertiesOnly failed: err.code${err?.code} err.message:${err?.message}`);
    })
  }

  /**
   * 设置是否屏幕常亮
   *
   * @param stage 窗口管理器
   * @param isKeepScreenOn 是否常亮
   */
  static setKeepScreenOn(stage: window.WindowStage, isKeepScreenOn: boolean): void {
    if (!stage) {
      LogUtil.error(`${TAG} setKeepScreenOn stage is invalid`);
      return;
    }
    LogUtil.info(`${TAG} setKeepScreenOn in`);
    stage.getMainWindow().then(windowInstance => {
      windowInstance.setWindowKeepScreenOn(isKeepScreenOn);
      LogUtil.info(`${TAG} setKeepScreenOn success ${isKeepScreenOn}`);
    });
  }

  // 关闭plugin弹窗
  static closePluginWindow(pluginTemplateName: string, canDestroyWindow: boolean): void {
    plugin.push({
      owner: {
        bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME
      },
      want: {
        bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME
      },
      name: pluginTemplateName,
      data: {},
      // 请求关闭弹窗
      extraData: {
        requestCloseWindow: true,
        requestDestroyWindow: canDestroyWindow
      }
    } as PushParametersI, () => {
      LogUtil.info(`${TAG} close plugin window complete. name is ${pluginTemplateName}`);
    });
  }

  // 更新plugin弹窗高度
  static updatePluginWindowHeight(pluginTemplateName: string, height: number): void {
    LogUtil.info(`${TAG} updatePluginWindowHeight name is ${pluginTemplateName}, height: ${height}`);
    plugin.push({
      owner: {
        bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME
      },
      want: {
        bundleName: PackagesConstant.SETTINGS_BUNDLE_NAME
      },
      name: pluginTemplateName,
      data: {},
      // 请求更新弹窗高度
      extraData: {
        requestWindowHeight: height
      }
    } as PushParametersI, () => {
      LogUtil.info(`${TAG} update plugin window height complete. name is ${pluginTemplateName}`);
    });
  }

  /**
   * 给窗口设置安全标记
   *
   * @param window Stage模型window容器
   * @param isPrivacyMode 是否设置成隐私模式
   */
  setWindowPrivacyMode(window: window.Window, isPrivacyMode: boolean): void {
    LogUtil.info(`${TAG} setPrivacyMode enter : ${isPrivacyMode}}`);
    window?.setWindowPrivacyMode(isPrivacyMode).then(() => {
    }).catch((err: BusinessError) => {
      LogUtil.error(`Failed to set the window to privacy mode. Cause: ${err?.message}`);
    });
  }

  /**
   * get main window
   */
  private getMainWindow(): void {
    if (this.mainWindow) {
      LogUtil.info(`${TAG} getMainWindow already exists, mainWindow: ${this.mainWindow === null}`);
      return;
    }

    try {
      let windowStage: window.WindowStage | undefined = this.getCurrentWindow();
      if (!windowStage) {
        LogUtil.warn(`${TAG} getMainWindow windowStage is null`);
        return;
      }
      this.mainWindow = windowStage.getMainWindowSync();
      LogUtil.info(`${TAG} getMainWindow success`);
    } catch (businessError) {
      LogUtil.error(`${TAG} getMainWindow error. Cause: ${businessError?.message}`);
    }
    LogUtil.info(`${TAG} getMainWindow mainWindow: ${this.mainWindow === null}`);
  }

  /**
   * 设置右三键的颜色和大小
   * @param isDarkStyle true：深色模式
   */
  static setDecorButtonStyle(isDarkStyle: boolean): void {
    let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
    if (!windowData) {
      LogUtil.warn(`${TAG} getMainWindow windowStage is null`);
      return;
    }
    let style: window.DecorButtonStyle = {
      colorMode: isDarkStyle ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT,
      buttonBackgroundSize: 40,
      closeButtonRightMargin: 16
    }
    try {
      windowData.setDecorButtonStyle(style);
    } catch (err) {
      LogUtil.error(`${TAG} setDecorButtonStyle error: ${err?.message} , code: ${err?.code}`);
    }
  }

  /**
   * 开启固定态输入法窗口软键盘高度变化的监听
   *
   * @param windowStage Stage模型window容器
   */
  onKeyboardHeightChange(callback: (data: number) => void): void {
    LogUtil.info(`${TAG} onKeyboardHeightChange, getCurrentWindow`);
    try {
      this.getMainWindow();
      if (!this.mainWindow) {
        LogUtil.warn(`${TAG} onKeyboardHeightChange, mainWindow is null`);
        return;
      }
      this.mainWindow.on('keyboardHeightChange', (data) => {
        LogUtil.info(`${TAG} Succeeded in enabling the listener for keyboard height changes.`);
        callback(data);
      });
    } catch (exception) {
      LogUtil.error(`${TAG} Failed to enable the listener for keyboard height changes, ${exception?.message}`);
    }
  }

  /**
   * 关闭固定态输入法窗口软键盘高度变化的监听
   *
   * @param windowStage Stage模型window容器
   */
  offKeyboardHeightChange(): void {
    try {
      this.getMainWindow();
      if (!this.mainWindow) {
        LogUtil.warn(`${TAG} onKeyboardHeightChange, mainWindow is null`);
        return;
      }
      this.mainWindow.off('keyboardHeightChange');
    } catch (exception) {
      LogUtil.error(`Failed to disable the listener for keyboard height changes, ${exception?.message}`);
    }
  }

  /**
   * 获取当前窗口信息
   */
  private getCurrentWindow(): window.WindowStage | undefined {
    if (LocalStorage?.GetShared()?.has('externalWindowStage')) {
      LogUtil.info('getCurrentWindow from externalWindowStage');
      return LocalStorage?.GetShared().get('externalWindowStage');
    }

    if (LocalStorage?.GetShared()?.has('windowStage')) {
      LogUtil.info('getCurrentWindow from windowStage');
      return LocalStorage?.GetShared().get('windowStage');
    }

    LogUtil.warn('getCurrentWindow empty');
    return undefined;
  }

  static setMainWindowBackgroundColor(windowStage: window.WindowStage, color: string): void {
    windowStage.getMainWindow().then((data) => {
      AppStorage.setOrCreate<window.Window>('mainWindow', data);
      LogUtil.showWarn(TAG, `set current window id : ${data?.getWindowProperties()?.id}`);
      data.setWindowBackgroundColor(color);
      let windowRect: window.Rect = data.getWindowProperties().windowRect;
      WindowManager.setNavBarWidth(windowRect.width);
      AppStorage.setOrCreate<window.Size>('windowSize', { width: windowRect.width, height: windowRect.height });
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} GetMainWindow Failed: ${err?.message}`);
    });
  }

  /**
   * 获取避让区域尺寸
   *
   * @param windowStage Stage模型window容器
   * @param callback 查询结果回调
   */
  static getStatusBarSize(windowStage: window.WindowStage, callback: (w: number, h: number) => void): void {
    windowStage.getMainWindow().then(async (mainWindow) => {
      const topRect = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect || {
        width: 0,
        height: 0
      };
      callback(topRect.width, topRect.height);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} GetMainWindow Failed: ${err?.message}`);
    });
  }

  /**
   * 获取避让区的高度
   *
   * @param windowStage Stage模型window容器
   * @param avoidAreaDirect 哪个方向的避让区
   * @param avoidAreaType 规避区域的类型
   * @returns 避让区的高度
   */
  static getAvoidAreaHeight(windowStage: window.WindowStage, avoidAreaDirect: AvoidAreaDirect,
    avoidAreaType: window.AvoidAreaType): number {
    let height = 0;
    try {
      let avoidArea = windowStage.getMainWindowSync().getWindowAvoidArea(avoidAreaType);
      switch (avoidAreaDirect) {
        case AvoidAreaDirect.TOP:
          height = avoidArea.topRect.height;
          break;
        case AvoidAreaDirect.BOTTOM:
          height = avoidArea.bottomRect.height;
          break;
        default:
          break;
      }
    } catch (err) {
      LogUtil.error(`${TAG} getAvoidAreaHeight Failed: ${err?.message}`);
    }
    return height;
  }

  /**
   * 监听主窗口系统规避区变化
   *
   * @param windowStage Stage模型window容器
   * @param callback 听主窗口系统规避区变化回调
   */
  static onAvoidAreaChange(windowStage: window.WindowStage, callback: (data: AvoidAreaParams) => void) {
    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((err: BusinessError, data) => {
      const errCode: number = err.code;
      if (errCode) {
        LogUtil.error(`${TAG} Failed to obtain the main window. Cause code: ${err?.code}, message: ${err?.message}`);
        return;
      }
      windowClass = data;
      try {
        windowClass.on('avoidAreaChange', callback);
      } catch (exception) {
        LogUtil.error(`${TAG} Failed to listen avoidAreaChange. ` +
          `Cause code: ${exception?.code}, message: ${exception?.message}`);
      }
    });
  }

  /**
   * 取消监听主窗口系统规避区变化
   *
   * @param windowStage Stage模型window容器
   * @param callback 取消监听主窗口系统规避区变化回调
   */
  static offAvoidAreaChange(windowStage: window.WindowStage, callback: (data: AvoidAreaParams) => void) {
    let windowClass: window.Window | undefined = undefined;
    windowStage.getMainWindow((err: BusinessError, data) => {
      const errCode: number = err.code;
      if (errCode) {
        LogUtil.error(`${TAG} Failed to obtain the main window. Cause code: ${err?.code}, message: ${err?.message}`);
        return;
      }
      windowClass = data;
      try {
        windowClass.off('avoidAreaChange', callback);
      } catch (exception) {
        LogUtil.error(`${TAG} Failed to listen avoidAreaChange. ` +
          `Cause code: ${exception?.code}, message: ${exception?.message}`);
      }
    });
  }

  /**
   * Loads content and set global windowStage info
   * @param windowStage window manager
   * @param pageUrl path of the page to which the content will be loaded
   * @param externalNavigationUrl navigation url
   */
  static loadContent(windowStage: window.WindowStage, pageUrl: string, externalNavigationUrl: string): void {
    LogUtil.info(`${TAG} loadContent, pageUrl: ${pageUrl}, externalNavigationUrl: ${externalNavigationUrl}`);
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    let localStorage: LocalStorage = new LocalStorage({
      'externalWindowStage': windowStage,
    } as Record<string, window.WindowStage>);
    windowStage?.loadContent(pageUrl, localStorage).then(() => {
      WindowManager.setMainWindowBackgroundColor(windowStage, WINDOW_BACKGROUND_COLOR);
    });
    AppStorage.SetOrCreate('externalNavigationUrl', externalNavigationUrl);
  }

  /**
   * set keyboard avoid mode
   *
   * @param value the mode of keyboard avoid
   */
  setKeyboardAvoidMode(value: KeyboardAvoidMode): void {
    this.getCurrentWindow()?.getMainWindowSync().getUIContext().setKeyboardAvoidMode(value);
  }

  /**
   * 为当前窗口添加或删除安全水印标志
   *
   * @param enable 是否对窗口添加标志位。true表示添加，false表示删除
   */
  async setWaterMarkFlag(enable: boolean): Promise<void> {
    LogUtil.info(`setWaterMarkFlag, enable: ${enable}`);
    if (!Boolean(AppStorage.get<window.WindowStage>('windowStage')).valueOf()) {
      LogUtil.error('setWaterMarkFlag error, windowStage is empty');
      return;
    }

    try {
      let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
      if (!windowData) {
        const stage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
        windowData = await stage.getMainWindow();
      }
      setWaterMarkFlag(windowData, enable);
    } catch (exception) {
      LogUtil.error(`Failed to set water mark flag of window. Cause: ${exception?.message}`);
    }
  }

  /**
   * 设置窗口的显示方向属性
   *
   * @param stage 窗口管理器
   * @param orientation 窗口显示方向
   */
  static async setWindowOrientation(stage: window.WindowStage, orientation: window.Orientation): Promise<void> {
    if (!stage || !orientation) {
      return;
    }
    let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
    if (!windowData) {
      windowData = await stage.getMainWindow();
    }
    WindowManager.setPreferredOrientation(windowData, orientation);
  }

  static async setWindowProperties(context: Context, windowStage: window.WindowStage): Promise<void> {
    let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
    if (!windowData) {
      windowData = await windowStage.getMainWindow();
    }
    try {
      // 第一次会错过监听
      let windowStatusType = windowData?.getWindowStatus();
      if (windowStatusType) {
        LogUtil.info(`${TAG} getWindowStatus, window status type is ${windowStatusType}`);
        AppStorage.setOrCreate<number>('windowMode', windowStatusType);
        SettingsDataUtils.setSettingsDataWithContext(context, 'settings.windowMode', String(windowStatusType));
      }
    } catch (err) {
      LogUtil.error(`${TAG} setWindowProperties failed. Error code: ${err.code} message: ${err.message}`);
    }

    Promise.resolve(windowData.on('windowStatusChange', (windowStatusType: window.WindowStatusType) => {
      LogUtil.info(`${TAG} windowStatusChange, window type is ${windowStatusType}`);
      AppStorage.setOrCreate<number>('windowMode', windowStatusType);
      SettingsDataUtils.setSettingsDataWithContext(context, 'settings.windowMode', String(windowStatusType));
    }));
  }

  /**
   * 适配深色模式
   * @param colorModeConfig 深色模式配置
   */
  static async setSystemBar(colorModeConfig: ConfigurationConstant.ColorMode): Promise<void> {
    AppStorage.setOrCreate<number>('changeMode', colorModeConfig);
    let isLightColorMode: boolean = colorModeConfig === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    const properties: window.SystemBarProperties = {
      statusBarContentColor: isLightColorMode ? WINDOW_BG_BLACK : WINDOW_BG_WHITE,
      navigationBarContentColor: isLightColorMode ? WINDOW_BG_BLACK : WINDOW_BG_WHITE,
    };
    let bgColor: string = isLightColorMode ? WINDOW_BG_APP : WINDOW_BG_BLACK;
    let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
    if (!windowData) {
      let stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      windowData = await stage.getMainWindow();
    }
    LogUtil.warn(`${TAG} setWindowBackgroundColor:  bgColor is ${bgColor}`);
    windowData = await WindowManager.adjustWindow(windowData);
    WindowManager.setWindowBackgroundColor(bgColor, windowData);
    WindowManager.setWindowSystemBarProperties(properties, windowData);
  }

  /**
   * 若当前使用的window不是主window，则将其替换成主window，当前文件是在common层, 因此还是先以 mainWindow 作为key来获取,避免其他类型
   * 产品调用该方法时导致获取的window异常
   *
   * @param windowData 根据key为'mainWindow'从AppStorage中获取到 window对象
   * @returns 调整后的window对象
   */
  static async adjustWindow(windowData: window.Window): Promise<window.Window> {
    let mainWindow: window.Window | undefined = AppStorage.get<window.Window>(MainConstants.MAIN_ABILITY_WINDOW);
    if (!mainWindow) {
      const stage: window.WindowStage | undefined =
        AppStorage.get<window.WindowStage>(MainConstants.MAIN_WINDOW_STAGE) as window.WindowStage;
      if (stage) {
        mainWindow = await stage.getMainWindow();
      }
    }
    const windowId: number | undefined = windowData?.getWindowProperties()?.id;
    const mainWindowId: number | undefined = mainWindow?.getWindowProperties()?.id;
    LogUtil.showInfo(TAG, `windowId: ${windowId}, mainWindowId: ${mainWindowId}`);
    if (mainWindow && windowId !== mainWindowId) {
      windowData = mainWindow;
    }
    return windowData;
  }

  static setMainWindowBgColorByColorMode(windowStage: window.WindowStage,
                                         colorModeConfig: ConfigurationConstant.ColorMode): void {
    let color = colorModeConfig === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ? WINDOW_BG_APP : WINDOW_BG_BLACK;
    windowStage.getMainWindow().then((data) => {
      AppStorage.setOrCreate<window.Window>('mainWindow', data);
      // ExternalWifiSettingsAbility会导致AppStorage中的window和windowstage被覆盖，临时方案是将主window多存一份
      AppStorage.setOrCreate<window.Window>(MainConstants.MAIN_ABILITY_WINDOW, data);
      LogUtil.showWarn(TAG, `set current window id : ${data?.getWindowProperties()?.id}`);
      WindowManager.setWindowBackgroundColor(color, data);
      let windowRect: window.Rect = data.getWindowProperties().windowRect;
      WindowManager.setNavBarWidth(windowRect.width);
      AppStorage.setOrCreate<window.Size>('windowSize', { width: windowRect.width, height: windowRect.height });
      try {
        AppStorage.setOrCreate<number>('windowTitleHeight', data?.getWindowDecorHeight() ?? 0);
      } catch (err) {
        LogUtil.error(`${TAG} getWindowDecorHeight fail: code: ${err?.code} message: ${err?.message}`);
      }
      LogUtil.showInfo(TAG, `backgroundColor: ${color}, windowSize: (${windowRect.width}, ${windowRect.height})`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} getMainWindow fail: code: ${err?.code} message: ${err?.message}`);
    });
  }

  static setWindowBackgroundColor(color: string, window: window.Window): void {
    try {
      setBgColor(window, color);
    } catch (err) {
      LogUtil.error(`${TAG} setWindowBackgroundColor fail, code: ${err?.code} message: ${err?.message}`);
    }
  }

  static setWindowSystemBarProperties(properties: window.SystemBarProperties, window: window.Window): void {
    try {
      setSystemBar(window, properties);
    } catch (err) {
      LogUtil.error(`${TAG} setWindowSystemBarProperties fail, code: ${err?.code} message: ${err?.message}`);
    }
  }

  /**
   * 隐藏或显示浮窗
   *
   * @param shouldHide true表示隐藏，false表示取消隐藏
   * @returns
   */
  static async hideOrShowNonSystemFloatingWindows(shouldHide: boolean): Promise<void> {
    let windowData: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
    if (!windowData) {
      let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      windowData = await windowStage.getMainWindow();
    }
    try {
      LogUtil.showInfo(TAG, `hideOrShowNonSystemFloatingWindows ${shouldHide}`);
      hideOrShowFloatingWindows(windowData, shouldHide);
    } catch (err) {
      LogUtil.error(`${TAG} hideOrShowNonSystemFloatingWindows fail, code: ${err?.code} message: ${err?.message}`);
    }
  }

  static setPreferredOrientation(window: window.Window, orientation: window.Orientation): void {
    try {
      setOrientation(window, orientation);
    } catch (err) {
      LogUtil.error(`${TAG} setPreferredOrientation fail, code: ${err?.code} message: ${err?.message}`);
    }
  }

  static async adjustOrientation(): Promise<void> {
    try {
      const status: display.FoldStatus = await display.getFoldStatus();
      DisplayManager.getInstance().setFoldStatus(status as number);
    } catch (e) {
      LogUtil.error(`${TAG} set orientation error message: ${e?.message}`);
    }
  }

  static async registerFoldChangeListener(): Promise<void> {
    if (!DeviceUtil.isFoldable()) {
      return;
    }
    try {
      display.on('foldStatusChange', (status: number) => {
        LogUtil.info(`on fold status changed: ${status}`);
        DisplayManager.getInstance().setFoldStatus(status);
        emitter.emit({
          eventId: EVENT_ID_FOLD_STATUS_CHANGE,
          priority: emitter.EventPriority.IMMEDIATE,
        }, {
          data: {
            EVENT_KEY_FOLD_STATUS_CHANGE: status,
          }
        });
      })
    } catch (err) {
      LogUtil.error(`${TAG} register foldStatusChange: code: ${err?.code} message: ${err?.message}`);
    }
  }

  static unregisterFoldChangeListener(): void {
    if (DeviceUtil.isFoldable()) {
      try {
        display.off('foldStatusChange');
      } catch (e) {
        LogUtil.error(`${TAG} unregister foldStatusChange: ${e?.message}`);
      }
    }
  }

  static async registerWindowStageListener(): Promise<void> {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      if (stage) {
        stage.on('windowStageEvent', (event: window.WindowStageEventType) => {
          LogUtil.info(`${TAG} on window stage changed: ${event}`);
          emitter.emit({
            eventId: EVENT_ID_ON_WINDOW_STAGE_CHANGED,
            priority: emitter.EventPriority.IMMEDIATE,
          }, {
            data: {
              KEY_ID_FINGERPRINT_DB_UPDATE: event,
            }
          });
        });
      }
    } catch (err) {
      LogUtil.error(`${TAG} register window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  static unregisterWindowStageListener(): void {
    try {
      const stage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
      if (stage) {
        stage?.off('windowStageEvent');
      }
    } catch (err) {
      LogUtil.error(`${TAG} unregister window stage listener failed: code: ${err?.code} message: ${err?.message}`);
    }
  }

  /**
   * vp转化成px，不受窗口属性影响
   *
   * @param value 传入的vp值
   * @returns 根据当前DPI转化后的的px值
   */
  static vpToPx(value: number): number {
    try {
      let dpi: number = display.getDefaultDisplaySync().densityDPI;
      let pxValue: number = dpi / VP_TO_PX_SCALE * value;
      return pxValue;
    } catch (err) {
      LogUtil.error(`${TAG} vpToPx failed: code: ${err?.code}`);
      return value;
    }
  }

  /**
   * 字体过大的情况需要为wifi window弹框添加额外高度，避免截断
   *
   * @returns 字体变大后额外增加的高度
   */
  static getExtraFontScaleHeight(isHiLink?: boolean): number {
    let value: number = 0;
    const extraHeight: number = 18;
    try {
      let currentFontScaleSize: number = Number(SettingsDataUtils
        .getSettingsDataDomain(Settings.display.FONT_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE,
          Settings.domainName.USER_PROPERTY));
      // 字体放大后，需要额外增加高度让弹框window不截断
      if (currentFontScaleSize > DisplayConstant.TEXT_FONT_SIZE_LARGE) {
        value = extraHeight;
      }
      if (isHiLink) {
        let hiLinkContentText: string = ResourceUtil.getFormatStringByNameSync('wifi_hlink_description', '');
        let hiLinkContentSize: SizeOptions = measure.measureTextSize({
          textContent: hiLinkContentText,
          fontSize: $r('sys.float.Body_M'),
          fontWeight: FontWeight.Regular,
          fontFamily: 'HarmonyHeiTi'
        });
        let contentWidth: number = vp2px(352);
        let lines: number = Number(hiLinkContentSize.width) / contentWidth;
        value = lines > 2 ? px2vp(Number(hiLinkContentSize.height)) + 6 : 0;
      }
      return value;
    } catch (err) {
      LogUtil.error(`${TAG} getExtraFontPadding failed: code: ${err?.code}`);
      return value;
    }
  }

  /**
   * 获取 Window 窗口背景色
   *
   */
  public static getDialogWindowBackgroundColor(): string {
    try {
      LogUtil.info(`${TAG} getDarkMode sucess`);
      return uiAppearance.getDarkMode() === COLOR_MODE_DARK ?
        DIALOG_WINDOW_ULTRA_THICK_BLACK : DIALOG_WINDOW_ULTRA_THICK_WHITE;
    } catch (err) {
      LogUtil.error(`${TAG} getDarkMode fail`);
      return DIALOG_WINDOW_ULTRA_THICK_WHITE;
    }
  }

  /**
   * 智慧屏navigation不支持设置栅格，手动计算navBarWidth
   *
   * @param value 窗宽
   */
  public static updateGridColumnsTV(windowWidth: number): void {
    let pageWidth: Record<string, number> = WindowManager.getHomeNavWidthTV(windowWidth);
    AppStorage.setOrCreate<number>(GRID_COLUMN_WIDTH_KEY, pageWidth.columnWidth);
    AppStorage.setOrCreate<number>(GRID_ROW_MARGIN_FULL_PAGE_KEY,
      pageWidth.columnWidth * GRID_CONTENT_MARGIN_RATIO);
    AppStorage.setOrCreate<number>(GRID_ROW_HOME_WIDTH_KEY, pageWidth.homeNavWidth);
  }

  /**
   * 获取智慧屏navigation宽
   * @param value 窗宽
   * @returns 智慧屏navigation宽
   */
  public static getHomeNavWidthTV(windowWidth: number): Record<string, number> {
    let densityPixels: number = display.getDefaultDisplaySync().densityPixels;
    if (densityPixels === 0) {
      LogUtil.error(`${TAG} densityPixels is 0`);
      return {
        'columnWidth': 0,
        'homeNavWidth': 0
      };
    }
    let windowWidthVp: number = windowWidth / densityPixels;
    let columnWidth: number = (windowWidthVp - GRID_ROW_MARGIN * 2 -
      (GRID_ROW_COLUMNS - 1) * GRID_ROW_GUTTER) / GRID_ROW_COLUMNS;
    let homeNavWidth: number = columnWidth * GRID_COLUMN_HOME_SPAN +
      GRID_COLUMN_HOME_GUTTER_WIDTH + GRID_ROW_MARGIN;
    return {
      'columnWidth': columnWidth,
      'homeNavWidth': homeNavWidth
    };
  }
}

@Concurrent
export async function getNavBarWidth(width: number, context: Context): Promise<number> {
  const widthScale: number = 0.4;
  const maxNavBarWidth: number = 480;
  const VP_TO_PX_SCALE: number = 160;
  const DPI_VALUE_NULL: string = '';
  const DISPLAY_DPI: string = 'system_default_dpi_value';
  let calNavBarWidth: number = 0;
  try {
    let dpiValue: string = SettingsDataUtils.getSettingsDataWithContext(context, DISPLAY_DPI, '');
    LogUtil.info(`getNavBarWidth dpiValue is ${dpiValue}`);
    if (dpiValue === DPI_VALUE_NULL) {
      calNavBarWidth = Math.min(width * widthScale, maxNavBarWidth * display.getDefaultDisplaySync()
        .densityDPI / VP_TO_PX_SCALE);
    } else {
      calNavBarWidth = Math.min(width * widthScale, maxNavBarWidth * Number.parseInt(dpiValue) / VP_TO_PX_SCALE);
    }
    LogUtil.info(`getNavBarWidth navigation bar width: ${calNavBarWidth}`);
  } catch (error) {
    LogUtil.error(`getNavBarWidth failed: ${error?.message}`);
  }
  return calNavBarWidth;
}

@Concurrent
function setBgColor(window: window.Window, color: string): void {
  window.setWindowBackgroundColor(color);
}

@Concurrent
function setSystemBar(window: window.Window, properties: window.SystemBarProperties): void {
  window.setWindowSystemBarProperties(properties);
}

@Concurrent
function hideOrShowFloatingWindows(window: window.Window, shouldHide: boolean): void {
  window.hideNonSystemFloatingWindows(shouldHide);
}

@Concurrent
function setOrientation(window: window.Window, orientation: window.Orientation): void {
  window.setPreferredOrientation(orientation);
}

@Concurrent
function setWaterMarkFlag(window: window.Window, enable: boolean): void {
  window.setWaterMarkFlag(enable);
}