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

import settings from '@ohos.settings';
import window from '@ohos.window';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import {
  AvoidAreaDirect,
  AvoidAreaParams,
  WindowManager,
  getNavBarWidth
} from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

/**
 * 关于本机title的高度
 */
export const ABOUT_DEVICE_TITLE_BAR_HEIGHT = 56;

/**
 * 关于本机页面左右边距
 */
export const PAGE_HORIZON_PADDING_RESOURCE = (DeviceUtil.isDevicePad() || DeviceUtil.isDevicePc())
  ? $r('app.float.padding_24') : $r('app.float.padding_16');

const PAGE_HORIZON_PADDING = (DeviceUtil.isDevicePad() || DeviceUtil.isDevicePc()) ? 24 : 16;
const NAV_MODE_LINE = 600;

/**
 * 关于本机标题和卡片间距
 */
export const PADDING_BETWEEN_TITLE_AND_CARD = 16;

/**
 * 关于本机卡片和右边设备名称间距
 */
export const PADDING_LEFT_CARD = 12;

/**
 * ouc模拟器图片margin，或ouc预加载图片margin
 */
export const OUC_CARD_IMG_MARGIN: Padding = {
  top: ABOUT_DEVICE_TITLE_BAR_HEIGHT + PADDING_BETWEEN_TITLE_AND_CARD,
  bottom: '0',
  left: PAGE_HORIZON_PADDING_RESOURCE,
  right: PAGE_HORIZON_PADDING_RESOURCE,
}

/**
 * 关于本机卡片高度在appStorage中的key
 */
export const ABOUT_DEVICE_FOLD_CARD_LENGTH = 'aboutDeviceFoldCardLength';
const TAG = 'OucAboutDeviceViewModel';
const VIDEO_ASPECT_RATIO_BIG = 3;
const VIDEO_ASPECT_RATIO_SMALL = 1.5;
const VIDEO_ASPECT_RATIO_VDE = 16 / 7;
const FOLD_PHONE_FOLD_WIDTH = 1080;
const SMALL_WINDOW_CARD_HEIGHT = 300;
const FIRMWARE_UPGRADE = 'com_hmos_ouc_software_update_settings';
const RECHECK = 'com_ohos_ouc_recheck_settings';
const SMALL_VIDEO_MIN_HEIGHT = 100;
const ABOUT_DEVICE_CARD_BIG_ASPECT = 9 / 16;
const ABOUT_DEVICE_CARD_SMALL_ASPECT = 1 / 3;
const ABOUT_DEVICE_CARD_VDE_ASPECT = 2 / 3;
const TV_DEVICE_CARD_ASPECT = 2 / 5;

/**
 * 关于本机页面信息
 *
 * @since 2024-05-06
 */
export class PageInfo {
  /**
   * 页面宽度
   */
  public pageWidth: number = 0;

  /**
   * 页面高度
   */
  public pageHeight: number = 0;

  /**
   * 去掉安全区之后的页面高度
   */
  public pageHeightExcludeAvoidArea: number = 0;

  /**
   * 上面安全区高度
   */
  public avoidAreaTopHeight: number = 0;

  /**
   * 下面安全区的高度
   */
  public avoidAreaBottomHeight: number = 0;

  /**
   * 卡片实际高度
   */
  public reallyFoldCardHeight: number = 0;

  /**
   * ouc新版本界面卡片高度
   */
  public oucNewVersionCardHeight: number = 0;

  /**
   * 全屏下关于本机nav内容区宽度，单位px
   */
  private navContentWidthInFullScreenPixel: number = 0;

  /**
   * pc设备的宽
   */
  private pcScreenWidthPixel: number = 0;

  constructor() {
    if (DeviceUtil.isDevicePhone() && DeviceUtil.isFoldable() && !DeviceUtil.isSmallFoldProduct()) {
      // 手机大折叠
      this.navContentWidthInFullScreenPixel = FOLD_PHONE_FOLD_WIDTH;
      return;
    }
    let display = DisplayUtils.getDefaultDisplaySyncInfo();
    if (DeviceUtil.isDevicePc()) {
      this.pcScreenWidthPixel = Math.max((display?.width ?? 0), (display?.height ?? 0));
      return;
    }
    if (DeviceUtil.isDevicePad()) {
      // 设备横屏全屏宽度
      let screenWidth = Math.max((display?.width ?? 0), (display?.height ?? 0));
      this.navContentWidthInFullScreenPixel = screenWidth * 0.6;
      return;
    }
    // 设备竖屏全屏宽度
    let screenWidth = Math.min((display?.width ?? 0), (display?.height ?? 0));
    this.navContentWidthInFullScreenPixel = screenWidth;
  }

  /**
   * 获取全屏模式下卡片高度
   *
   * @returns 全屏模式下卡片高度
   */
  public getFoldCardHeightInFullScreen(): number {
    if (DeviceUtil.isDevicePc()) {
      let pcScreenWidthVp = px2vp(this.pcScreenWidthPixel);
      let pcNavWidthVp = WindowManager.getPcSettingsNavBarWidth(pcScreenWidthVp);
      let navDesDynamicPadding = WindowManager.getPcSettingsPagePadding(pcScreenWidthVp);
      let pcNavContentWidthVp = pcScreenWidthVp - pcNavWidthVp - navDesDynamicPadding * 2;
      let cardWidth = pcNavContentWidthVp - PAGE_HORIZON_PADDING * 2;
      return cardWidth * ABOUT_DEVICE_CARD_SMALL_ASPECT;
    }
    let cardWidth = px2vp(this.navContentWidthInFullScreenPixel) - PAGE_HORIZON_PADDING * 2;
    if (DeviceUtil.is2In1DevicePcType()) {
      return cardWidth * ABOUT_DEVICE_CARD_SMALL_ASPECT;
    }
    if (DeviceUtil.isDevicePad()) {
      return cardWidth * ABOUT_DEVICE_CARD_BIG_ASPECT;
    }
    if (DeviceUtil.isNexFormsProduct()) {
      return cardWidth * ABOUT_DEVICE_CARD_VDE_ASPECT;
    }
    return cardWidth;
  }
}

/**
 * 关于本机OUC卡片工具
 *
 * @since 2024-03-29
 */
export class OucAboutDeviceViewModel {
  private static pageInfo: PageInfo = new PageInfo();

  private static getSettingsWindowStatusType(): window.WindowStatusType | undefined {
    LogUtil.info(`${TAG} getSettingsWindowStatusType`);
    try {
      let mainWindow: window.Window | undefined = AppStorage.get<window.Window>('mainWindow');
      if (!mainWindow) {
        mainWindow = AppStorage.get<window.WindowStage>('windowStage')?.getMainWindowSync();
      }
      if (!mainWindow) {
        LogUtil.error(`${TAG} getSettingsWindowStatusType get mainWindow failed.`);
        return undefined;
      }
      let windowStatusType: window.WindowStatusType = mainWindow.getWindowStatus();
      if (windowStatusType) {
        AppStorage.setOrCreate<number>('windowMode', windowStatusType);
        SettingsDataUtils.setSettingsDataAsyncWithContext(AbilityContextManager.getMainAbilityContext(),
          'settings.windowMode', String(windowStatusType));
      }
      return windowStatusType;
    } catch (err) {
      LogUtil.error(`${TAG} getSettingsWindowStatusType failed. Error code: ${err.code} message: ${err.message}`);
    }
    return undefined;
  }

  private static calReallyFoldCardHeight(pageWidth: number): void {
    let calWidth = pageWidth - 2 * PAGE_HORIZON_PADDING;
    let windowStatusType = AppStorage.get<number>('windowMode') ??
      OucAboutDeviceViewModel.getSettingsWindowStatusType();
    LogUtil.info(`${TAG}: windowStatusType ${windowStatusType}`);
    switch (windowStatusType) {
      case window.WindowStatusType.FULL_SCREEN: // To 全屏
        OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight =
          OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen();
        break;
      case window.WindowStatusType.FLOATING: // To 悬浮窗
        OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight =
          OucAboutDeviceViewModel.getFoldCardHeightInFloating(calWidth);
        break;
      case window.WindowStatusType.MAXIMIZE: // 最大窗口
      case window.WindowStatusType.MINIMIZE: // 最小窗口
      case window.WindowStatusType.SPLIT_SCREEN: // 分屏 不改变窗口高度
      default:
        OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight =
          OucAboutDeviceViewModel.getFoldCardHeightInSplitOrMax(calWidth);
        break;
    }
    AppStorage.setOrCreate(ABOUT_DEVICE_FOLD_CARD_LENGTH, OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight);
  }

  private static getFoldCardHeightInFloating(calWidth: number): number {
    if (DeviceUtil.isDevicePc()) {
      return Math.min(calWidth * ABOUT_DEVICE_CARD_BIG_ASPECT,
        OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen());
    }
    if (DeviceUtil.is2In1DevicePcType()) {
      return Math.min(calWidth * ABOUT_DEVICE_CARD_BIG_ASPECT,
        OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen());
    }
    if (DeviceUtil.isNexFormsProduct()) {
      return calWidth * ABOUT_DEVICE_CARD_VDE_ASPECT;
    }
    if (calWidth <= SMALL_WINDOW_CARD_HEIGHT) {
      return calWidth;
    }
    return SMALL_WINDOW_CARD_HEIGHT;
  }

  private static getFoldCardHeightInSplitOrMax(calWidth: number): number {
    if (DeviceUtil.isDevicePc()) {
      return Math.min(calWidth * ABOUT_DEVICE_CARD_BIG_ASPECT,
        OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen());
    }
    if (DeviceUtil.is2In1DevicePcType()) {
      return Math.min(calWidth * ABOUT_DEVICE_CARD_BIG_ASPECT,
        OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen());
    }
    if (DeviceUtil.is2In1DevicePadType()) {
      let min = Math.min(calWidth * ABOUT_DEVICE_CARD_BIG_ASPECT,
        OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen());
      return Math.max(min, SMALL_WINDOW_CARD_HEIGHT);
    }
    return OucAboutDeviceViewModel.pageInfo.getFoldCardHeightInFullScreen();
  }

  private static calOucNewVersionCardHeight(pageWidth: number): void {
    let calWidth = pageWidth - 2 * PAGE_HORIZON_PADDING;
    let ratio: number = OucAboutDeviceViewModel.getVideoAspectRatio();
    if (ratio !== 0) {
      OucAboutDeviceViewModel.pageInfo.oucNewVersionCardHeight = Math.max(calWidth / ratio, SMALL_VIDEO_MIN_HEIGHT);
    }
  }

  private static getVideoAspectRatio(): number {
    if (DeviceUtil.isNexFormsProduct()) {
      return VIDEO_ASPECT_RATIO_VDE;
    }
    if (DeviceUtil.isDevicePc() || (DeviceUtil.isDevicePad() && !DeviceUtil.isDevicePortrait())) {
      return VIDEO_ASPECT_RATIO_BIG;
    }
    return VIDEO_ASPECT_RATIO_SMALL;
  }

  private static isExpandSafeArea(): boolean {
    return !(DeviceUtil.isDevicePc());
  }

  private static setPageInfo(pageArea: Area): void {
    OucAboutDeviceViewModel.pageInfo.pageWidth = pageArea.width as number;
    OucAboutDeviceViewModel.pageInfo.pageHeight = pageArea.height as number;
    OucAboutDeviceViewModel.calReallyFoldCardHeight(pageArea.width as number);
    OucAboutDeviceViewModel.calOucNewVersionCardHeight(pageArea.width as number);
    OucAboutDeviceViewModel.calAvoidArea();
  }

  private static calAvoidArea(): void {
    if (OucAboutDeviceViewModel.isExpandSafeArea()) {
      OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight = px2vp(WindowManager.getAvoidAreaHeight(
        AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage, AvoidAreaDirect.TOP,
        window.AvoidAreaType.TYPE_SYSTEM));
      OucAboutDeviceViewModel.pageInfo.avoidAreaBottomHeight = px2vp(WindowManager.getAvoidAreaHeight(
        AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage, AvoidAreaDirect.BOTTOM,
        window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR));
    }
    OucAboutDeviceViewModel.pageInfo.pageHeightExcludeAvoidArea = OucAboutDeviceViewModel.pageInfo.pageHeight -
      OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight - OucAboutDeviceViewModel.pageInfo.avoidAreaBottomHeight;
  }

  /**
   * 主窗口系统避让区变化回调
   *
   * @param data 系统避让区变化数据
   * @returns 是否正在变化，需要刷新页面
   */
  public static onAvoidAreaChange(data: AvoidAreaParams): boolean {
    let isRealChange: boolean = false;
    if (OucAboutDeviceViewModel.isExpandSafeArea()) {
      if (data?.type === window.AvoidAreaType.TYPE_SYSTEM) {
        let topAvoidAreaHeight = px2vp(data?.area?.topRect?.height ?? 0);
        isRealChange = OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight !== topAvoidAreaHeight;
        OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight = topAvoidAreaHeight;
      }
      if (data?.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottomAvoidAreaHeight = px2vp(data?.area?.bottomRect?.height ?? 0);
        isRealChange = OucAboutDeviceViewModel.pageInfo.avoidAreaBottomHeight !== bottomAvoidAreaHeight;
        OucAboutDeviceViewModel.pageInfo.avoidAreaBottomHeight = bottomAvoidAreaHeight;
      }
    }
    OucAboutDeviceViewModel.pageInfo.pageHeightExcludeAvoidArea = OucAboutDeviceViewModel.pageInfo.pageHeight -
      OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight - OucAboutDeviceViewModel.pageInfo.avoidAreaBottomHeight;
    LogUtil.info(`${TAG} onAvoidAreaChange.`);
    return isRealChange;
  }

  /**
   * 首次加载页面处理
   *
   * @returns
   */
  public static aboutToAppearPageProcess(): void {
    let pageArea: Area = {
      width: OucAboutDeviceViewModel.getPageWidthSettingStart(),
      height: OucAboutDeviceViewModel.getPageHeightSettingStart(),
      position: {},
      globalPosition: {}
    };
    LogUtil.info(`${TAG} aboutToAppearPageProcess pageArea:` +
      ` ,pageWidth:${pageArea.width as number} ,pageHeigh:${pageArea.height as number}`);
    OucAboutDeviceViewModel.setPageInfo(pageArea);
  }

  private static getPageWidthSettingStart(): number {
    let windowSize: window.Size = AppStorage.get<window.Size>('windowSize') ?? { width: 0, height: 0 };
    let startNavMode: NavigationMode = px2vp(windowSize.width) >=
      NAV_MODE_LINE ? NavigationMode.Split : NavigationMode.Stack;
    LogUtil.info(`${TAG} getPageWidthSettingStart windowWidth: ${windowSize.width},` +
      ` windowHeight: ${windowSize.height}, startNavMode:${startNavMode}`);
    if (startNavMode === NavigationMode.Stack) {
      return px2vp(windowSize.width);
    }
    if (DeviceUtil.isDevicePc()) {
      let windowSizeVp = px2vp(windowSize.width);
      let navBarWidth = WindowManager.getPcSettingsNavBarWidth(windowSizeVp);
      let navDesDynamicPadding = WindowManager.getPcSettingsPagePadding(windowSizeVp);
      return windowSizeVp - navBarWidth - navDesDynamicPadding * 2;
    }
    return px2vp(windowSize.width - (AppStorage.get<number>('calNavBarWidth') ?? 0));
  }

  private static getPageHeightSettingStart(): number {
    let windowSize: window.Size = AppStorage.get<window.Size>('windowSize') ?? { width: 0, height: 0 };
    let isFreeWindow: boolean = SettingsDataUtils.getSettingsData('window_pcmode_switch_status', 'false',
      settings.domainName.USER_PROPERTY) === 'true';
    let windowTitleHeight: number = AppStorage.get<number>('windowTitleHeight') ?? 0;
    LogUtil.info(`${TAG} getPageHeightSettingStart isFreeWindow: ${isFreeWindow},` +
      ` windowTitleHeight: ${windowTitleHeight}`);
    return px2vp(windowSize.height) - (isFreeWindow ? windowTitleHeight : 0);
  }

  /**
   * 页面尺寸变化处理
   *
   * @param pageArea 页面尺寸
   * @returns 是否发生改变
   */
  public static onPageAreaChange(pageArea: Area): boolean {
    LogUtil.info(`${TAG} onPageAreaChange pageArea: ${pageArea.width as number} ${pageArea.height as number}`);
    if (Math.round(pageArea.width as number) === Math.round(OucAboutDeviceViewModel.pageInfo.pageWidth) &&
      Math.round(pageArea.height as number) === Math.round(OucAboutDeviceViewModel.pageInfo.pageHeight) ) {
      return false;
    }
    OucAboutDeviceViewModel.setPageInfo(pageArea);
    return true;
  }

  /**
   * 获取list移动到bottom的距离
   *
   * @return list移动到bottom的距离
   */
  public static getListMoveBottomLength(): number {
    return OucAboutDeviceViewModel.pageInfo.pageHeight -
      OucAboutDeviceViewModel.pageInfo.avoidAreaTopHeight -
      ABOUT_DEVICE_TITLE_BAR_HEIGHT -
      PADDING_BETWEEN_TITLE_AND_CARD -
      OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight;
  }

  /**
   * 获取list与标题之间的距离
   *
   * @returns list与标题之间的距离
   */
  public static getListColumnMarginTop(): number {
    return PADDING_BETWEEN_TITLE_AND_CARD +
      OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight;
  }

  /**
   * 获取List到OUC新版本页面的移动距离
   *
   * @param smallVideoRatio 视频比例
   * @return List到OUC新版本页面的移动距离
   */
  public static getListToOucNewVersionMoveLength(smallVideoRatio: number): number {
    let calWidth = OucAboutDeviceViewModel.pageInfo.pageWidth - 2 * PAGE_HORIZON_PADDING;
    let oucSmallVideoHeight = (Number.isNaN(smallVideoRatio) || smallVideoRatio === 0) ?
      OucAboutDeviceViewModel.pageInfo.oucNewVersionCardHeight : calWidth / smallVideoRatio;
    return oucSmallVideoHeight - OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight;
  }

  /**
   * 获取卡片高度
   *
   * @return 卡片高度
   */
  public static getReallyFoldCardHeight(): number {
    return OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight;
  }

  /**
   * ouc column高度百分比：关于本机页面高度减小（手机分屏或者pc缩小窗口高度）时，调整ouc组件高度
   * 保证ouc卡片布局所需的最小高度
   *
   * @returns ouc column高度百分比
   */
  public static getOucColumnPercent(): string {
    let oucNeedMinHeight = ABOUT_DEVICE_TITLE_BAR_HEIGHT +
      PADDING_BETWEEN_TITLE_AND_CARD +
      OucAboutDeviceViewModel.pageInfo.reallyFoldCardHeight;
    if (OucAboutDeviceViewModel.pageInfo.pageHeightExcludeAvoidArea < oucNeedMinHeight &&
      OucAboutDeviceViewModel.pageInfo.pageHeightExcludeAvoidArea > 0) {
      return ((oucNeedMinHeight / OucAboutDeviceViewModel.pageInfo.pageHeightExcludeAvoidArea) * 100) + '%';
    }
    return '100%';
  }

  /**
   * AboutToAppear生命周期获取跳转地址
   *
   * @param pushParams 参数
   * @returns 跳转地址
   */
  public static getTargetSubRouterAboutToAppear(pushParams: PushParam | null | undefined): string {
    let targetSubRouter = AppStorage.get<string>('com_hmos_ouc_software_update_settings_target_sub_router') ?? '';
    return !CheckEmptyUtils.checkStrIsEmpty(targetSubRouter) ? targetSubRouter :
      OucAboutDeviceViewModel.getTargetSubRouter(pushParams);
  }

  /**
   * 获取跳转地址
   *
   * @param pushParams 参数
   * @returns 跳转地址
   */
  public static getTargetSubRouter(pushParams: PushParam | null | undefined): string {
    if (pushParams === null || pushParams === undefined) {
      return '';
    }
    let config: string | undefined = undefined;
    if (!CheckEmptyUtils.isEmpty(pushParams?.config) && typeof pushParams?.config === 'string') {
      // 设置搜索会通过config传递subUrl，且不会经过SettingsHome的handleOUCNavigationUrlChange
      // 设置搜索会在config后面拼接,isShowBack:false，如：
      // ==>搜索软件更新：com_hmos_ouc_software_update_settings,isShowBack:false
      // ==>搜索关于本机中其他不进内页的项目内容：,isShowBack:false
      LogUtil.info(`${TAG} config`);
      config = pushParams.config.toString();
    }
    let targetSubRouter: string = config ?? (pushParams.subUri ?? '');
    LogUtil.info(`${TAG} targetSubRouter:${targetSubRouter}`);
    targetSubRouter = targetSubRouter?.split(',')[0];
    return targetSubRouter;
  }

  /**
   * aboutToAppear的时候，是否直接到OUC内页，类手机（适用于进OUC搜包场景）
   *
   * @param pushParams 关于本机页面跳转参数
   * @returns 是否直接到OUC内页
   */
  public static isToOUCLikePhone(pushParams: PushParam | null | undefined): boolean {
    let targetSubRouter: string = OucAboutDeviceViewModel.getTargetSubRouterAboutToAppear(pushParams);
    return OucAboutDeviceViewModel.isUriToOUCLikePhone(targetSubRouter);
  }

  /**
   * aboutToAppear的时候，是否直接到OUC内页，类手机（适用于进OUC搜包场景）
   *
   * @param targetSubRouter 跳转地址
   * @returns 是否直接到OUC内页
   */
  public static isUriToOUCLikePhone(targetSubRouter: string | null | undefined): boolean {
    if (DeviceUtil.is2In1DevicePcType()) {
      return OucAboutDeviceViewModel.isUriToOUCLikePC(targetSubRouter);
    }
    return !CheckEmptyUtils.isEmpty(targetSubRouter);
  }

  /**
   * aboutToAppear的时候，是否直接到OUC内页，类PC（适用于关于本机页面搜包场景）
   *
   * @param pushParams 关于本机页面跳转参数
   * @returns 是否直接到OUC内页
   */
  public static isToOUCLikePC(pushParams: PushParam | null | undefined): boolean {
    let targetSubRouter: string = OucAboutDeviceViewModel.getTargetSubRouterAboutToAppear(pushParams);
    return OucAboutDeviceViewModel.isUriToOUCLikePC(targetSubRouter);
  }

  /**
   * aboutToAppear的时候，是否直接到OUC内页，类PC（适用于关于本机页面搜包场景）
   *
   * @param targetSubRouter 跳转地址
   * @returns 是否直接到OUC内页
   */
  public static isUriToOUCLikePC(targetSubRouter: string | null | undefined): boolean {
    if (CheckEmptyUtils.isEmpty(targetSubRouter)) {
      return false;
    }
    const OUC_OUTER_PAGES = [FIRMWARE_UPGRADE, RECHECK];
    return OUC_OUTER_PAGES.every((uri: string) => targetSubRouter !== uri);
  }

  /**
   * 校验路由地址
   *
   * @param targetSubRouter 路由地址
   * @returns true or false
   */
  public static checkTargetSubRouter(targetSubRouter: string): boolean {
    return !CheckEmptyUtils.checkStrIsEmpty(targetSubRouter);
  }
}

/**
 * OUC卡片动效类型
 *
 * @since 2024-03-29
 */
export enum AnimateType {
  CHECKING = 1,
  NO_VERSION = 2,
  HAS_VERSION = 3,
}

/**
 * OUC卡片动效执行动作
 *
 * @since 2024-03-29
 */
export enum AboutDeviceCardAction {
  FOLD = 'fold',
  EXPAND = 'expand',
  POP = 'pop',
  SettingSearchBack = 'settingSearchBack',
  PRELOAD_IMG_HIDE = 'preloadImgHide',
  INIT_AGAIN = 'initAgain',
}

/**
 * OUC卡片和关于本机控制器通信数据类型
 *
 * @since 2024-03-29
 */
export interface AboutDeviceOucPublishData {
  aboutDeviceCardAction: AboutDeviceCardAction,
  animateType?: AnimateType,
  extraInfo?: Object,
}