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

import lottie, { AnimationItem } from '@ohos/lottie';
import { SwiperDataMgr } from '../model/SwiperDataMgr';
import { SwiperItem } from '../model/SwiperItem';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
/* instrument ignore file */
const TAG = 'SwiperViewData';

/**
 * 当前轮播索引
 */
export enum CurrentState {
  CLICK_BACK = 0,
  GESTURE_BACK = 1,
  SWIPE_UP_DESKTOP = 2,
  SWIPE_UP_RECENT = 3,
  NOT_INITIAL = -1
}

@Observed
export class SwiperViewData {
  public mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  public canvasRenderingContextList: CanvasRenderingContext2D[] = [];
  public swiperController: SwiperController = new SwiperController();
  public lottieItems: AnimationItem[] = [];
  // 动画每个item的播放时间
  public lottieTimes: number[] = [4000, 2500, 4000];
  public lottieTime: number = this.lottieTimes[0];
  public canvasWidth: number = 288;
  public canvasHeight: number = 288;
  public swiperItems: SwiperItem[] = [];
  public animationData: object | null = null;
  public currentIndex: number = CurrentState.NOT_INITIAL;
  private readonly TABLET_CANVAS_WIDTH: number = 254 * 1.5;
  private readonly TABLET_CANVAS_HEIGHT: number = 254;
  private readonly PHONE_EXPAND_CANVAS_HEIGHT_WIDTH: number = 334;
  private readonly PHONE_CANVAS_HEIGHT_WIDTH: number = 288;

  public updateViewData(): void {
    this.swiperItems = SwiperDataMgr.getInstance().getSwiperItems();
    for (let swiperItem of this.swiperItems) {
      this.canvasRenderingContextList[swiperItem.index] = new CanvasRenderingContext2D(this.mainRenderingSettings);
    }
    this.currentIndex = CurrentState.CLICK_BACK;
    LogUtil.showInfo(TAG, 'canvasWidth is %{public}d', this.canvasWidth);
  }

  public updateLottie() {
    let devicePrefix = DeviceUtil.deviceType + '_';
    if (devicePrefix == 'default_') {
      devicePrefix = 'phone_';
    }
    let isFoldScreenExpand = DeviceUtil.isFoldExpand() && DeviceUtil.isLargeInFoldProduct();
    LogUtil.showInfo(TAG, 'devicePrefix is %{public}s,expand is %{public}s', devicePrefix, isFoldScreenExpand);
    switch (devicePrefix) {
      case 'phone_':
        if (isFoldScreenExpand) {
          this.setCanvasWidthHeight(this.PHONE_EXPAND_CANVAS_HEIGHT_WIDTH,
            this.PHONE_EXPAND_CANVAS_HEIGHT_WIDTH);
          devicePrefix = 'fold_';
        } else {
          this.setCanvasWidthHeight(this.PHONE_CANVAS_HEIGHT_WIDTH,
            this.PHONE_CANVAS_HEIGHT_WIDTH);
        }
        break;
      case 'tablet_':
        this.setCanvasWidthHeight(this.TABLET_CANVAS_WIDTH,
          this.TABLET_CANVAS_HEIGHT);
        break;
      default:
        LogUtil.showError(TAG, 'deviceType is %{public}s, not support', devicePrefix);
    }
    let isFold = DeviceUtil.isFoldable();
    for (let swiperItem of this.swiperItems) {
      let swiperItemName = swiperItem.name;
      if (swiperItemName.startsWith('gesture_navigation')) {
        this.setSwiperItemName(swiperItem, devicePrefix, swiperItemName);
      } else if (isFold) {
        let firstIndex = swiperItemName.indexOf('_');
        this.setSwiperItemName(swiperItem, devicePrefix, swiperItemName.substring(firstIndex + 1));
      } else {
        LogUtil.showInfo(TAG, 'swiperItems no need to change');
      }
    }
    LogUtil.showInfo(TAG, 'swiperItems is %{public}s', this.swiperItems?.length);
  }

  private setSwiperItemName(swiperItem: SwiperItem, devicePrefix: string, swiperItemName: string): void {
    let name = devicePrefix + swiperItemName;
    if (swiperItem.name !== name) {
      swiperItem.name = name;
      LogUtil.showInfo(TAG, `setSwiperItemName ${name}`);
    }
  }

  private setCanvasWidthHeight(width: number, height: number): void {
    if (this.canvasWidth !== width) {
      this.canvasWidth = width;
      LogUtil.showInfo(TAG, `setCanvasWidth ${width}`);
    }
    if (this.canvasHeight !== height) {
      this.canvasHeight = height;
      LogUtil.showInfo(TAG, `setCcanvasHeight ${height}`);
    }
  }

  public async playLottie(index: number): Promise<void> {
    let item = this.swiperItems[index];
    LogUtil.showInfo(TAG, 'index %{public}d, load count is %{public}d', index, item.loadCount);
    try {
      let name: string = this.swiperItems[item.index].name;
      LogUtil.showInfo(TAG, `loadLottieData, lottieData: ${name}`);
      //加载动画前先销毁之前加载的动画
      lottie.destroy(name);
      item.isPlaying = true;
      this.lottieItems[index] = await this.startLottie(name, this.canvasRenderingContextList[item.index]);
      this.addEventListener(index);
    } catch (error) {
      LogUtil.showError(TAG, `context is undefined, message:${error.message}`,);
    }
  }

  /**
   * 开始播放动画
   */
  private async startLottie(name: string, canvas: CanvasRenderingContext2D): Promise<AnimationItem> {
    let animationItem = lottie.loadAnimation({
      container: canvas,
      renderer: 'canvas',
      loop: false,
      autoplay: true,
      name: name,
      frameRate: 30,
      contentMode: 'Contain',
      path: `resources/rawfile/${name}`,
    });
    return animationItem;
  }

  private addEventListener(index: number) {
    this.lottieItems[index].addEventListener('loopComplete', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d loopComplete', index);
    });
    this.lottieItems[index].addEventListener('complete', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d complete', index);
    });
    this.lottieItems[index].addEventListener('destroy', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d destroy', index);
    });
    this.lottieItems[index].addEventListener('DOMLoaded', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d DOMLoaded', index);
    });
    this.lottieItems[index].addEventListener('data_failed', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d data_failed', index);
    });

    this.lottieItems[index].addEventListener('error', (args: Object): void => {
      LogUtil.showInfo(TAG, 'lottie index:%{public}d error', index);
    });
  }
}

