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

import screen from '@ohos.screen';
import display from '@ohos.display';
import window from '@ohos.window';
import Settings from '@ohos.settings';
import Display from '@ohos.display';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '../utils/LogUtil';
import { displayDataManager } from '../data/DisplayDataManager';
import { PreferencesUtil } from './PreferencesUtil';
import { SettingsDataUtils } from './SettingsDataUtils';
import { DisplayConstant } from '../constant/DisplayConstant';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { DeviceUtil } from './BaseUtils';

const TAG = 'DpiManager :';

/**
 * dpi和档位描述的集合
 */
interface DensitySet {
  density: number;
  description: Resource;
}
/**
 * OpenHarmony支持的最大dpi数值
 */
const MAX_LCD_DENSITY: number = 640;
/**
 * OpenHarmony支持的最小dpi数值
 */
const MIN_LCD_DENSITY: number = 80;
/**
 * 最小允许的屏幕维度
 */
const MIN_DIMENSION_DP: number = 320;
/**
 * 最大支持的档位
 */
const MAX_SCALE: number = 1.5;
/**
 * 最小支持的档位
 */
const MIN_SCALE: number = 0.85;
/**
 * 档位的最小颗粒
 */
const MIN_SCALE_INTERVAL: number = 0.09;
/**
 * 折叠屏档位的最小颗粒
 */
const ALT_MIN_SCALE_INTERVAL: number = 0.08;

/**
 * 默认DPI数值键值
 */
const DEFAULT_DPI_VALUE: string = 'system_default_dpi_value';

/**
 * xml读取的默认DPI数值
 */
const DEFAULT_XML_DPI_VALUE: string = 'default_display_dpi';

/**
 * 外屏默认DPI数值键值
 */
const EXTEND_DPI_VALUE: string = 'extend_dpi_value';

/**
 * 外屏用户自定义DPI数值键值
 */
const USER_SET_DPI_VALUE_EXTEND: string = 'user_set_dpi_value_extend';

/**
 * Settings data中的默认DPI数值
 */
const DPI_VALUE_NULL: string = '';

/**
 *当前设备折叠态宽度
 */
const FOLD_WIDTH_VALUE: number = 1080;

const SETTINGS_DISPLAY_SCREEN_WIDTH: string = 'settings.display.screen.width';
const DOMAIN_NAME: string = Settings.domainName.USER_PROPERTY;

/**
 * DPI管理工具类
 *
 * @since 2023-08-10
 */
class DpiManager {
  /**
   * 默认DPI数值
   */
  public defaultDensityDpi: number = -1;
  /**
   * 最大DPI数值
   */
  public maxDensityDpi: number = -1;
  /**
   * 最小DPI数值
   */
  public minDensityDpi: number = 1001;
  /**
   * 当前DPI数值
   */
  public currentDensityDpi: number = -1;
  /**
   * 当前设备支持大档位个数
   */
  public numLarger: number = 0;
  /**
   * 当前设备支持小档位个数
   */
  public numSmaller: number = 0;
  /**
   * 当前设备的档位集合
   */
  public densityList: DensitySet[] = [];
  /**
   * Screen实例
   */
  public screenClass: screen.Screen | null = null;
  /**
   * Display实例
   */
  public displayClass: display.Display | null = null;
  /**
   * Windows实例
   */
  public windowClass: window.Window | null = null;
  /**
   * Windows宽度
   */
  public windowWidth: number = 0;
  /**
   * Windows高度
   */
  public windowHeight: number = 0;
  /**
   * px转化成vp的倍数
   */
  public densityMedium: number = 160;
  /**
   * 导航栏默认宽度
   */
  public navBarWidth: number = 271;

  /**
   * DPI管理获取所需的screen和display接口实例
   *
   * @since 2023-08-30
   */
  async getClassInstance(): Promise<void> {
    /* instrument ignore next */
    try {
      this.displayClass = display.getDefaultDisplaySync();
      await this.getScreenClassInstance();
      // 当前页面选中设备
      if (DeviceUtil.isDevicePc()) {
        this.displayClass = Display.getDisplayByIdSync(this.screenClass?.id ?? 0);
      }
    } catch (err) {
      LogUtil.error(`${TAG} get all default display error: ${err?.code}`);
    }
  }

  private async getDisplayClass(currentDeviceId: number): Promise<void> {
    try {
      let allDisplay: display.Display[] = await display.getAllDisplays();
      // 根据当前选中设备获取displayClass
      allDisplay.forEach((d) => {
        /* instrument ignore if*/
        if (d.id === currentDeviceId) {
          this.displayClass = d;
        }
      });
    } catch (err) {
      LogUtil.error(`${TAG} get all display error: ${err.code}`);
      this.displayClass = display.getDefaultDisplaySync();
    }
  }

 private async getScreenClassInstance(): Promise<void> {
    let currentDeviceId: number =
      Number(SettingsDataUtils.getSettingsData('display_current_device_id', '0', DOMAIN_NAME));
    try {
      let data: screen.Screen[] = await screen.getAllScreens();
      let maxWidth: number = 0;
      if (data !== undefined && data !== null && data.length !== 0) {
        for (let index = 0; index < data.length; index++) {
          // 这里要防止 rsId 为-1的异常值的情况
          if (currentDeviceId === (data[index].rsId >= 0 ? data[index].rsId : data[index].id)) {
            LogUtil.info(`${TAG} screen index: ${index}`);
            this.screenClass = data[index];
            LogUtil.showInfo(TAG, `supportedModeInfo length: ${this.screenClass.supportedModeInfo.length}`);
            if (this.screenClass.supportedModeInfo.length > 0) {
              this.screenClass.supportedModeInfo.forEach((value: screen.ScreenModeInfo, index: number) => {
                if (maxWidth < value.width) {
                  maxWidth = value.width;
                }
              });
            }
            break;
          }
        }
      }
      LogUtil.info(`${TAG} screen. maxWidth : ${maxWidth}`);
      PreferencesUtil.put(SETTINGS_DISPLAY_SCREEN_WIDTH, maxWidth);
    } catch (err) {
      LogUtil.error(`${TAG} get screen class error. Cause:code: ${err.code} message: ${err.message}`);
    }
  }

  /**
   * DPI管理获取所需的window接口实例
   *
   * @since 2023-09-10
   */
  async getWindowClassInstance(): Promise<void> {
    try {
      this.windowClass = await window.getLastWindow(getContext(this));
      this.windowWidth = this.windowClass.getWindowProperties().windowRect.width;
      this.windowHeight = this.windowClass.getWindowProperties().windowRect.height;
    } catch (err) {
      LogUtil.error(`${TAG} Failed to obtain the top window. Cause: code: ${err.code} message: ${err.message}`);
    }
  }

  /**
   * 设置dpi，并获取滑块对应的显示大小类型（小、默认、大、较大、最大）
   *
   * @since 2023-08-30
   */
  setDpiName(index: number): Resource {
    try {
      AppStorage.setOrCreate('dpiChange', index);
      this.screenClass?.setDensityDpi(this.densityList[index].density)?.then((data) => {
        LogUtil.info(`${TAG} Succeeded in setting the pixel density of the screen.`);
        /* instrument ignore else*/
        if (this.isNativeDisplay()) {
          SettingsDataUtils.setSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE,
            this.densityList[index].density.toString());
        } else {
          // 非本机设备设置dpi
          SettingsDataUtils.setSettingsData(USER_SET_DPI_VALUE_EXTEND, this.densityList[index].density.toString());
        }
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} Failed to set the pixel density of the screen. Code: code: ${err.code} message: ${err.message}`);
      });
    } catch (err) {
      LogUtil.error(`${TAG}  Failed to set the pixel density of the screen. code: ${err.code} message: ${err.message}`);
    }
    return this.densityList[index].description;
  }

  /**
   * 设置dpi，并获取滑块对应的显示大小类型（小、默认、大、较大、最大）
   *
   * @since 2023-08-30
   */
  getDpiValue(index: number): number {
    return this.densityList[index]?.density;
  }

  /**
   * 获取DPI，并获取滑块对应的显示大小类型（小、默认、大、较大、最大）
   *
   * @since 2024-01-16
   */
  getDpiName(index: number): Resource {
    return this.densityList[index]?.description;
  }

  /**
   * 根据DPI获取档位（小、默认、大、较大、最大）
   *
   * @param dpi dpi值
   * @returns 档位
   */
  getIndexByDpi(dpi: number): number {
    for (let i = 0; i < this.densityList.length; i++) {
      if (this.densityList[i].density === dpi) {
        return i;
      }
    }
    return 1;
  }

  /**
   * 从settings data中获取默认dpi（若setting data不存在，则将当前dpi设置为默认dpi）
   *
   * @since 2023-08-30
   */
  setDefaultDpi(dpiValue: string): void {
    let  defaultDpi = PreferencesUtil.getSync(DEFAULT_XML_DPI_VALUE,'') as string
    if (!defaultDpi) {
      LogUtil.showInfo(TAG, `getDefaultDpi: ${defaultDpi}, displayClass dpi: ${this.displayClass?.densityDPI}`);
      defaultDpi =  this.displayClass?.densityDPI.toString()??""
      PreferencesUtil.putSync(DEFAULT_XML_DPI_VALUE, this.displayClass?.densityDPI.toString()??'')
    }
    LogUtil.info(`${TAG} setdpiValue: ${dpiValue} setDefaultDpi`+defaultDpi);
    /* instrument ignore if*/
    if (dpiValue === DPI_VALUE_NULL) {
      if (this.isNativeDisplay()) {
        LogUtil.showInfo(TAG, `defaultDpi1: ${defaultDpi}, displayClass dpi: ${this.displayClass?.densityDPI}`);
        SettingsDataUtils.setSettingsData(DEFAULT_DPI_VALUE, defaultDpi);
        displayDataManager.updateDefaultDPI();
        this.defaultDensityDpi = Number(defaultDpi);
      } else {
        SettingsDataUtils.setSettingsDataAsync(EXTEND_DPI_VALUE, this.displayClass?.densityDPI.toString() as string);
        displayDataManager.updateExtendDPI();
        this.defaultDensityDpi = this.displayClass?.densityDPI as number;
      }
    } else {
      this.defaultDensityDpi = Number.parseInt(dpiValue);
    }

    if (this.isNativeDisplay()) {
      // 默认dpi统一从DEFAULT_XML_DPI_VALUE获取
      if (defaultDpi !== dpiValue) {
        LogUtil.showWarn(TAG, `defaultDpi2: ${defaultDpi}, dpiValue: ${dpiValue}`);
        this.defaultDensityDpi = Number(defaultDpi);
        displayDataManager.updateDefaultDPI();
        SettingsDataUtils.setSettingsData(DEFAULT_DPI_VALUE, defaultDpi);
      }
    }

    LogUtil.info(`${TAG} this.defaultDensityDpi: ${this.defaultDensityDpi}`);
    this.maxDensityDpi = this.defaultDensityDpi;
    this.currentDensityDpi = this.displayClass?.densityDPI as number;
  }

  /**
   * 双向截断约束，所有数值不得低于low，不得高于high
   *
   * @since 2023-08-30
   */
  private constrain(amount: number, low: number, high: number): number {
    return amount < low ? low : (amount > high ? high : amount);
  }

  /**
   * 将dpi和档位描述打包成为DensitySet
   *
   * @since 2023-08-30
   */
  private getDensitySet(density: number, str: Resource): DensitySet {
    let set: DensitySet = {
      density: density,
      description: str
    };
    return set;
  }

  /**
   * 计算最高档位和最低档位数量，并将对应档位和描述进行计算；
   * 将当前界面所属dpi找到对应档位，并返回当前档位
   *
   * @since 2023-08-30
   */
  setNumberAndScale(summariesLarger: Array<Resource>, summariesSmaller:
    Array<Resource>, summariesDefault: Resource): number {
    let defaultDensity: number = this.defaultDensityDpi;
    let currentDensity: number = this.displayClass?.densityDPI as number;
    if (DeviceUtil.isDevicePc()) {
      currentDensity = Number(SettingsDataUtils.getSettingsData(DisplayConstant.SETTINGS_DATA_USER_SET_DPI_VALUE,
        `${this.displayClass?.densityDPI}`));
    }
    LogUtil.info(`${TAG} setNumberAndScale: defaultDensity: ${defaultDensity}, currentDensity: ${currentDensity}`);
    let currentWidth: string = String(PreferencesUtil.getSync(SETTINGS_DISPLAY_SCREEN_WIDTH,
      Math.min(this.displayClass?.height as number, this.displayClass?.width as number)));
    let minDimensionPx: number = Display.isFoldable() ? FOLD_WIDTH_VALUE : Number(currentWidth);
    LogUtil.info(`${TAG} setNumberAndScale: currentWidth: ${currentWidth}, minDimensionPx: ${minDimensionPx}`);
    let maxDensity: number = this.densityMedium * minDimensionPx / MIN_DIMENSION_DP;
    let maxScale: number = Math.min(MAX_SCALE, maxDensity / defaultDensity);
    let minScale: number = MIN_SCALE;
    let minInterval: number = Display.isFoldable() ? ALT_MIN_SCALE_INTERVAL : MIN_SCALE_INTERVAL;
    LogUtil.info(`${TAG} setNumberAndScale: ${maxDensity}, ${maxScale}, ${minScale}, ${minInterval}`);
    this.numLarger = this.constrain(Math.floor((maxScale - 1) / minInterval), 0, summariesLarger.length);
    this.numSmaller = this.constrain(Math.floor((1 - minScale) / MIN_SCALE_INTERVAL), 0, summariesSmaller.length);
    this.densityList = [];
    LogUtil.info(`${TAG} setNumberAndScale: numLarger:${this.numLarger}, numSmaller:${this.numSmaller}`);
    let inSetValue: number = 0;

    let currentDensityIndex = this.pushDensity(
      minScale, maxScale, defaultDensity, currentDensity,
      summariesLarger, summariesSmaller, summariesDefault
    );
    LogUtil.info(`${TAG} this.currentDensityIndex: ${currentDensityIndex}`);
    if (currentDensityIndex >= 0) {
      inSetValue = currentDensityIndex;
    } else {
      inSetValue = 1;
    }
    LogUtil.info(`${TAG} this.inSetValue: ${inSetValue}`);
    LogUtil.info(`${TAG} this.numLarger: ${this.numLarger}`);
    return inSetValue;
  }

  private pushDensity(minScale: number, maxScale: number, defaultDensity: number, currentDensity: number,
    summariesLarger: Array<Resource>, summariesSmaller: Array<Resource>, summariesDefault: Resource) {
    let curIndex: number = 0;
    let currentDensityIndex: number = -1;
    let interval: number = 0;
    let i: number = 0;
    let density: number = 0;
    if (this.numSmaller > 0) {
      interval = (1 - minScale) / this.numSmaller;
      for (i = this.numSmaller - 1; i >= 0; i--) {
        density = Math.floor(defaultDensity * (1 - (i + 1) * interval)) & ~1;
        if (density < MIN_LCD_DENSITY) {
          density = MIN_LCD_DENSITY;
        }
        if (density < this.minDensityDpi) {
          this.minDensityDpi = density;
        }
        if (currentDensity === density) {
          currentDensityIndex = curIndex;
        }
        this.densityList.push(this.getDensitySet(density, summariesSmaller[i]));
        LogUtil.info(`${TAG} setNumberAndScale: densityList.push density:${density}`);
        curIndex++;
      }
    }

    if (currentDensity === defaultDensity) {
      currentDensityIndex = curIndex;
    }
    this.densityList.push(this.getDensitySet(defaultDensity, summariesDefault));
    LogUtil.info(`${TAG} setNumberAndScale: densityList.push defaultDensity:${defaultDensity}`);
    curIndex++;

    if (this.numLarger > 0) {
      interval = (maxScale - 1) / this.numLarger;
      for (i = 0; i < this.numLarger; i++) {
        density = Math.floor(defaultDensity * (1 + (i + 1) * interval)) & ~1;
        if (density > MAX_LCD_DENSITY) {
          density = MAX_LCD_DENSITY;
        }
        if (density > this.maxDensityDpi) {
          this.maxDensityDpi = density;
        }
        if (currentDensity === density) {
          currentDensityIndex = curIndex;
        }
        this.densityList.push(this.getDensitySet(density, summariesLarger[i]));
        LogUtil.info(`${TAG} setNumberAndScale: densityList.push density:${density}`);
        curIndex++;
      }
    }
    return currentDensityIndex;
  }

  private isNativeDisplay() {
    // 这里要防止 rsId 为-1的异常值的情况
    return (this.screenClass?.rsId && this.screenClass?.rsId >= 0 ? this.screenClass?.rsId : this.displayClass?.id) === 0;
  }
}

export default new DpiManager();