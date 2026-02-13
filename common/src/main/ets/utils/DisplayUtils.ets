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

import Display from '@ohos.display';
import { DisplayConstant } from '../constant/DisplayConstant';
import { DeviceUtil } from './BaseUtils';
import { LogUtil } from './LogUtil';
import { SettingsDataUtils } from './SettingsDataUtils';

/* instrument ignore file */
const TAG: string = 'DisplayUtils';
const DE_FEATURE_COLORMODE = 11;
const DE_FEATURE_3D_COLOR_TEMPERATURE = 18;

export enum SheetDialogStyle {
  /**
   * 半模态底部弹窗样式
   */
  BOTTOM_DIALOG_STYLE = 0,
  /**
   * 半模态居中弹窗样式
   */
  CENTER_DIALOG_STYLE = 1,
  /**
   * 半模态跟手弹窗样式
   */
  FOLLOW_DIALOG_STYLE = 2,
}


export class DisplayUtils {
  public static registerFoldStatusChange(callback: (state: number) => void): void {
    if (!DeviceUtil.isFoldable()) {
      return;
    }
    try {
      Display.on('foldStatusChange', callback);
    } catch (err) {
      LogUtil.error(`${TAG} register foldStatusChange: code: ${err?.code} message: ${err?.message}`);
    }
  }

  public static unRegisterFoldStatusChange(callback: (state: number) => void): void {
    if (!DeviceUtil.isFoldable()) {
      return;
    }
    try {
      Display.off('foldStatusChange', callback);
    } catch (err) {
      LogUtil.error(`${TAG} unregister foldStatusChange: code: ${err?.code} message: ${err?.message}`);
    }
  }

  public static getDefaultDisplaySyncInfo(): Display.Display | undefined {
    try {
      return Display.getDefaultDisplaySync();
    } catch (err) {
      LogUtil.error(`${TAG} getDefaultDisplaySync failed: ${err?.message}`);
    }
    return undefined;
  }

  public static getFoldStatus(): Display.FoldStatus {
    try {
      return Display.getFoldStatus();
    } catch (err) {
      LogUtil.error(`${TAG} getFoldStatus failed: ${err?.message}`);
    }
    return Display.FoldStatus.FOLD_STATUS_UNKNOWN;
  }

  public static isFoldable(): boolean {
    try {
      return Display.isFoldable();
    } catch (err) {
      LogUtil.error(`${TAG} check isFoldable failed: ${err?.message}`);
    }
    return false;
  }

  /**
   * 高对比度是否已打开
   */
  public static isHighContrastOn(): boolean {
    let highContrast: string = SettingsDataUtils
      .getSecureValue(DisplayConstant.HIGH_TEXT_CONTRAST_ENABLED, DisplayConstant.HIGH_TEXT_CONTRAST_DEFAULT_VALUE);
    LogUtil.info(`${TAG} high_text_contrast_enabled: ${highContrast}`);
    return highContrast === DisplayConstant.HIGH_CONTRAST_ON;
  }

  /**
   * 获取当前设备屏幕比例
   *
   * @returns 当前设备屏幕宽高比
   */
  public static getScreenRation(): number {
    return (DisplayUtils.getDefaultDisplaySyncInfo()?.width ?? 0) /
      (DisplayUtils.getDefaultDisplaySyncInfo()?.height ?? 1);
  }

  /**
   * 获取当前设备屏幕宽度
   *
   * @returns 当前设备屏幕宽度
   */
  public static getScreenWidth(): number {
    return px2vp(DisplayUtils.getDefaultDisplaySyncInfo()?.width ?? 0);
  }

  /**
   * 获取当前设备屏幕高度
   *
   * @returns 当前设备屏幕高度
   */
  public static getScreenHeight(): number {
    return px2vp(DisplayUtils.getDefaultDisplaySyncInfo()?.height ?? 0);
  }

  /**
   * 获取插图大小
   *
   * @returns 插图尺寸
   */
  public static getIllustrationSize(navBarWidth: number, width?: number, height?: number): number {
    const displaySyncInfo = DisplayUtils.getDefaultDisplaySyncInfo();
    if (!displaySyncInfo) {
      LogUtil.error(`getDefaultDisplaySyncInfo error`);
      return 0;
    }
    height = px2vp(height ?? displaySyncInfo.height);
    width = px2vp(width ?? displaySyncInfo.width - navBarWidth);
    return Math.round(Math.min(Math.max(height, width) / 2, Math.min(height, width)) * 0.8);
  }

  /**
   * 判断当前屏幕是否为竖屏
   *
   * @return true: 竖屏  false: 横屏
   */
  public static isScreenPortraitOrientation(): boolean {
    const orientation: Display.Orientation = DisplayUtils.getDefaultDisplaySyncInfo()?.orientation ?? 0;
    return !(orientation === Display.Orientation.LANDSCAPE || orientation === Display.Orientation.LANDSCAPE_INVERTED);
  }

  /**
   * 获取当前屏幕宽度下，半模态的展示样式
   *
   * @return SheetDialogStyle 展示样式
   */
  public static getSheetStyle(): SheetDialogStyle {
    // 设备宽度小于600vp时，默认显示底部弹窗样式
    if (DisplayUtils.getScreenWidth() < 600) {
      return SheetDialogStyle.BOTTOM_DIALOG_STYLE;
    }
    // 设备宽度在600vp - 840vp之间时，默认显示居中弹窗样式
    if (DisplayUtils.getScreenWidth() <= 840) {
      return SheetDialogStyle.CENTER_DIALOG_STYLE;
    }
    // 设备宽度大于840vp时，默认显示跟手弹窗样式
    return SheetDialogStyle.FOLLOW_DIALOG_STYLE;
  }

  /**
   * 获取当前折叠设备的显示模式以及对应的物理屏幕分辨率信息对象
   *
   * @return DisplayPhysicalResolution 当前所有的对象(折叠设备的显示模式,设备的宽度,设备的高度)
   */
  public static async getAllDisplayPhysicalResolution(): Promise<Display.DisplayPhysicalResolution[]> {
    let resolutionObjects: Display.DisplayPhysicalResolution[] = [];
    try {
      resolutionObjects = await Display.getAllDisplayPhysicalResolution();
    } catch (err) {
      LogUtil.showError(TAG, `getAllDisplayPhysicalResolution failed code: ${err?.code} err: ${err?.message}`)
    }
    return resolutionObjects;
  }

  /**
   * 判断当前设备是否支持色彩调节
   *
   * @return true: 支持色彩调节  false: 不支持色彩调节
   */
  static async isColorModeSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi: ESObject = await import('@ohos.displayengine.displayengine_napi');
    //   let colorModeAdjustmentSupport: boolean =
    //     displayengineNapi.default.getSupported([DE_FEATURE_COLORMODE])[0] === 1;
    //   LogUtil.info(`${TAG} colorModeAdjustmentSupport ${colorModeAdjustmentSupport}`);
    //   return colorModeAdjustmentSupport;
    // } catch (err) {
    //   LogUtil.error(`${TAG} displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    // }
    return false;
  }

  /**
   * 判断当前设备是否支持色温调节
   *
   * @return true: 支持色温调节  false: 不支持色温调节
   */
  static async isColorTemperatureAdjustmentSupport(): Promise<boolean> {
    // try {
    //   let displayengineNapi = await import('@ohos.displayengine.displayengine_napi');
    //   let colorTemperatureAdjustmentSupport: boolean =
    //     displayengineNapi.default.getSupported([DE_FEATURE_3D_COLOR_TEMPERATURE])[0] === 1;
    //   LogUtil.info(`${TAG} colorTemperatureAdjustmentSupport ${colorTemperatureAdjustmentSupport}`);
    //   return colorTemperatureAdjustmentSupport;
    // } catch (err) {
    //   LogUtil.error(`${TAG} displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    // }
    return false;
  }

  /**
   * 判断当前设备是否支持色彩或色温调节
   *
   * @return true: 支持色彩或色温调节  false: 不支持色彩色温调节
   */
  static async isColorModeOrTemperatureAdjustmentSupport(): Promise<boolean> {
    try {
      let colorModeAdjustmentSupport: boolean = await DisplayUtils.isColorModeSupport();
      let colorTemperatureAdjustmentSupport: boolean = await DisplayUtils.isColorTemperatureAdjustmentSupport();
      return colorTemperatureAdjustmentSupport || colorModeAdjustmentSupport;
    } catch (err) {
      LogUtil.error(`${TAG} displayengine_napi getSupported error: ${err?.code} ${err?.message}`);
    }
    return false;
  }
}