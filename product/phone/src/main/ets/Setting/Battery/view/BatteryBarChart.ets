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

import { common } from '@kit.AbilityKit';
import { taskpool } from '@kit.ArkTS';
import { commonEventManager } from '@kit.BasicServicesKit';
import { BusinessError } from '@ohos.base';
import { BarChart } from '@ohos/mpchart/src/main/ets/components/chartcomponents/BarChart';
import BarChartModel from '@ohos/mpchart/src/main/ets/components/charts/BarChartModel';
import WaterfallChartModel from '@ohos/mpchart/src/main/ets/components/charts/WaterfallChartModel';
import Description from '@ohos/mpchart/src/main/ets/components/components/Description';
import Legend, {
  LegendForm,
  LegendHorizontalAlignment,
  LegendVerticalAlignment
} from '@ohos/mpchart/src/main/ets/components/components/Legend';
import LimitLine from '@ohos/mpchart/src/main/ets/components/components/LimitLine';
import { XAxis, XAxisPosition } from '@ohos/mpchart/src/main/ets/components/components/XAxis';
import YAxis, { AxisDependency } from '@ohos/mpchart/src/main/ets/components/components/YAxis';
import BarData from '@ohos/mpchart/src/main/ets/components/data/BarData';
import EntryOhos from '@ohos/mpchart/src/main/ets/components/data/EntryOhos';
import WaterfallDataSet from '@ohos/mpchart/src/main/ets/components/data/WaterfallDataSet';
import WaterfallEntry, { WaterfallHighlight } from '@ohos/mpchart/src/main/ets/components/data/WaterfallEntry';
import ChartHighlighter from '@ohos/mpchart/src/main/ets/components/highlight/ChartHighlighter';
import Highlight from '@ohos/mpchart/src/main/ets/components/highlight/Highlight';
import IBarDataSet from '@ohos/mpchart/src/main/ets/components/interfaces/datasets/IBarDataSet';
import OnChartValueSelectedListener from '@ohos/mpchart/src/main/ets/components/listener/OnChartValueSelectedListener';
import { JArrayList } from '@ohos/mpchart/src/main/ets/components/utils/JArrayList';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import DeviceUsageManager, {
  DEVICE_USAGE_DATA_LOADING
} from '@ohos/settings.common/src/main/ets/data/DeviceUsageDataManager';
import { DeviceUsageHistory } from '@ohos/settings.common/src/main/ets/data/DeviceUsageDataType';
import {
  SCREEN_ON_TIME_EVENT,
  SELECT_CONSUMPTION_CHART_ALL_EVENT,
  SELECT_CONSUMPTION_CHART_SEGMENT_EVENT,
  SELECT_SCREEN_TIME_CHART_ALL_EVENT,
  SELECT_SCREEN_TIME_CHART_SEGMENT_EVENT
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { TimeFormat, TimeUtil } from '@ohos/settings.common/src/main/ets/utils/TimeUtil';
import CustomBarChartRender from './CustomBarChartRender';

/* instrument ignore file */
export const BATTERY_BAR_END_INDEX: number = 24.01;

export const SCREEN_ON_COLOR: string = '#FF0A59F7';

export const SCREEN_OFF_COLOR: string = '#D95291FF';

const TAG = 'BatteryBarChart';
const PER_MIN_IN_MILLIS: number = DateTimeUtil.getPerMinInMillis();

@Concurrent
async function refreshDealBatteryData(context: common.Context): Promise<DeviceUsageHistory[]> {
  return await DeviceUsageManager.queryDeviceUsageHistoryData(context);
}

export interface DeviceTime {
  screenOnTime: number,
  screenOffTime: number,
}

export interface Coordinate {
  x: number,
  y: number,
}


/**
 * 数据库插入完成通知刷新事件
 */
const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: [DEVICE_USAGE_DATA_LOADING],
  publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS
};

@Component
export struct BatteryBarChart {
  private batteryChart: WaterfallChartModel | null = null; // 柱状图配置构建类
  private data: BarData | null = null; // 柱状图数据包
  private normalAllDataSets: JArrayList<IBarDataSet> = new JArrayList;
  private allDataSets: JArrayList<IBarDataSet> = new JArrayList;
  // 坐标对应的时间戳
  private indexAndTimes: Map<number, DeviceTime> = new Map();
  private bottomAxis?: XAxis | null;
  private axisLeft?: YAxis | null;
  private axisRight?: YAxis | null;
  private chartLegend?: Legend | null;
  private chartDescription?: Description | null;
  // 数据库折线图数据
  private deviceUsageData?: DeviceUsageHistory[];
  private smallStartNumber: number = 0;
  // Y轴两端的时间对应的时间戳
  private timeInMillis: number = 0;
  private chartMinTime: number = 0;
  // 表格最大的索引值
  private chartMaxIndex = 24;
  // 一小时毫秒数
  private oneHourMillis = 3600000;
  // X轴网格线 宽度
  private lineWidth = 0.2;
  //柱子的宽度
  private barWidth = 0.6;
  // 一共坐标点的总数
  private allIndexCount: number = 48;
  private xAxisLeftShowBoundaries: number = 5;
  private xAxisRightShowBoundaries: number = 21;
  // 百分之十 透明度灰色
  private greyColorNumber: number = 11776947;
  private middleNumber: number = 15;
  private maxEndNumber: number = 62;
  private isRenderAllChart: boolean = true;
  private allDeviceTimeData: DeviceTime = { screenOnTime: 0, screenOffTime: 0 };

  private powerDataState: CommonEventHelper = new CommonEventHelper(subscribeInfo, (err, data) => {
    if (err?.code) {
      LogUtil.error(`${TAG} CommonEventHelper failed. code:${err?.code} message:${err?.message}`);
    } else {
      LogUtil.info(`${TAG} getDataFromDatabase from common event:${data?.event}`);
      this.getDataFromDatabase();
    }
  })

  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (entry: EntryOhos, h: Highlight) => {
      let xIndex = entry.getX();
      LogUtil.info(`${TAG} onValueSelected, x: ${xIndex}`)
      this.doValueSelectedListenerForIndexChanged(xIndex);
    },
    onNothingSelected: () => {
      LogUtil.info(`${TAG} onNothingSelected`);
    },
  }

  /**
   * 监听电量图渲染全部的事件处理
   */
  private onConsumptionAllCallback = (() => {
    if (!this.isRenderAllChart) {
      this.isRenderAllChart = true;
      this.doNothingSelected();
    }
  });

  /**
   * 监听电量图渲染x坐标的事件处理
   */
  private onConsumptionChangedCallback = ((point: Coordinate) => {
    let x: number = point.x;
    let y: number = point.y;
    LogUtil.info(`${TAG}, onConsumptionChangedCallback recv point: [${x}, ${y}]`);
    let nowMinute = new Date().getMinutes();
    //点击电量图，电量图y值为0的情况: 1.如果瀑布图的y也是0，则需要渲染全部；2.如果瀑布图的y值不为0，则需要选中柱子
    //将瀑布图计算结果通知给电量图，进行统一入口控制
    if (y === 0 && x < this.allIndexCount) {
      let thisX: number = 0;
      if (nowMinute < 30) {
        thisX = Math.floor(x / 2);
      } else {
        if (x === 0) {
          thisX = 0;
        } else {
          thisX = Math.floor((x + 1) / 2);
        }
      }
      let deviceTime = this.indexAndTimes.get(thisX);
      if (!deviceTime) {
        return;
      }
      let thisY = deviceTime.screenOnTime + deviceTime.screenOffTime;
      // 发送通知给电量图，同步刷新电量图
      LogUtil.info(`${TAG}, onConsumptionChangedCallback emit: [${thisX}, ${thisY}]`);
      EventBus.getInstance().emit(SELECT_SCREEN_TIME_CHART_SEGMENT_EVENT, { x: thisX, y: thisY });
      return;
    }

    if (nowMinute < 30) {
      if (x === this.allIndexCount) {
        this.doNothingSelected();
      } else {
        this.renderSelectedChart(Math.floor(x / 2));
      }
    } else {
      if (x === this.allIndexCount) {
        this.doNothingSelected();
      } else if (x === 0) {
        this.renderSelectedChart(x);
      } else {
        this.renderSelectedChart(Math.floor((x + 1) / 2));
      }
    }
  });

  private doNothingSelected() {
    let barData: BarData = new BarData(this.allDataSets);
    barData.setBarWidth(this.barWidth);
    barData.setTopRadius(20);
    this.batteryChart?.setData(barData);
    this.batteryChart?.invalidate();
    EventBus.getInstance().emit(SCREEN_ON_TIME_EVENT, this.allDeviceTimeData);
  }

  /**
   * 选中柱子处理，选中边界时渲染全部
   *
   * @param x 选中柱子的x坐标值
   */
  private doValueSelectedListenerForIndexChanged(x: number) {
    // 对右边界进行处理，触发则走onNothingSelected
    let nowMinute = new Date().getMinutes();
    if ((nowMinute >= 30 && Math.abs(x - BATTERY_BAR_END_INDEX) < 1e-6) || (nowMinute < 30 && x > 23)) {
      // 超过边界之后，渲染全图
      if (!this.isRenderAllChart) {
        this.isRenderAllChart = true;
        this.doNothingSelected();
        EventBus.getInstance().emit(SELECT_SCREEN_TIME_CHART_ALL_EVENT);
      }
      return;
    }
    let point: Coordinate = { x: x, y: 0 }
    let times = this.indexAndTimes.get(x);
    if (times) {
      point = { x: x, y: times.screenOnTime + times.screenOffTime };
    }
    //发送通知给电量图，同步刷新电量图
    EventBus.getInstance().emit(SELECT_SCREEN_TIME_CHART_SEGMENT_EVENT, point);
  }

  /**
   * 渲染指定柱子
   *
   * @param x 选中柱子的x坐标
   */
  private renderSelectedChart(x: number) {
    LogUtil.info(`${TAG} renderSelectedChart, x: ${x}`);
    //清除上一次的highlight，防止概率性触发onNothingSelected
    this.batteryChart?.getOnTouchListener()?.setLastHighlighted();
    this.isRenderAllChart = false;
    let selectIndex = x;
    let times = this.indexAndTimes.get(selectIndex);
    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList = this.normalAllDataSets; // 灰色的柱状图 对应全部数据
    if (!times) {
      LogUtil.showWarn(TAG, `renderSelectedChart indexAndTimes has no valid data!`);
      return;
    }
    for (let i = 0; i < dataSetList.size(); ++i) {
      let dataSet = dataSetList.get(i);
      if (!(dataSet instanceof WaterfallDataSet)) {
        continue;
      }
      if (i === x) {
        let highlightList: WaterfallHighlight[] = [];
        highlightList.push(new WaterfallHighlight(0, times.screenOnTime, SCREEN_ON_COLOR));
        if (times.screenOffTime !== 0) {
          highlightList.push(new WaterfallHighlight(times.screenOnTime, times.screenOnTime + times.screenOffTime,
            SCREEN_OFF_COLOR));
        }
        dataSet.setYAxisSegmentationColors(highlightList);
        dataSet.setColorByColor(Color.Transparent);
        dataSet.setHighLightAlpha(0);
      } else {
        dataSet.setColorByColor(this.greyColorNumber);
        dataSet.setYAxisSegmentationColors([]);
        dataSet.setHighLightAlpha(0);
      }
    }

    // 灰色的+选中的 datasetList
    const barData: BarData = new BarData(dataSetList);
    barData.setTopRadius(20);
    barData.setBarWidth(this.barWidth);
    this.batteryChart?.setData(barData);
    this.batteryChart?.invalidate();

    // 发送亮灭屏活动时间
    EventBus.getInstance().emit(SCREEN_ON_TIME_EVENT, times);
  }

  /**
   * 从数据库获取全部数据
   */
  private getDataFromDatabase(): void {
    try {
      let taskPoolTask: taskpool.Task = new taskpool.Task(refreshDealBatteryData, AbilityContextManager.getContext());
      taskpool.execute(taskPoolTask, taskpool.Priority.HIGH).then(async res => {
        this.deviceUsageData = res as DeviceUsageHistory[];
        LogUtil.info(`${TAG} getDataFromDatabase deviceUsageData length: ${this.deviceUsageData?.length}`);
        let barData: BarData = await this.dealNormalBatteryChartForWater();
        this.batteryChart?.setData(barData);
        // 获取数据的时候重新刷新X轴时间和日期
        this.setBottomAxisConfig();
        this.batteryChart?.invalidate();
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} getDataFromDatabase catch error. code: ${err?.code} message: ${err?.message}`);
      });
    } catch (error) {
      LogUtil.error(`${TAG} getDataFromDatabase failed. code: ${error?.code} message: ${error?.message}`);
    }
  }

  /**
   * 处理正常上报的电量图
   *
   * @returns 电量数据
   */
  private async dealNormalBatteryChartForWater(): Promise<BarData> {
    return new Promise((resolve) => {
      if (!this.deviceUsageData || this.deviceUsageData.length < 1) {
        resolve(new BarData());
        return;
      }
      let dataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
      let powerData = this.deviceUsageData.reverse();
      if (powerData.length > 0) {
        // 根据当前时间判断
        let nowMinute = new Date().getMinutes();
        if (nowMinute < 30) {
          // 未超半小时过做24段处理，一小时一段
          this.doWholeHourIndex(powerData, dataSets);
        } else {
          // 超过半小时做25段处理，首尾为半小时柱子
          this.doSpecialHalfHourIndex(powerData, dataSets);
        }
      }
      this.data = new BarData(dataSets);
      this.data.setBarWidth(this.barWidth);
      this.data.setTopRadius(20);
      resolve(this.data);
    });
  }

  /**
   * 构造一根柱子的数据
   *
   * @param normalDataSets 高亮数据缓存
   * @param dataSets 所有柱子的数据
   * @param x 柱状图位置索引
   * @param screenOnTime 亮屏时长 单位为分钟
   * @param screenOffTime 后台活动时长 单位为分钟
   */
  private addOneBar(normalDataSets: JArrayList<IBarDataSet>, dataSets: JArrayList<IBarDataSet>, x: number,
    screenOnTime: number, screenOffTime: number) {
    let values: JArrayList<WaterfallEntry> = new JArrayList<WaterfallEntry>();
    values.add(new WaterfallEntry(x, 0, screenOnTime + screenOffTime));
    let normalHighlightList: WaterfallHighlight[] = [];
    normalHighlightList.push(new WaterfallHighlight(0, screenOnTime, SCREEN_ON_COLOR));
    if (screenOffTime !== 0) {
      normalHighlightList.push(new WaterfallHighlight(screenOnTime, screenOnTime + screenOffTime, SCREEN_OFF_COLOR));
    }
    let dataSet = new WaterfallDataSet(values, 'DataSet');
    dataSet.setYAxisSegmentationColors(normalHighlightList);
    // 最高点最低点是否高亮
    dataSet.setEnableMaxOrMinHighlightColor(false);
    dataSet.setColorByColor(Color.Transparent);
    dataSet.setHighLightAlpha(0);
    dataSets.add(dataSet);
    let greyHighlightList: WaterfallHighlight[] = [];
    greyHighlightList.push(new WaterfallHighlight(0, screenOnTime, Color.Grey));
    if (screenOffTime !== 0) {
      greyHighlightList.push(new WaterfallHighlight(screenOnTime, screenOnTime + screenOffTime, Color.Grey));
    }
    let normalSet: WaterfallDataSet = new WaterfallDataSet(values, '');
    normalSet.setYAxisSegmentationColors(greyHighlightList)
    normalDataSets.add(normalSet);
  }

  /**
   * 未超过半小时的情况，坐标从0-23，24根柱子，24.01为右边界
   *
   * @param powerData 查询的接口数据
   * @param dataSets 柱子数据集合
   */
  private doWholeHourIndex(powerData: DeviceUsageHistory[], dataSets: JArrayList<IBarDataSet>) {
    let normalDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    LogUtil.info(`${TAG} doWholeHourIndex`);
    let allScreenOnTime = 0;
    let allScreenOffTime = 0;
    for (let i = 0; i < this.allIndexCount; i += 2) {
      if (i >= powerData.length || i + 1 >= powerData.length) {
        LogUtil.warn(`${TAG} doWholeHourIndex index [${i}] out bounds, powerData length: ${powerData.length}`);
        break;
      }
      let x: number = Math.floor(i / 2);
      let screenOnTime: number =
        Math.round((powerData[i].screenOnTime + powerData[i + 1].screenOnTime) / PER_MIN_IN_MILLIS);
      let screenOffTime: number =
        Math.round((powerData[i].screenOffActivityTime + powerData[i + 1].screenOffActivityTime) / PER_MIN_IN_MILLIS);
      this.indexAndTimes.set(x, {
        screenOnTime: screenOnTime,
        screenOffTime: screenOffTime
      });
      allScreenOnTime += screenOnTime;
      allScreenOffTime += screenOffTime;
      this.addOneBar(normalDataSets, dataSets, x, screenOnTime, screenOffTime);
    }
    this.addOneBar(normalDataSets, dataSets, 24, 0, 0);
    // 作为右边界的柱子，用于触发刷新全图
    this.addOneBar(normalDataSets, dataSets, BATTERY_BAR_END_INDEX, 0, 0);
    this.normalAllDataSets = normalDataSets;
    this.allDataSets = dataSets;
    let data: DeviceTime = { screenOnTime: allScreenOnTime, screenOffTime: allScreenOffTime };
    EventBus.getInstance().emit(SCREEN_ON_TIME_EVENT, data);
    this.allDeviceTimeData = data;
  }

  /**
   * 超过半小时的柱状图处理，首尾为半小时柱子，25个柱子
   *
   * @param powerData 电量使用信息
   * @param values 柱状图数据信息
   */
  private doSpecialHalfHourIndex(powerData: DeviceUsageHistory[], dataSets: JArrayList<IBarDataSet>) {
    let normalDataSets: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    LogUtil.info(`${TAG} doSpecialHalfHourIndex`);
    // 计算亮灭屏活动总时长
    let allScreenOnTime: number = 0;
    let allScreenOffTime: number = 0;
    let screenOnTime: number = 0;
    let screenOffTime: number = 0;
    for (let i = 0; i < powerData.length; i += (i === 0) ? 1 : 2) {
      if (i === 0) {
        screenOnTime = Math.round(powerData[i].screenOnTime / PER_MIN_IN_MILLIS);
        screenOffTime = Math.round(powerData[i].screenOffActivityTime / PER_MIN_IN_MILLIS);
        this.indexAndTimes.set(0, {
          screenOnTime: screenOnTime,
          screenOffTime: screenOffTime
        });
        this.addOneBar(normalDataSets, dataSets, 0, screenOnTime, screenOffTime);
      } else {
        if (i >= powerData.length || i + 1 >= powerData.length) {
          LogUtil.warn(`${TAG} doSpecialHalfHourIndex index [${i}] out bounds, powerData length: ${powerData.length}`);
          break;
        }
        let x: number = Math.floor(i / 2) + 1;
        screenOnTime = Math.round((powerData[i].screenOnTime + powerData[i + 1].screenOnTime) / PER_MIN_IN_MILLIS);
        screenOffTime =
          Math.round((powerData[i].screenOffActivityTime + powerData[i + 1].screenOffActivityTime) / PER_MIN_IN_MILLIS);
        this.indexAndTimes.set(x, {
          screenOnTime: screenOnTime,
          screenOffTime: screenOffTime
        });
        this.addOneBar(normalDataSets, dataSets, x, screenOnTime, screenOffTime);
      }
      allScreenOnTime += screenOnTime;
      allScreenOffTime += screenOffTime;
    }
    // 处理最后半小时数据，也就是47所在的数据
    screenOnTime = Math.round(powerData[powerData.length - 1].screenOnTime / PER_MIN_IN_MILLIS);
    screenOffTime = Math.round(powerData[powerData.length - 1].screenOffActivityTime / PER_MIN_IN_MILLIS);
    this.indexAndTimes.set(24, {
      screenOnTime: screenOnTime,
      screenOffTime: screenOffTime
    });
    this.addOneBar(normalDataSets, dataSets, 24, screenOnTime, screenOffTime);
    // 作为右边界的柱子，用于触发刷新全图
    this.addOneBar(normalDataSets, dataSets, BATTERY_BAR_END_INDEX, 0, 0);
    allScreenOnTime += screenOnTime;
    allScreenOffTime += screenOffTime;
    let data: DeviceTime = { screenOnTime: allScreenOnTime, screenOffTime: allScreenOffTime };
    EventBus.getInstance().emit(SCREEN_ON_TIME_EVENT, data);
    this.allDeviceTimeData = data;
    this.normalAllDataSets = normalDataSets;
    this.allDataSets = dataSets;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getDataFromDatabase();
    this.axisRight?.setDrawGridLinesBehindData(true);
    this.batteryChart = new WaterfallChartModel();
    this.batteryChart.getAxisRight()?.setMinWidth(0);
    this.batteryChart.getAxisRight()?.setMaxWidth(20);
    // X轴
    this.bottomAxis = this.batteryChart.getXAxis();
    this.setBottomAxisConfig();
    // Y轴
    this.axisLeft = this.batteryChart.getAxisLeft();
    this.axisRight = this.batteryChart.getAxisRight();
    this.setYAxisConfig();
    // 图例
    this.batteryChart?.getLegend()?.setEnabled(false);
    this.chartLegend = this.batteryChart.getLegend();
    this.chartLegend?.setForm(LegendForm.LINE);
    this.chartLegend?.setVerticalAlignment(LegendVerticalAlignment.TOP);
    this.chartLegend?.setHorizontalAlignment(LegendHorizontalAlignment.RIGHT);
    this.chartLegend?.setXOffset(15);
    this.chartLegend?.setEnabled(false);
    // 图表描述
    this.chartDescription = this.batteryChart.getDescription();
    this.chartDescription?.setEnabled(false);
    this.batteryChart.setDrawGridBackground(false) // 不绘制背景
    this.batteryChart.getDescription()?.setEnabled(false);
    this.setBatteryChartConfig();
    EventBus.getInstance().on(SELECT_CONSUMPTION_CHART_SEGMENT_EVENT, this.onConsumptionChangedCallback);
    EventBus.getInstance().on(SELECT_CONSUMPTION_CHART_ALL_EVENT, this.onConsumptionAllCallback);
    this.powerDataState.registerCommonEvent();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(SELECT_CONSUMPTION_CHART_SEGMENT_EVENT, this.onConsumptionChangedCallback);
    EventBus.getInstance().detach(SELECT_CONSUMPTION_CHART_ALL_EVENT, this.onConsumptionAllCallback);
    this.powerDataState.unRegisterCommonEvent();
  }

  /**
   * 设置图表左右两边的Y轴样式
   */
  private setYAxisConfig() {
    this.axisRight?.setSpaceTop(60);
    this.axisLeft?.setDrawAxisLine(true);
    this.axisRight?.setDrawAxisLine(true);
    // 不展示y轴线和网格线
    this.axisRight?.setDrawGridLines(true);
    this.axisRight?.setDrawGridLinesBehindData(true);
    this.axisRight?.setGridColor(this.greyColorNumber);
    // 设置y轴粒度，100除以4个网格线，粒度为25
    this.axisRight?.setGranularity(this.middleNumber);
    this.axisRight?.setAxisLineColor(Color.Transparent)
    this.axisRight?.setAxisMinimum(this.smallStartNumber);
    // 因为虚线要往上延一小段，所以最大值设为102
    this.axisRight?.setAxisMaximum(this.maxEndNumber);
    // 设置标签只在右边展示
    this.axisRight?.setEnabled(true);
    this.axisRight?.setDrawLabels(true);
    // 设置y轴标签的横向偏移量
    this.axisRight?.setXOffset(1);
    this.axisRight?.setTextColor(this.greyColorNumber);
    this.axisRight?.setValueFormatter({
      getFormattedValue: (value, axis) => {
        let minuteStr: string = ResourceUtil.getPluralStringByNameSync('time_minute', value);
        return (value === 30 || value === 60) ? minuteStr : '';
      },
    });

    // 设置最上面横线的样式
    this.axisLeft?.setEnabled(true);
    this.axisLeft?.setDrawAxisLine(false);
    this.axisLeft?.setDrawGridLines(false);

    this.axisLeft?.setDrawLabels(false);
    this.axisLeft?.setAxisMinimum(this.smallStartNumber);
    this.axisLeft?.setAxisMaximum(this.maxEndNumber);
    this.axisLeft?.setGranularity(this.middleNumber);

    // 设置最上面横线的样式
    let limitLine = new LimitLine(60);
    limitLine.setLineColor(this.greyColorNumber);
    limitLine.setLineWidth(1);
    this.axisLeft?.addLimitLine(limitLine);
  }

  private setBatteryChartConfig() {
    this.batteryChart?.setExtraTopOffset(500);
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    this.batteryChart?.setMaxVisibleValueCount(0);
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    this.batteryChart?.setVisibleXRangeMaximum(BATTERY_BAR_END_INDEX);
    // 设置延长线
    this.batteryChart?.setYAxisExtensionLine(true);
    // 禁用手指滑动结束时显示高亮效果
    this.batteryChart?.setHighlightPerDragEnabled(false);
    // 禁用拖拽
    this.batteryChart?.setDragEnabled(false);
    // 禁用缩放
    this.batteryChart?.setScaleEnabled(false);
    // // 重写表格的Highlighter方法，在计算最近的点击坐标时，取x坐标的差值的绝对值的最小值 保证横向滑动时坐标点位置触发的流畅性
    this.batteryChart?.setHighlighter(new HwChartHighlighter(this.batteryChart));
    // 设置最小偏移量为0，下面的偏移量设置才会生效
    this.batteryChart?.setMinOffset(this.smallStartNumber);
    // 设置偏移量,类似于内边距
    this.batteryChart?.setExtraOffsets(0, 10, 15, 10);
    // 禁用长按高亮
    this.batteryChart?.setHighlightPerLongPressEnabled(false);
    // 图表注册操作事件
    this.batteryChart?.setOnChartValueSelectedListener(this.valueSelectedListener);
    this.batteryChart?.setRenderer(new CustomBarChartRender(this.batteryChart, this.batteryChart.getAnimator()!,
      this.batteryChart.getViewPortHandler()))
  }

  /**
   * 设置图表底部X轴和日期分割竖线
   */
  private setBottomAxisConfig() {
    // 设置X轴的文字在底部
    this.bottomAxis?.setPosition(XAxisPosition.BOTTOM);
    // 是否x轴线
    this.bottomAxis?.setDrawAxisLine(true);
    this.bottomAxis?.setYOffset(3);
    // 是否绘制纵向网格线
    this.bottomAxis?.setDrawGridLines(false);
    // 设置左边界
    this.bottomAxis?.setAxisMinimum(this.smallStartNumber);
    // 设置右边界
    this.bottomAxis?.setAxisMaximum(this.chartMaxIndex);
    this.bottomAxis?.setAxisMaxLabels(this.allIndexCount);
    this.bottomAxis?.setLabelCount(this.allIndexCount);
    this.bottomAxis?.setTextColor(this.greyColorNumber);
    this.bottomAxis?.setAxisLineColor(this.greyColorNumber);
    // 计算左右两边点的时间戳
    this.timeInMillis = this.getNearByTimeMillis();
    this.chartMinTime = this.timeInMillis - this.chartMaxIndex * this.oneHourMillis;
    // 计算中间的日期刻度点
    const dateIndex = (new Date(this.timeInMillis).setHours(0, 0, 0, 0) - this.chartMinTime) / this.oneHourMillis;
    this.bottomAxis?.setValueFormatter({
      getFormattedValue: (value, axis) => {
        if (value === 0) {
          if (dateIndex >= this.xAxisLeftShowBoundaries) {
            return TimeUtil.obtainFormatTime(new Date(this.timeInMillis), TimeFormat.HOUR_MINUTE_SHORT);
          }
        } else if (value === dateIndex) {
          return TimeUtil.obtainFormatTime(new Date(this.timeInMillis), TimeFormat.MONTH_DAY_NUMERIC);
        } else if (value === this.chartMaxIndex) {
          if (dateIndex <= this.xAxisRightShowBoundaries) {
            return TimeUtil.obtainFormatTime(new Date(this.timeInMillis), TimeFormat.HOUR_MINUTE_SHORT);
          }
        }
        return '';
      },
    });
    // 清空原先的
    this.bottomAxis?.removeAllLimitLines();
    // 最左边的刻度
    let leftLine = new LimitLine(this.smallStartNumber);
    leftLine.setLineWidth(this.lineWidth);
    leftLine.setLineColor(this.greyColorNumber);
    leftLine.enableDashedLine(4, 2, 0);
    this.bottomAxis?.addLimitLine(leftLine);
    // 中间日期刻度
    let midLine = new LimitLine(dateIndex);
    midLine.setLineWidth(this.lineWidth);
    midLine.setLineColor(this.greyColorNumber);
    midLine.enableDashedLine(4, 2, 0);
    this.bottomAxis?.addLimitLine(midLine);
    // 最右边的刻度
    let rightLine = new LimitLine(this.chartMaxIndex);
    rightLine.setLineWidth(this.lineWidth);
    rightLine.setLineColor(this.greyColorNumber);
    rightLine.enableDashedLine(4, 2, 0);
    this.bottomAxis?.addLimitLine(rightLine);
    this.bottomAxis?.setAvoidFirstLastClipping(true)
  }

  /**
   * 获取 X轴最右端的时间点对应的时间戳
   *
   * @returns 时间戳
   */
  private getNearByTimeMillis(): number {
    let calendar = new Date();
    let min = calendar.getMinutes();
    // 选上一个整点或者半点
    calendar.setMinutes(min < 30 ? 0 : 30);
    calendar.setSeconds(0);
    calendar.setMilliseconds(0);
    // X轴最右端的时间点对应的时间戳
    return calendar.getTime();
  }

  build() {
    Column() {
      BarChart({
        model: this.batteryChart,
      })
        .width('100%')
        .height('158vp')
    }
  }
}

/**
 * 重写高亮效果
 */
export class HwChartHighlighter extends ChartHighlighter<BarChartModel> {
  constructor(chart: BarChartModel) {
    super(chart);
  }

  // 按像素获取最接近的高亮显示
  getClosestHighlightByPixel(closestValues: JArrayList<Highlight>, x: number, y: number,
    axis: AxisDependency, minSelectionDistance: number): Highlight | null {
    let closest: Highlight | null = null;
    let distance = minSelectionDistance;
    for (let i = 0; i < closestValues.size(); ++i) {
      const high = closestValues.get(i);
      if (!axis || high.getAxis() === axis) {
        // 此处重写修改距离点击点最近的x坐标，作为点击事件的响应坐标
        const cDistance = Math.abs(x - high.getXPx());
        if (cDistance < distance) {
          closest = high;
          distance = cDistance;
        }
      }
    }
    return closest;
  }
}
