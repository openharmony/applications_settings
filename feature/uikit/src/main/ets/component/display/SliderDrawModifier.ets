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

import uiAppearance from '@ohos.uiAppearance';
import { DrawContext } from '@ohos.arkui.node';
import { common2D, drawing } from '@kit.ArkGraphics2D';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
/* instrument ignore file */
const TAG: string = 'SliderDrawModifier';

export class SliderDrawModifier extends DrawModifier {
  private stepRadius: number = 2;
  private num: number = 2;
  private trackThickness: number = 20;
  private drawOffsetX: number = 6;
  public value: number = 0;
  public min: number = 0;
  public max: number = 100;
  public default: number = 0;

  drawBehind(context: DrawContext): void {
    LogUtil.info(`${TAG} drawBehind `);
    this.value = LanguageUtils.isLtrDirection() ? this.default : this.max - (this.default - this.min);
    let isDarkMode: boolean = uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    let brush = new drawing.Brush();
    let lightColor: common2D.Color = {
      alpha: 25,
      red: 24,
      green: 36,
      blue: 49
    };
    let darkColor: common2D.Color = {
      alpha: 25,
      red: 255,
      green: 255,
      blue: 255
    };
    try {
      brush.setColor(isDarkMode ? darkColor : lightColor);
      context.canvas.attachBrush(brush);
      let position: PositionT<number> = this.getCirclePosition(context.size.width, context.size.height, this.value);
      context.canvas.drawCircle(vp2px(position.x), vp2px(position.y), vp2px(this.stepRadius));
    } catch (error) {
      LogUtil.error(`${TAG} drawBehind error. code:${error?.code} message:${error?.message}`);
    }
  }

  getCirclePosition(width: number, height: number, value: number): PositionT<number> {
    let zeroValuePosition: number = this.drawOffsetX + this.trackThickness / this.num;
    let position: PositionT<number> = {
      x: zeroValuePosition,
      y: height / this.num,
    };

    let totalDistance = width - this.drawOffsetX * this.num - this.trackThickness;
    let rate = (value - this.min) / ((this.max - this.min));
    position.x = zeroValuePosition + totalDistance * rate;
    return position;
  }
}