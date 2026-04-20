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

import {
  BarBuffer,
  ChartPixelMap,
  Fill,
  FillDirection,
  Highlight,
  IValueFormatter,
  IWaterfallDataSet,
  JArrayList,
  MPPointF,
  Transformer,
  Utils,
  WaterfallChartRenderer,
  WaterfallData,
  WaterfallDataSet,
  WaterfallEntry,
} from '@ohos/mpchart';
import IBarDataSet from '@ohos/mpchart/src/main/ets/components/interfaces/datasets/IBarDataSet';
import { SCREEN_SELECT_BUBBLE_EVENT, } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { BATTERY_BAR_END_INDEX, Coordinate } from './BatteryBarChart';

/* instrument ignore file */
export default class CustomBarChartRender extends WaterfallChartRenderer {
  // 自定义buffer
  protected mCustomBarBuffers: CustomBarBuffer[] = [];
  // 重写drawHighlighted方法，使点击时始终选中，发送事件给电量图使用
  private mPersistentHighlight: Highlight | null = null;
  private _highlightDebounceTimer?: number;

  protected drawCircle(c: CanvasRenderingContext2D, left: number, top: number, radius: number) {
  }

  // 替换为自定义CustomBuffer
  public initBuffers(): void {
    if (!this.mChart) {
      return;
    }
    let data: WaterfallData | null = this.mChart.getWaterfallData();
    if (data) {
      this.mCustomBarBuffers = new Array(data.getDataSetCount());
      for (let i = 0; i < this.mCustomBarBuffers.length; i++) {
        let dataSet: IWaterfallDataSet | null = data.getDataSetByIndex(i) as IWaterfallDataSet;
        if (dataSet) {
          this.mCustomBarBuffers[i] =
            new CustomBarBuffer(dataSet.getEntryCount() * 4 * (dataSet.isStacked() ? dataSet.getStackSize() : 1),
              data.getDataSetCount(), dataSet.isStacked());
        }
      }
    }
  }

  // 替换为自定义CustomBuffer
  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: WaterfallDataSet, index: number): void {
    if (!this.mChart) {
      return;
    }
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

    if (this.mBarBorderPaint) {
      this.mBarBorderPaint.setColor(dataSet.getBarBorderColor());
      this.mBarBorderPaint.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()));
    }

    const drawBorder: boolean = dataSet.getBarBorderWidth() > 0.0;

    let phaseX: number = 1;
    let phaseY: number = 1;
    if (this.mAnimator) {
      phaseX = this.mAnimator.getPhaseX();
      phaseY = this.mAnimator.getPhaseY();
    }

    // initialize the buffer
    let buffer: CustomBarBuffer = this.mCustomBarBuffers[index];
    if (buffer === null || buffer === undefined) {
      return;
    }
    buffer.setPhases(phaseX, phaseY);
    buffer.setDataSet(index);
    buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()));
    let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
    if (waterfallData) {
      buffer.setBarWidth(waterfallData.getBarWidth());
    }

    buffer.feed(dataSet);
    if (trans) {
      trans.pointValuesToPixel(buffer.buffer);
    }

    let fills: JArrayList<Fill> | null = dataSet.getFills();
    const isCustomFill: boolean = !!fills && !fills.isEmpty();
    const isSingleColor: boolean = dataSet.getColors().size() === 1;
    const isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

    if (isSingleColor) {
      this.mRenderPaint.setColor(dataSet.getColor());
      const opacity = dataSet.getOpacity();
      this.mRenderPaint.globalAlpha = opacity / 100;
    }

    let arrayTop = buffer.getArrayTop();
    let maxTop = arrayTop[0];
    for (let i = 1; i < arrayTop.length; i++) {
      if (arrayTop[i] > maxTop) {
        maxTop = arrayTop[i];
      }
    }

    let arrayBottom = buffer.getArrayBottom();
    let minBottom = arrayBottom[0];

    for (let i = 1; i < arrayBottom.length; i++) {
      if (arrayBottom[i] < minBottom) {
        minBottom = arrayBottom[i];
      }
    }

    if (dataSet.getEnableMaxOrMinHighlightColor()) {
      for (let i = 0,
        count = Math.min(Number(Math.ceil(Number(dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount());
        i < count; i++) {
        let e: WaterfallEntry = dataSet.getEntryForIndex(i) as WaterfallEntry;
        this.initMaxAndMinHighlightData(e, dataSet, maxTop, minBottom);
      }
    }
    // 获取Y轴刻度范围数据
    let yAxisSegmentList = dataSet.getYAxisSegmentationColors();

    for (let j = 0, pos = 0; j < buffer.size(); j += 4, pos++) {
      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(buffer.buffer[j + 2])) {
        continue;
      }
      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(buffer.buffer[j])) {
        break;
      }
      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
        this.mRenderPaint.setColor(dataSet.getColor(pos));
      }

      if (isCustomFill) {
        let fill: Fill | null = dataSet.getFill(pos);
        if (fill) {
          fill.fillRect(
            c, this.mRenderPaint,
            buffer.buffer[j],
            buffer.buffer[j + 1],
            buffer.buffer[j + 2],
            buffer.buffer[j + 3],
            isInverted ? FillDirection.DOWN : FillDirection.UP);
        }
      } else {
        if (this.mRenderPaint) {
          Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
        }

        let left: number = buffer.buffer[j];
        let bottom: number = buffer.buffer[j + 1];
        let right: number = buffer.buffer[j + 2];
        let top: number = buffer.buffer[j + 3];

        //绘制数据
        let radius = (right - left) / 2;
        let path = new Path2D();
        let outBarIsEllipse = false;

        //绘制基本瀑布图
        if (Math.abs(top - bottom) > (right - left)) {
          path = this.drawRoundedRectangles(c, left, top, right, bottom, radius);
        } else {
          outBarIsEllipse = true;
          path = this.drawEllipse(c, left, top, right, bottom);
        }
        //绘制基本瀑布图结束

        c.save();
        c.clip(path);
        let e: WaterfallEntry = dataSet.getEntryForIndex(j / 4) as WaterfallEntry;
        // 绘制Y轴刻度范围图
        for (let i = 0; i < yAxisSegmentList.length; i++) {
          let h = yAxisSegmentList[i];
          // canvas画布的y轴与图表的y轴方向相反
          let maxY = h.getMinY();
          let minY = h.getMaxY();
          if (maxY > e.getMaxY() || (minY < e.getMaxY() && minY < e.getMinY())) {
            continue;
          }
          maxY = maxY <= e.getMinY() ? e.getMinY() : maxY;
          minY = minY >= e.getMaxY() ? e.getMaxY() : minY;
          let yArray = [0, minY, 0, maxY];
          trans?.pointValuesToPixel(yArray);
          c.save();
          c.fillStyle = h.getColor();
          this.drawWaterfallBar(c, left, right, radius, yArray, e, minY, maxY);
          c.restore();
        }
        c.restore();

        let highlights = e.getHighlights();
        let topNum = this.getHighlightTop(e);
        // 绘制标记点
        for (let i = 0; i < highlights.length; i++) {
          let h = highlights[i];
          // canvas画布的y轴与图表的y轴方向相反
          let maxY = h.getMinY();
          let minY = h.getMaxY();
          let yArray = [0, minY, 0, maxY];
          trans?.pointValuesToPixel(yArray);
          if (yArray[1] == yArray[3]) {
            c.save();
            c.fillStyle = h.getColor();
            c.clip(path);
            if (outBarIsEllipse) {
              this.drawEllipse(c, left, top, right, bottom);
            } else {
              if (yArray[1] == top) {
                // 绘制最高点
                this.drawEllipse(c, left, top, right, top + radius * 2);
              } else {
                // 绘制最低点
                this.drawEllipse(c, left, bottom - radius * 2, right, bottom);
              }
            }
            c.restore();
            continue;
          }
          c.save();
          c.fillStyle = h.getColor();
          c.clip(path);
          if (e.getHighlights().length === 1) {
            this.drawRoundedRectangles(c, left, yArray[1], right, yArray[3], radius);
          } else {
            this.drawHighlights(c, left, radius, yArray, i, right, h, topNum, outBarIsEllipse);
          }
          c.restore();
        }
      }

      if (drawBorder) {
        if (this.mBarBorderPaint) {
          Utils.resetContext2DWithoutFont(c, this.mBarBorderPaint);
        }
        c.beginPath();
        c.rect(buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2] - buffer.buffer[j],
          buffer.buffer[j + 3] - buffer.buffer[j + 1]);
        c.stroke();
        c.closePath();
      }
    }
    dataSet.setMaxTopHighlightEXIST(false);
    dataSet.setMinBottomHighlightEXIST(false);
  }


  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {
    // 防抖处理
    if (this._highlightDebounceTimer) {
      clearTimeout(this._highlightDebounceTimer);
    }
    this._highlightDebounceTimer = setTimeout(() => {
      this.doDrawHighlighted(c, indices);
    }, 60);
  }

  private doDrawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {
    //x坐标
    let waterX: number = 0;
    if (indices == null || indices.length == 0) {
      if (this.mPersistentHighlight != null) {
        super.drawHighlighted(c, [this.mPersistentHighlight]);
        waterX = this.mPersistentHighlight?.getX();
      }
    } else {
      this.mPersistentHighlight = indices[0];
      waterX = this.mPersistentHighlight?.getX();
      super.drawHighlighted(c, indices);
      let y: number = 0;
      if (this.mPersistentHighlight?.getY()) {
        y = this.mPersistentHighlight?.getY();
      }
      let point: Coordinate = { x: waterX, y: y }
      // 发送x坐标给电量图，用于显示气泡
      EventBus.getInstance().emit(SCREEN_SELECT_BUBBLE_EVENT, point);
    }
  }

  // @Override 替换自定义CustomBuffer
  public drawValues(c: CanvasRenderingContext2D): void {
    if (!this.mChart || !this.mChart.getWaterfallData()) {
      return;
    }
    // if values are drawn
    if (this.isDrawingValuesAllowed(this.mChart)) {
      let waterfallData: WaterfallData | null = this.mChart.getWaterfallData();
      if (!waterfallData) {
        return;
      }
      let dataSets: JArrayList<IWaterfallDataSet> = waterfallData.getDataSets();

      const valueOffsetPlus: number = 0;
      let posOffset: number = 0;
      let negOffset: number = 0;
      let drawValueAboveBar: boolean = this.mChart.isDrawValueAboveBarEnabled();

      for (let i = 0; i < waterfallData.getDataSetCount(); i++) {

        let dataSet: IWaterfallDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet)) {
          continue;
        }

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

        // calculate the correct offset depending on the draw position of the value
        let valueTextHeight: number = Utils.getLabelTextSize(this.mValuePaint, '8', this.textSizeCache).height;
        posOffset = (drawValueAboveBar ? -valueOffsetPlus : valueTextHeight + valueOffsetPlus);
        negOffset = (drawValueAboveBar ? valueTextHeight + valueOffsetPlus : -valueOffsetPlus);

        if (isInverted) {
          posOffset = -posOffset - valueTextHeight;
          negOffset = -negOffset - valueTextHeight;
        }

        // get the buffer
        let buffer: CustomBarBuffer = this.mCustomBarBuffers[i];

        let iconsOffset: MPPointF = MPPointF.getInstance(0, 0, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        for (let j = 0; j < buffer.buffer.length * (this.mAnimator ? this.mAnimator.getPhaseX() : 1); j += 4) {
          let x: number = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2;
          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x)) {
            break;
          }
          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsY(buffer.buffer[j + 1]) ||
            !this.mViewPortHandler.isInBoundsLeft(x)) {
            continue;
          }

          let entry: WaterfallEntry = dataSet.getEntryForIndex(j / 4) as WaterfallEntry;
          let val: number = entry.getY();
          if (dataSet.isDrawValuesEnabled()) {
            let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
            if (valueFormatter) {
              this.drawValue(c, valueFormatter, val, entry, i, x,
                (buffer.buffer[j + 3] + posOffset),
                dataSet.getValueTextColor(j / 4));
            }
          }
          let icon: ChartPixelMap | null = entry.getIcon();
          if (icon && dataSet.isDrawIconsEnabled()) {
            let px: number = x + iconsOffset.x;
            let py: number = buffer.buffer[j + 3] + posOffset + iconsOffset.y
            Utils.drawImage(
              c,
              icon,
              Utils.parseInt(px),
              Utils.parseInt(py),
              icon.getWidth(),
              icon.getHeight());
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }
}

class CustomBarBuffer extends BarBuffer {
  private arrayTop: Array<number> = [];
  private arrayBottom: Array<number> = [];

  public getArrayTop(): Array<number> {
    return this.arrayTop;
  }

  public getArrayBottom(): Array<number> {
    return this.arrayBottom;
  }

  public feed(data: IBarDataSet): void {
    let size: number = data.getEntryCount() * this.phaseX;
    let barWidthHalf: number = this.mBarWidth / 2;
    this.arrayTop = [];
    this.arrayBottom = [];
    for (let i = 0; i < size; i++) {
      let e: WaterfallEntry | null = data.getEntryForIndex(i) as WaterfallEntry;
      if (e == null) {
        continue;
      }
      let x: number = e.getX();
      let y1: number = e.getMinY();
      let y2: number = e.getMaxY();
      let maxY = Math.max(y1, y2);
      let minY = Math.min(y1, y2);
      let bottom = this.mInverted ? minY : maxY;
      let top = this.mInverted ? maxY : minY;
      this.arrayTop.push(e.getMaxY());
      this.arrayBottom.push(e.getMinY());

      // 对首位的柱子进行特殊处理，超过30分钟的情况，第0根柱子宽度为一半，最后一根柱子宽度为一半
      let nowMinute = new Date().getMinutes();
      if (nowMinute >= 30) {
        if (Math.abs(x - BATTERY_BAR_END_INDEX) < 1e-6) {
          this.addWaterfall(x, 0, x, 0);
        } else {
          this.addWaterfall(x - barWidthHalf, top * this.phaseY, x + barWidthHalf, bottom * this.phaseY);
        }
      } else { // 对于为超过30分钟的情况，整体往右偏移barWidthHalf
        if (x === 24 || Math.abs(x - BATTERY_BAR_END_INDEX) < 1e-6) {
          this.addWaterfall(x, 0, x, 0);
        } else {
          this.addWaterfall(x, top * this.phaseY, x + 2 * barWidthHalf, bottom * this.phaseY);
        }
      }
    }
    this.reset();
  }

  protected addWaterfall(left: number, top: number, right: number, bottom: number): void {
    this.buffer[this.index++] = left;
    this.buffer[this.index++] = top;
    this.buffer[this.index++] = right;
    this.buffer[this.index++] = bottom;
  }
}
