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

import { display } from '@kit.ArkUI';
import { CurrentState, SwiperViewData } from './SwiperViewData';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG = 'SwiperViewModel';

const VASSISTANT_INDEX = 3;

export class SwiperViewModel {
  private viewData: SwiperViewData;

  constructor(viewData: SwiperViewData) {
    this.viewData = viewData;
  }

  public initViewData(): void {
    this.viewData.updateViewData();
  }

  public registerScreenListener(): void {
    LogUtil.showInfo(TAG, '[%{public}s] registerScreenListener', TAG);
    try {
      display.on('foldStatusChange', this.foldDisplayModeChangeCallback);
      display.on('change', this.displayModeChangeCallback);
    } catch (e) {
      LogUtil.error(`${TAG} display.on callback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  public unRegisterScreenListener(): void {
    LogUtil.showInfo(TAG, '[%{public}s] unRegisterScreenListener', TAG);
    try {
      display.off('foldStatusChange', this.foldDisplayModeChangeCallback);
      display.off('change', this.displayModeChangeCallback);
    } catch (e) {
      LogUtil.error(`${TAG} display.off callback error error.code ${e?.code} error.message ${e?.message}`);
    }
  }

  private foldDisplayModeChangeCallback: () => void = () => {
    LogUtil.showInfo(TAG, 'foldStatusChange');
    this.updateLottie();
  };
  private displayModeChangeCallback: () => void = () => {
    LogUtil.showInfo(TAG, 'screen change');
    this.updateLottie();
  };

  public updateLottie() {
    this.viewData.updateLottie();
  }

  public playLottie(index: number) {
    this.viewData.playLottie(index);
  }

  public jumpIndexChange(jumpIndex: number): void {
    LogUtil.showInfo(TAG, `jumpIndexChange index is ${jumpIndex},currentIndex is:${this.viewData?.currentIndex}`);
    switch (jumpIndex) {
      case VASSISTANT_INDEX:
        this.clickJumpLottie(VASSISTANT_INDEX);
        break;
      default:
        LogUtil.showError(TAG, 'jump index is %{public}d, error', jumpIndex);
        break;
    }
  }

  public clickJumpLottie(jumpIndex: number): void {
    this.viewData.swiperController?.finishAnimation();
    if (this.viewData.currentIndex !== jumpIndex) {
      this.viewData.swiperController?.changeIndex(jumpIndex, true);
      LogUtil.showInfo(TAG, `jump index is ${jumpIndex}`);
    }
  }

  public refreshLottieState(): void {
    LogUtil.showInfo(TAG, 'index %{public}d refreshLottieState', this.viewData.currentIndex);
    if (this.viewData.currentIndex !== CurrentState.NOT_INITIAL) {
      this.viewData.lottieItems[this.viewData.currentIndex]?.play();
    }
  }

  public closeLottieState(): void {
    LogUtil.showInfo(TAG, '[%{public}s] closeLottieState, currentIndex is %{public}d', TAG, this.viewData.currentIndex);
    this.viewData.lottieItems[this.viewData.currentIndex]?.goToAndPlay(0, true);
    this.viewData.lottieItems[this.viewData.currentIndex]?.pause();
  }
}