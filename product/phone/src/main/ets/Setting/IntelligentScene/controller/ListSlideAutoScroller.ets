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

import Curves from '@ohos.curves';
import Display from '@ohos.display';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';

/* instrument ignore file */
const TAG: string = 'ListSlideAutoScroller';
const toolBarHeight: number = 52;

/*
 * 列表滑动多选: 滑到底部/顶部时,处理自动上滑/下滑且选中的逻辑
 */
export class ListSlideAutoScroller {
  // 热区趋势阈值:5vp
  private static readonly THRESHOLD: number = 5;
  private speedFlag: number = 0;
  private scrollerHeight: number = 0;
  private extraUpArea: number = 0;
  private extraDownArea: number = 0;
  private oriGesturePosY: number = 0;
  public isEntryFromHotAndNotScrolled: boolean = false;

  // 自动滚动或停止
  public autoScrollOrStop(scroller: Scroller, gesturePosY: number): void {
    let isIn: boolean = false;
    if (gesturePosY > this.extraUpArea && gesturePosY <= this.getHotAreaLength() + this.extraUpArea) {
      if (!this.isEntryFromHotAndNotScrolled || this.isWantToAutoUp(gesturePosY)) {
        if (this.getHotAreaLength() + this.extraUpArea === 0) {
          this.speedFlag = 0;
        } else {
          this.speedFlag = this.getSlideSelectSpeedCurve()
            .interpolate(1 - gesturePosY / (this.getHotAreaLength() + this.extraUpArea));
        }
        scroller.scrollEdge(Edge.Top, { velocity: this.speedFlag * this.getAutoSlideMaxSpeed() });
        this.isEntryFromHotAndNotScrolled = false;
      }
      return;
    } else if (
      gesturePosY < this.scrollerHeight - this.extraDownArea &&
        gesturePosY >= this.scrollerHeight - this.extraDownArea - this.getHotAreaLength()) {
      if (!this.isEntryFromHotAndNotScrolled || this.isWantToAutoDown(gesturePosY)) {
        if (this.getHotAreaLength() + this.extraDownArea === 0) {
          this.speedFlag = 0;
        } else {
          this.speedFlag = this.getSlideSelectSpeedCurve()
            .interpolate(1 - (this.scrollerHeight - gesturePosY) / (this.getHotAreaLength() + this.extraDownArea));
        }
        scroller.scrollEdge(Edge.Bottom, { velocity: this.speedFlag * this.getAutoSlideMaxSpeed() });
        this.isEntryFromHotAndNotScrolled = false;
      }
      return;
    }
    // 热区扩展区域:最大速度滚动
    if ((gesturePosY >= 0 && gesturePosY <= this.extraUpArea) || gesturePosY < 0) {
      scroller.scrollEdge(Edge.Top, { velocity: this.getAutoSlideMaxSpeed() });
      isIn = true;
      this.isEntryFromHotAndNotScrolled = false;
    } else if ((gesturePosY <= this.scrollerHeight &&
      gesturePosY >= this.scrollerHeight - this.extraDownArea) || gesturePosY > this.scrollerHeight) {
      scroller.scrollEdge(Edge.Bottom, { velocity: this.getAutoSlideMaxSpeed() });
      isIn = true;
      this.isEntryFromHotAndNotScrolled = false;
    }
    if (!isIn) {
      this.isEntryFromHotAndNotScrolled = false;
      scroller.scrollBy(0, 0);
    }
  }

  public setScrollerHeight(height: number): void {
    this.scrollerHeight = height;
  }

  public initIsEntryFromHotAndNotScrolled(gesturePosY: number): void {
    this.isEntryFromHotAndNotScrolled = false;
    this.oriGesturePosY = gesturePosY;
    if (gesturePosY < this.extraUpArea || gesturePosY > this.scrollerHeight - this.extraDownArea) {
      return;
    }
    if (gesturePosY < this.extraUpArea + this.getHotAreaLength() ||
      gesturePosY > this.scrollerHeight - this.extraDownArea - this.getHotAreaLength()) {
      this.isEntryFromHotAndNotScrolled = true;
    }
  }

  public setExtraAreaHeightByIsHorizontal(isHorizontal: boolean, actionBarHeight: number = 0,
    statusBarHeight: number = 0,
    upFlag: boolean = false, downFlag: boolean = false) {
    if (isHorizontal) {
      this.extraUpArea = actionBarHeight - statusBarHeight;
      this.extraDownArea = 0;
    } else {
      this.extraUpArea = actionBarHeight;
      this.extraDownArea = toolBarHeight;
    }
    // 标题栏无沉浸式时，upFlag赋值为true
    if (upFlag) {
      this.extraUpArea = 0;
    }
    // toolBar无模糊时，downFlag赋值为true
    if (downFlag) {
      this.extraDownArea = 0;
    }
  }

  private isWantToAutoDown(gesturePosY: number): boolean {
    return gesturePosY - this.oriGesturePosY > ListSlideAutoScroller.THRESHOLD
  }

  private isWantToAutoUp(gesturePosY: number): boolean {
    return this.oriGesturePosY - gesturePosY > ListSlideAutoScroller.THRESHOLD;
  }

  private getSlideSelectSpeedCurve(): Curves.ICurve {
    return Curves.cubicBezierCurve(0.33, 0, 0.67, 1);
  }

  private getAutoSlideMaxSpeed(): number {
    let display: Display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
    if (display && display.densityPixels !== 0) {
      // 计算滚动速度: 贝塞尔曲线
      return Math.round(1600 / display.densityPixels);
    }
    return 0;
  }

  private getHotAreaLength(): number {
    let display: Display.Display | undefined = DisplayUtils.getDefaultDisplaySyncInfo();
    if (display && display.densityPixels !== 0) {
      // UX热区规范
      return Math.round(display.densityDPI * 10 / 25.4 / display.densityPixels);
    }
    return 0;
  }
}