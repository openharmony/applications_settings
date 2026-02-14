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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';

const TAG: string = 'WlanPullLoadingController : ';
const DEFAULT_VERTICAL_OFFSET: number = -64;
const VIBRATION_DURATION: number = 100;
const DOUBLE: number = 2;

export class WlanPullLoadingController implements ComponentControl {
  private isTop: boolean = true;
  private loadPull: boolean = false;
  private isReachStart: boolean = false;
  private verticalOffset: number = DEFAULT_VERTICAL_OFFSET;
  private marBtm: number = 0;
  private isShowingPullBar: boolean = false;
  private onVisibleChange?: (show: boolean) => void;
  private onHeightChange?: (newHeight: number) => void;

  init(param?: object | undefined): void {
  }

  destroy(): void {
  }

  registerVisibleChangeListener(onVisibleChange: (show: boolean) => void): void {
    this.onVisibleChange = onVisibleChange;
  }

  registerHeightChangeListener(onHeightChange: (newHeight: number) => void): void {
    this.onHeightChange = onHeightChange;
  }

  unRegisterListener(): void {
    this.onVisibleChange = undefined;
    this.onHeightChange = undefined;
  }

  onScrollStop(): void {
    this.verticalOffset = DEFAULT_VERTICAL_OFFSET;
    this.loadPull = false;
    this.isReachStart = false;
    this.onPullLoadStateChange();
  }

  onReachStart(): void {
    // 有滑动且滑到列表起始位置时记录isReachStart
    if (this.verticalOffset !== DEFAULT_VERTICAL_OFFSET) {
      this.isReachStart = true;
    }
    this.isTop = true;
    this.onPullLoadStateChange();
  }

  onScroll(yOffset: number, scrollState: ScrollState): void {
    this.verticalOffset = this.verticalOffset + yOffset;
    if (this.verticalOffset > 0 && this.isTop) {
      this.isTop = false;
    }
    // 判断在列表顶部且向上滑，isTop为false
    if (this.loadPull && this.verticalOffset > (DOUBLE * DEFAULT_VERTICAL_OFFSET)) {
      this.loadPull = false;
    } else if (!this.loadPull && this.verticalOffset <= (DOUBLE * DEFAULT_VERTICAL_OFFSET)) {
      this.loadPull = true;
      /* instrument ignore if*/
      if (this.isTop && !this.isReachStart) {
        this.vibratorLoading();
      }
    }
    this.marBtm = this.verticalOffset;
    /* instrument ignore if*/
    if (this.onHeightChange) {
      this.onHeightChange(this.marBtm);
    }
    this.onPullLoadStateChange();
  }

  onPullLoadStateChange(): void {
    if (this.isTop && this.loadPull && !this.isReachStart) {
      if (!this.isShowingPullBar) {
        this.isShowingPullBar = true;
        this.changeVisible(true);
      }
      return;
    }
    if (this.isShowingPullBar) {
      this.isShowingPullBar = false;
      this.changeVisible(false);
    }
  }

  private changeVisible(isVisible: boolean) {
    /* instrument ignore if*/
    if (this.onVisibleChange) {
      this.onVisibleChange(isVisible);
    }
  }

  // 下拉刷新震感
  private async vibratorLoading(): Promise<void> {
    try {
      VibratorUtil.vibrateOnVibrateMode(VIBRATION_DURATION, 'physicalFeedback', 'haptic.drag');
    } catch (error) {
      LogUtil.error(`${TAG}, vibratorLoading failed, ${error?.message}`);
    }
  }
}