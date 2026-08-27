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

/* instrument ignore file */
import display from '@ohos.display';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG: string = 'AccessibilityImageSizeAdjust : ';
const HALF_OF_NUMBER: number = 2;
const TABLET_SPLIT_LEFT_MAX_WIDTH: number = 480;
const TABLET_SPLIT_LEFT_PERCENT: number = 0.4;
const TABLET_SPLIT_RIGHT_PERCENT: number = 0.6;
const IMAGE_RESOURCE_PERCENT: number = 0.8;
const OOBE_CARD_CONTAINER_WIDTH_MARGIN: number = 32;
const OOBE_CARD_CONTAINER_TABLET_WIDTH_MARGIN: number = 212;
const OOBE_CARD_CONTAINER_SUPER_FOLD_WIDTH_MARGIN: number = 494;
const OOBE_CARD_CONTAINER_PAD_WIDTH_MARGIN: number = 664;
const OOBE_CARD_CONTAINER_HEIGHT_MARGIN: number = 188;

export class AccessibilityImageSizeAdjust {
  public imageResourceRadius: number = this.getImageHeight() * IMAGE_RESOURCE_PERCENT;

  /**
   * 获取短边宽度,计算方式：
   * 屏幕一分为二后获取到较短的一边为短边（分栏场景按照应用占用的宽高计算）
   * 插画资源大小 短边*0.8
   *
   * @returns 返回短边大小（单位vp）
   */
  public getImageHeight(): number {
    let displayClass: display.Display | undefined = undefined;
    try {
      displayClass = display.getDefaultDisplaySync();
      if (display.isFoldable() && display.getFoldDisplayMode() === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL ||
      DeviceUtil.isDevicePad()) {
        let fortyPercentWidth: number = px2vp(displayClass.width * TABLET_SPLIT_LEFT_PERCENT);
        if (fortyPercentWidth > TABLET_SPLIT_LEFT_MAX_WIDTH) {
          let maxValue: number =
            Math.max(px2vp(displayClass.width) - TABLET_SPLIT_LEFT_MAX_WIDTH, px2vp(displayClass.height));
          let minValue: number =
            Math.min(px2vp(displayClass.width) - TABLET_SPLIT_LEFT_MAX_WIDTH, px2vp(displayClass.height));
          return Math.min(maxValue / HALF_OF_NUMBER, minValue);
        } else {
          let maxValue: number = Math.max(displayClass.width * TABLET_SPLIT_RIGHT_PERCENT, displayClass.height);
          let minValue: number = Math.min(displayClass.width * TABLET_SPLIT_RIGHT_PERCENT, displayClass.height);
          return px2vp(Math.min(maxValue / HALF_OF_NUMBER, minValue));
        }
      } else {
        let maxValue: number = Math.max(displayClass.width, displayClass.height);
        let minValue: number = Math.min(displayClass.width, displayClass.height);
        return px2vp(Math.min(maxValue / HALF_OF_NUMBER, minValue));
      }
    } catch (exception) {
      LogUtil.error(`${TAG} getImageHeight Failed to get the default display object. code: ${exception?.code}`);
    }
    return 0;
  }

  public registerDisplayChangeListener(): void {
    try {
      display.on('change', () => {
        LogUtil.info(`${TAG} IntroducePage Display changed`);
        this.imageResourceRadius = this.getImageHeight() * IMAGE_RESOURCE_PERCENT;
        let imageSize = AppStorage.get<number>('AccessibilityImageSize') as number;
        if (this.imageResourceRadius !== imageSize) {
          AppStorage.setOrCreate<number>('AccessibilityImageSize', this.imageResourceRadius);
        }
      });
    } catch (error) {
      LogUtil.error(`${TAG} Failed to register callback. Code: ${(error as BusinessError)?.code}`);
    }
  }

  public unregisterDisplayChangeListener(): void {
    try {
      display.off('change');
    } catch (error) {
      LogUtil.error(`${TAG} IntroducePage unregister displayChange: ${(error as BusinessError)?.message}`);
    }
  }

  public getImageSize(): number {
    let length: number = AppStorage.get<number>('AccessibilityImageSize') as number;
    LogUtil.info(`${TAG} GetImageSize: ${length}`);
    return length;
  }

  /**
   * 判断是不是宽屏状态
   * @returns true 是；false 不是
   */
  static checkIsDevicesExpanded(): boolean {
    return DeviceUtil.isDevicePc() || DeviceUtil.isDevicePad() || DeviceUtil.isFoldExpand() ||
      DeviceUtil.isThreeFoldableGmodel() || !DeviceUtil.isDevicePortrait();
  }
}

export class AccessibilityOobeImageSizeAdjust {
  public tag: string = 'AccessibilityOobeImageSizeAdjust: ';
  public imageResourceRadius: number = this.getImageHeight() * IMAGE_RESOURCE_PERCENT;

  private getCardContainerWidth(): number {
    if (DeviceUtil.isNextSuperFoldProduct()) {
      return OOBE_CARD_CONTAINER_SUPER_FOLD_WIDTH_MARGIN;
    } else if (DeviceUtil.isDevicePad()) {
      return OOBE_CARD_CONTAINER_PAD_WIDTH_MARGIN
    } else {
      return OOBE_CARD_CONTAINER_TABLET_WIDTH_MARGIN
    }
  }

  /**
   * 获取卡片容器短边宽度,计算方式：
   * 屏幕一分为二后获取到较短的一边为短边（分栏场景按照应用占用的宽高计算）
   * 插画资源大小 短边*0.8
   *
   * @returns 返回短边大小（单位vp）
   */
  public getImageHeight(): number {
    let displayClass: display.Display | undefined = undefined;
    try {
      displayClass = display.getDefaultDisplaySync();
      if (this.checkImageExpanded() || DeviceUtil.isDevicePad()) {
        let calWidth: number =
          px2vp(displayClass.width) - this.getCardContainerWidth();
        let calHeight: number =
          px2vp(displayClass.height) - OOBE_CARD_CONTAINER_HEIGHT_MARGIN;
        let maxValue: number = Math.max(calWidth, calHeight);
        let minValue: number = Math.min(calWidth, calHeight);
        return Math.min(maxValue / HALF_OF_NUMBER, minValue);
      } else {
        let calWidth: number = px2vp(displayClass.width) - OOBE_CARD_CONTAINER_WIDTH_MARGIN;
        let calHeight: number = px2vp(displayClass.height) - OOBE_CARD_CONTAINER_HEIGHT_MARGIN;
        let maxValue: number = Math.max(calWidth, calHeight);
        let minValue: number = Math.min(calWidth, calHeight);
        return Math.min(maxValue / HALF_OF_NUMBER, minValue);
      }
    } catch (exception) {
      LogUtil.error(`${this.tag} getImageHeight Failed to get the default display object. code: ${exception?.code}`);
    }
    return 0;
  }

  public registerDisplayChangeListener(): void {
    try {
      display.on('change', () => {
        LogUtil.debug(`${this.tag} IntroducePage Display changed`);
        this.setImageSize();
      });
    } catch (error) {
      LogUtil.error(`${this.tag} Failed to register callback. message: ${(error as BusinessError)?.message}`);
    }
  }

  public unregisterDisplayChangeListener(): void {
    try {
      display.off('change');
    } catch (error) {
      LogUtil.error(`${this.tag} IntroducePage unregister displayChange: ${(error as BusinessError)?.message}`);
    }
  }

  public setImageSize(): void {
    this.imageResourceRadius = this.getImageHeight() * IMAGE_RESOURCE_PERCENT;
    let imageSize: number = AppStorage.get<number>('AccessibilityOobeImageSize') as number;
    if (this.imageResourceRadius !== imageSize) {
      AppStorage.setOrCreate<number>('AccessibilityOobeImageSize', this.imageResourceRadius);
      LogUtil.debug(`${this.tag} setImageSize ${this.imageResourceRadius}`);
    }
  }

  public getImageSize(): number {
    let length: number = AppStorage.get<number>('AccessibilityOobeImageSize') as number;
    LogUtil.debug(`${this.tag} GetImageSize: ${length}`);
    return length;
  }

  /**
   * 获取卡片容器是否为宽屏状态
   * @returns true 是；false 不是
   */
  public checkImageExpanded(): boolean {
    return display.isFoldable() && display.getFoldDisplayMode() === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL;
  }
}