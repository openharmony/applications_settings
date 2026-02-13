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

import mediaquery from '@ohos.mediaquery';
import { DeviceUtil } from '../utils/BaseUtils';
import { LogUtil } from '../utils/LogUtil';
import { UIExtensionSessionUtils } from '../utils/UIExtensionSessionUtils';

const TAG: string = 'ColumnSystemManager : ';

const COLUMN_GUTTER_SM = 16;

const COLUMN_GUTTER_MD = 16;

const COLUMN_GUTTER_LG = 24;

const COLUMN_MARGIN_SM = 16;

const COLUMN_MARGIN_MD = 16;

const COLUMN_MARGIN_LG = 24;

const DOUBLE = 2;

const DEFAULT_BTN_WIDTH = 188;

/**
 * OOBE栅格系统管理类
 */
export class ColumnSystemManager {
  private static instance: ColumnSystemManager;

  private hasRegister: boolean = false;

  private lgListener?: mediaquery.MediaQueryListener;

  private mdListener?: mediaquery.MediaQueryListener;

  private smListener?: mediaquery.MediaQueryListener;

  private columnCount: number = 0;

  private singleColumnWidth: number = 0;

  private columnGutter: number = vp2px(COLUMN_GUTTER_SM);

  private columnMargin: number = vp2px(COLUMN_MARGIN_MD);

  constructor() {
    this.initListeners();
  }

  /**
   * 获取实例
   *
   * @returns 栅格管理类
   */
  static getInstance(): ColumnSystemManager {
    if (!ColumnSystemManager.instance) {
      ColumnSystemManager.instance = new ColumnSystemManager();
    }
    return ColumnSystemManager.instance;
  }

  /**
   * 注册媒体监听
   */
  registerMediaQuery(): void {
    if (this.hasRegister) {
      return;
    }
    this.lgListener?.on('change', this.onColumnLg);
    this.mdListener?.on('change', this.onColumnMd);
    this.smListener?.on('change', this.onColumnSm);
    this.hasRegister = true;
  }

  /**
   * 反注册媒体监听
   */
  unregisterMediaQuery(): void {
    if (this.lgListener) {
      this.lgListener.off('change');
    }
    if (this.mdListener) {
      this.mdListener.off('change');
    }
    if (this.smListener) {
      this.smListener.off('change');
    }
    this.hasRegister = false;
  }

  /**
   * 获取当前窗口栅格总数
   *
   * @returns 栅格总数
   */
  getColumnCount(): number {
    return this.columnCount;
  }

  /**
   * 获取单个栅格宽度，单位px
   *
   * @returns 单个栅格宽度
   */
  getSingleColumnWidth(): number {
    return this.singleColumnWidth;
  }

  /**
   * 获取单个栅格宽度，单位vp
   *
   * @returns 单个栅格宽度
   */
  getSingleColumnWidthVp(): number {
    return px2vp(this.singleColumnWidth);
  }

  /**
   * 获取栅格屏幕左右间距，单位px
   *
   * @returns 屏幕左右间距
   */
  getColumnMargin(): number {
    return this.columnMargin;
  }

  /**
   * 获取栅格屏幕左右间距，单位vp
   *
   * @returns 屏幕左右间距
   */
  getColumnMarginVp(): number {
    return px2vp(this.columnMargin);
  }

  /**
   * 获取栅格与栅格之间的间距，单位px
   *
   * @returns 栅格间距
   */
  getColumnGutter(): number {
    return this.columnGutter;
  }

  /**
   * 获取栅格与栅格之间的间距，单位vp
   *
   * @returns 栅格间距
   */
  getColumnGutterVp(): number {
    return px2vp(this.columnGutter);
  }

  /**
   * 获取指定栅格数量的宽度，包含栅格间距，即2个栅格包含1个gutter,单位px
   *
   * @param wantCount 指定栅格数量
   * @param extraGutterCount 额外gutter数量，即在最外边添加多少个gutter
   * @returns 指定栅格数量的宽度
   */
  getCustomWidth(wantCount: number, extraGutterCount: number = 0): number {
    if (wantCount <= 0) {
      return 0;
    }
    return wantCount * this.singleColumnWidth + (wantCount - 1 + extraGutterCount) * this.columnGutter;
  }

  /**
   * 获取指定栅格数量的宽度，包含栅格间距，即2个栅格包含1个gutter,单位vp
   *
   * @param wantCount 指定栅格数量
   * @param extraGutterCount 额外gutter数量，即在最外边添加多少个gutter
   * @returns 指定栅格数量的宽度
   */
  getCustomWidthVp(wantCount: number, extraGutterCount: number = 0): number {
    return px2vp(this.getCustomWidth(wantCount, extraGutterCount));
  }

  private initListeners(): void {
    this.lgListener = mediaquery.matchMediaSync(`(${ColumnDevice.LG}vp<width)`);
    this.mdListener = mediaquery.matchMediaSync(`(${ColumnDevice.MD}vp<=width<=${ColumnDevice.LG}vp)`);
    this.smListener = mediaquery.matchMediaSync(`(${ColumnDevice.SM}vp<=width<${ColumnDevice.MD}vp)`);
  }

  private onColumnLg = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.onColumnChangeInner(ColumnCount.LG_COLUMN_COUNT);
    }
  };

  private onColumnMd = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.onColumnChangeInner(ColumnCount.MD_COLUMN_COUNT);
    }
  };

  private onColumnSm = (result: mediaquery.MediaQueryResult) => {
    if (result.matches) {
      this.onColumnChangeInner(ColumnCount.SM_COLUMN_COUNT);
    }
  };

  private async onColumnChangeInner(count: number): Promise<void> {
    this.columnCount = count;
    this.updateMarginAndGutter();
    this.calcColumnWidth();
    AppStorage.setOrCreate('columnCount', count);
  }

  /* instrument ignore next */
  private updateButtonWidth(): void {
    let footBtnWidth: number = DEFAULT_BTN_WIDTH;
    if (this.columnCount === ColumnCount.SM_COLUMN_COUNT) {
      footBtnWidth = ColumnSystemManager.getInstance().getCustomWidthVp(2, 2);
    } else if (DeviceUtil.isDevicePc()) {
      footBtnWidth = ColumnSystemManager.getInstance().getCustomWidthVp(2, 0);
    } else {
      footBtnWidth = ColumnSystemManager.getInstance().getCustomWidthVp(3, 0);
    }
    LogUtil.showInfo(TAG, `updateButtonWidth: ${footBtnWidth}`);
    AppStorage.setOrCreate('oobeFootBtnWidth', footBtnWidth);
  }

  /**
   * 自动获取窗口大小并计算单个栅格宽度
   *
   * @returns 空Promise对象
   */
  async calcColumnWidth(): Promise<void> {
    let windowRect = await UIExtensionSessionUtils.getWindowRect();
    if (!windowRect) {
      LogUtil.showInfo(TAG, `get windowRect failed: calcColumnWidth oobeFootBtnWidth ${DEFAULT_BTN_WIDTH}`);
      AppStorage.setOrCreate('oobeFootBtnWidth', DEFAULT_BTN_WIDTH);
      return;
    }
    let windowWidth = windowRect.width;
    this.singleColumnWidth = (windowWidth - this.columnMargin * DOUBLE - (this.columnCount - 1) * this.columnGutter) /
      this.columnCount;
    this.updateButtonWidth();
  }

  /* instrument ignore next */
  private updateMarginAndGutter(): void {
    if (this.columnCount === ColumnCount.SM_COLUMN_COUNT) {
      this.columnMargin = vp2px(COLUMN_MARGIN_SM);
      this.columnGutter = vp2px(COLUMN_GUTTER_SM);
    } else if (this.columnCount === ColumnCount.MD_COLUMN_COUNT) {
      this.columnMargin = vp2px(COLUMN_MARGIN_MD);
      this.columnGutter = vp2px(COLUMN_GUTTER_MD);
    } else {
      this.columnMargin = vp2px(COLUMN_MARGIN_LG);
      this.columnGutter = vp2px(COLUMN_GUTTER_LG);
    }
  }

  /**
   * 通过屏幕宽度获取当前的栅格数量
   *
   * @param currentWidthVp 当前屏幕宽度
   * @returns 当前栅格数量
   */
  static getCurrentColumnCountByWidth(currentWidthVp: number): number {
    let currentColumnCount = ColumnCount.LG_COLUMN_COUNT as number;
    if (currentWidthVp >= ColumnDevice.MD && currentWidthVp <= ColumnDevice.LG) {
      currentColumnCount = ColumnCount.MD_COLUMN_COUNT;
    } else if (currentWidthVp < ColumnDevice.MD) {
      currentColumnCount = ColumnCount.SM_COLUMN_COUNT;
    } else {
      currentColumnCount = ColumnCount.LG_COLUMN_COUNT;
    }
    return currentColumnCount;
  }

  /**
   * 通过当前栅格数量获取栅格间隙Gutter
   *
   * @param currentColumnCount 当前栅格数量
   * @returns 当前栅格间隙
   */
  static getColumnGutterVpByColumnCount(currentColumnCount: number) {
    if (currentColumnCount === ColumnCount.SM_COLUMN_COUNT) {
      return COLUMN_GUTTER_SM;
    } else if (currentColumnCount === ColumnCount.MD_COLUMN_COUNT) {
      return COLUMN_GUTTER_MD;
    } else {
      return COLUMN_GUTTER_LG;
    }
  }

  /**
   * 通过当前栅格数量获取外边距Margin
   *
   * @param currentColumnCount 当前栅格数量
   * @returns 当前栅格外边距
   */
  static getColumnMarginVpByColumnCount(currentColumnCount: number) {
    if (currentColumnCount === ColumnCount.SM_COLUMN_COUNT) {
      return COLUMN_MARGIN_SM;
    } else if (currentColumnCount === ColumnCount.MD_COLUMN_COUNT) {
      return COLUMN_MARGIN_MD;
    } else {
      return COLUMN_MARGIN_LG;
    }
  }

  /**
   * 根据传入的窗口大小计算单个栅格宽度
   *
   * @param windowWidth 窗口大小,px
   */
  updateColumnWidth(windowWidth: number): void {
    if (windowWidth <= 0) {
      return;
    }
    this.singleColumnWidth = (windowWidth - this.columnMargin * DOUBLE - (this.columnCount - 1) * this.columnGutter) /
    this.columnCount;
  }
}

/**
 * 栅格变化监听接口
 */
export interface ColumnChangeListener {
  /**
   * 栅格变化
   *
   * @param type 栅格设备类型
   * @param count 栅格总数
   */
  onColumnChange(type: ColumnDevice, count: number): void;
}

/**
 * 栅格设备枚举类,值为断点
 */
export enum ColumnDevice {
  SM = 0,
  /**
   * 低于600vp,4栅格;高于600vp,8栅格
   */
  MD = 600,
  /**
   * 高于1080vp,12栅格
   */
  LG = 1080,
}

/**
 * 栅格数量枚举,值为具体栅格数量
 */
export enum ColumnCount {
  /**
   * 手机竖屏，4栅格
   */
  SM_COLUMN_COUNT = 4,
  /**
   * 手机横屏、折叠屏横/竖屏、Pad竖屏，8栅格
   */
  MD_COLUMN_COUNT = 8,
  /**
   * PAD横屏、智慧屏，12栅格
   */
  LG_COLUMN_COUNT = 12
}