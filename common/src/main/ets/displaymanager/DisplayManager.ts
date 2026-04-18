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
import type common from '@ohos.app.ability.common';
import { LogUtil } from '../utils/LogUtil';
import type { Context } from '@ohos.abilityAccessCtrl';
import Settings from '@ohos.settings';
import { SettingsDataUtils } from '../utils/SettingsDataUtils';

const TAG = 'SettingsDisplayManager';

const ROTATION_90 = 1;

const ROTATION_270 = 3;

const NOTCH_FIX_WIDTH = 12;

export const EVENT_ID_FOLD_STATUS_CHANGE: number = 5000001;

export const EVENT_KEY_FOLD_STATUS_CHANGE: string = 'event_key_fold_status_change';

const DEFAULT_DPI_VALUE: string = 'system_default_dpi_value';

export type OffEvent = () => void;
/**
 * 屏幕常量
 */
export class DisplayConstants {
  /**
   * 默认display id
   */
  public static readonly DEFAULT_DISPLAY: number = 0;

  /**
   * 无效display id
   */
  public static readonly INVALID_DISPLAY: number = -1;
}

/**
 * 屏幕显示信息
 */
export class DisplayState {
  public rotation: number;
  public cutoutInfo: CutoutInfo;

  /**
   * 构造
   */
  constructor() {
    this.cutoutInfo = new CutoutInfo(0, 0, 0, 0);
  }

  /**
   * 对比方法，校验是否一致
   *
   * @param other DisplayState
   */
  public equals(other: DisplayState): boolean {
    if (this.rotation !== other.rotation) {
      return false;
    }
    if (!this.cutoutInfo.equals(other.cutoutInfo)) {
      return false;
    }
    return true;
  }
}

/**
 * 挖孔信息
 */
export class CutoutInfo {
  public left: number;
  public top: number;
  public right: number;
  public bottom: number;

  /**
   * 构造
   */
  constructor(left: number, top: number, right: number, bottom: number) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;
  }

  /**
   * 对比方法，校验是否一致
   *
   * @param other 另一个CutoutInfo
   */
  public equals(other: CutoutInfo): boolean {
    if (this.left !== other.left || this.top !== other.top ||
    this.right !== other.right || this.bottom !== other.bottom) {
      return false;
    }
    return true;
  }
}

/**
 * 屏幕显示信息回调
 */
export interface Callback {
  (data: DisplayState): void;
}

/**
 * display屏幕管理
 *
 * @since 2023-2-27
 */
export class DisplayManager {
  /**
   * 当前运行屏幕id
   */
  private displayId?: number;

  /**
   * 当前运行屏幕实例
   */
  private display?: Display.Display;

  /**
   * 折叠屏展开状态
   */
  private foldStatus?: number;

  /**
   * 当前运行屏幕显示信息实例
   */
  private displayState?: DisplayState;

  /**
   * 监听集合
   */
  private listener?: Set<Callback>;

  /**
   * 默认DPI
   */
  private defaultDensityDpi: number = -1;

  /**
   * 构造
   */
  constructor() {
    this.listener = new Set();
    this.displayState = new DisplayState();
  }

  /**
   * 获取显示管理类对象
   *
   * @return 显示管理类对象单一实例
   */
  public static getInstance(): DisplayManager {
    if (!Boolean(AppStorage.get('DisplayManager')).valueOf()) {
      AppStorage.setOrCreate<DisplayManager>('DisplayManager', new DisplayManager());
    }
    return AppStorage.get('DisplayManager') as DisplayManager;
  }

  /**
   * display初始化
   */
  public init(context: common.AbilityStageContext): void {
    if (!context) {
      return;
    }
    // 匹配当前display id
    this.displayId = context.config?.displayId;
    if (this.displayId === DisplayConstants.INVALID_DISPLAY) {
      this.displayId = DisplayConstants.DEFAULT_DISPLAY;
    }
    LogUtil.info(TAG + `init current display id: ${this.displayId}`);
    // 初始display
    this.refreshCurrentDisplay().then(() => this.checkDisplayState());
    // 监听display变化
    Display.on('change', (id) => {
      if (id === this.displayId) {
        LogUtil.info(TAG + `display changed id: ${id}`);
        this.refreshCurrentDisplay().then(() => this.checkDisplayState());
      }
    });
  }

  /**
   * 获取DPI相对默认值的缩放比例
   *
   * @returns 缩放比例
   */
  public getDpiScale(): number {
    if (this.defaultDensityDpi === -1) {
      this.getDefaultDpi();
    }
    if (this.defaultDensityDpi !== -1 && this.display?.densityDPI && this.display.densityDPI !== 0) {
      let scale: number = this.defaultDensityDpi / this.display?.densityDPI;
      return Number.isNaN(scale) ? 1 : scale;
    }
    return 1;
  }

  getDefaultDpi(): void {
    if (AppStorage.get<Context>('pageContext') === undefined) {
      LogUtil.error(`${TAG} getDefaultDpi context null`);
      return;
    }
    const dpiValue: string = SettingsDataUtils.getSettingsData(DEFAULT_DPI_VALUE, '');
    LogUtil.info(`${TAG} dpiValue: ${dpiValue}`);
    if (dpiValue === '') {
      let currentDpi: string = this.display?.densityDPI.toString() ?? '';
      SettingsDataUtils.setSettingsData( DEFAULT_DPI_VALUE, currentDpi);
      this.defaultDensityDpi = this.display?.densityDPI as number;
    } else {
      this.defaultDensityDpi = Number.parseInt(dpiValue);
    }
    LogUtil.info(`${TAG} this.defaultDensityDpi: ${this.defaultDensityDpi}`);
  }

  /**
   * 检查屏幕信息是否改变，如果改变则需要通知监听者
   */
  private checkDisplayState(): void {
    this.display.getCutoutInfo().then(data => {
      let displayState = new DisplayState();
      displayState.rotation = this.display.rotation;
      displayState.cutoutInfo = this.refreshCutoutInfo(this.display, data.boundingRects);
      if (this.displayState.equals(displayState)) {
        LogUtil.info(TAG + ' displayState is not change!');
        return;
      }
      this.displayState = displayState;
      LogUtil.info(TAG + ' checkDisplayState');
      this.listener?.forEach(callback => callback(this.displayState));
    });
  }

  /**
   * 注册屏幕信息改变监听
   *
   * @param callback 改变后的回调
   */
  public on(callback: Callback): OffEvent {
    if (!callback) {
      return () => {};
    }
    this.listener.add(callback);
    LogUtil.info(TAG + ' on callback, size: ' + this.listener?.size);
    if (this.displayState) {
      callback(this.displayState);
    }
    return () => this.off(callback);
  }

  /**
   * 反注册屏幕信息改变监听
   *
   * @param callback 改变后的回调
   */
  public off(callback: Callback): void {
    if (!callback) {
      return;
    }
    let result = this.listener?.delete(callback);
    LogUtil.info(TAG + ' off callback, size: ' + this.listener?.size);
    if (!result) {
      LogUtil.error(TAG + 'off callback failed');
    }
  }

  /**
   * 直接获取缓存display，不用异步等待
   *
   * @return display(Nullable)
   */
  public getCacheDisplay(): Display.Display {
    return this.display as Display.Display;
  }

  /**
   * 获取当前display
   *
   * @return 当前display
   */
  public async getCurrentDisplay(): Promise<Display.Display> {
    if (this.display) {
      return new Promise(resolve => resolve(this.display));
    }
    await this.refreshCurrentDisplay();
    return new Promise(resolve => resolve(this.display));
  }

  /**
   * 设置折叠屏状态
   *
   * @param status 折叠屏状态
   */
  public setFoldStatus(status: number): void {
    this.foldStatus = status;
  }

  /**
   * 获取折叠屏状态
   *
   * @returns 折叠屏状态
   */
  public getFoldStatus(): number {
    return this.foldStatus;
  }

  /**
   * 刷新当前display
   */
  private async refreshCurrentDisplay(): Promise<void> {
    let allDisplays = await Display.getAllDisplays();
    allDisplays?.find((display) => {
      if (display && this.displayId === display?.id) {
        LogUtil.info(TAG + ' refreshCurrentDisplay display.');
        this.display = display;
      }
    });
  }

  /**
   * 刷新挖孔信息
   */
  private refreshCutoutInfo(display: Display.Display, cutoutRects: Array<Display.Rect>): CutoutInfo {
    let cutoutInfo = new CutoutInfo(0, 0, 0, 0);
    if (!display || !cutoutRects || cutoutRects.length === 0) {
      return cutoutInfo;
    }
    let rect = cutoutRects[0];
    switch (display.rotation) {
      case ROTATION_90:
        cutoutInfo.right = display.width - rect?.left + NOTCH_FIX_WIDTH; // 挖孔参数不正确，+12校准
        break;
      case ROTATION_270:
        cutoutInfo.left = rect?.left + rect?.width + NOTCH_FIX_WIDTH; // 挖孔参数不正确，+12校准
        break;
      default:
        return cutoutInfo;
    }
    return cutoutInfo;
  }
}