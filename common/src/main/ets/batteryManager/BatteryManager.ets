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

import common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
// import xPowerManager from '@hms.xpower';
import { BusinessError } from '@ohos.base';
import BatteryListDataManager from '../data/BatteryListDataManager';
import { DateTimeUtil } from '../utils/DateTimeUtil';
import { LogUtil } from '../utils/LogUtil';
import { PreferencesUtil } from '../utils/PreferencesUtil';
import BatteryHistoryManager from '../data/BatteryLineDataManager';
import DeviceUsageManager from '../data/DeviceUsageDataManager';

const TAG: string = 'BatteryManager:';
const LAST_APP_POWER_DATA_TIME: string = 'LastAppPowerDataTime';

export class PowerInfo {
  /**
   * 描述信息 时间段
   */
  public desc: string = '';
  /**
   * 开始时间 格式：HH:mm
   */
  public startTimeDesc = '';
  /**
   * 结束时间 格式：HH:mm
   */
  public endTimeDesc = '';
}

export class BatteryManager {
  // private static getWantInfo(): xPowerManager.AppPowerDataReq {
  //   let endTimestamp: number = DateTimeUtil.getPassTimestamp();
  //   let startTimestamp: number = endTimestamp - DateTimeUtil.getPerDayInMillis();
  //   LogUtil.info(`${TAG} getWantInfo. startTimestamp:${startTimestamp} endTimestamp:${endTimestamp}`);
  //   // xPowerManager getBatteryData 入参
  //   let wantInfo: xPowerManager.AppPowerDataReq = {
  //     start: startTimestamp,
  //     end: endTimestamp,
  //     charge: 1,
  //     interval: 30
  //   };
  //   return wantInfo;
  // }

  /**
   * 获取24小时内应用耗电信息
   */
  static getAppPowerDataFun(context: common.Context): void {
    // let wantInfo: xPowerManager.AppPowerDataReq = BatteryManager.getWantInfo();
    // LogUtil.info(`${TAG} getAppPowerDataFun start.`);
    // xPowerManager.getAppPowerData(wantInfo).then((data: xPowerManager.AppPowerDataReply) => {
    //   LogUtil.info(`${TAG} getAppPowerDataFun success. length:${data?.appDatas?.length}`);
    //   BatteryManager.getAppPowerData(data, context);
    // }).catch((err: BusinessError) => {
    //   LogUtil.info(`${TAG} getAppPowerDataFun fail. message:${err?.message}`);
    // });
  }

  /**
   * 获取手机24小时内应用亮灭屏信息
   */
  static getAppPowerDataFunForPhone(startTimestamp: number, endTimestamp: number, context: common.Context): void {
    // let wantInfo: xPowerManager.AppPowerDataReq = {
    //   start: startTimestamp,
    //   end: endTimestamp,
    //   charge: 1,
    //   interval: 30
    // };
    // LogUtil.info(`${TAG} getAppPowerDataFunForPhone start.`);
    // xPowerManager.getAppPowerData(wantInfo).then((data: xPowerManager.AppPowerDataReply) => {
    //   LogUtil.info(`${TAG} getAppPowerDataFunForPhone success. length:${data?.appDatas?.length}`);
    //   BatteryManager.getAppPowerData(data, context);
    // }).catch((err: BusinessError) => {
    //   LogUtil.error(`${TAG} getAppPowerDataFunForPhone fail. code:${err?.code} message:${err?.message}`);
    // });
  }

  /**
   * 获取24小时内设备使用信息
   */
  static getDeviceUsageDurationFun(startTimestamp: number, endTimestamp: number, context: common.Context): void {
    // let wantInfo: xPowerManager.DeviceUsageDurationReq = {
    //   start: startTimestamp,
    //   end: endTimestamp,
    //   interval: 30
    // };
    // LogUtil.info(`${TAG} getDeviceUsageDurationFun start.`);
    // xPowerManager.getDeviceUsageDuration(wantInfo).then((data: xPowerManager.DeviceUsageDurationReply) => {
    //   LogUtil.info(`${TAG} getDeviceUsageDurationFun success. length: ${data?.usageDurationDataInfo?.length}`);
    //   BatteryManager.getDeviceUsage(data, context);
    // }).catch((err: BusinessError) => {
    //   LogUtil.error(`${TAG} getDeviceUsageDuration fail. code:${err?.code} message:${err?.message}`);
    // });
  }

  /**
   * 获取24小时内应用耗电信息(在内存中直接统计)
   */
  static async getAppPowerDataFunSync(): Promise<Record<string, string | number>[]> {
    // try {
    //   let wantInfo: xPowerManager.AppPowerDataReq = BatteryManager.getWantInfo();
    //   LogUtil.info(`${TAG} getAppPowerDataFunSync start.`);
    //   let data: xPowerManager.AppPowerDataReply = await xPowerManager.getAppPowerData(wantInfo);
    //   LogUtil.info(`${TAG} getAppPowerDataFunSync success. length:${data?.appDatas?.length}`);
    //   return await BatteryManager.getStatisticPower(data);
    // } catch (err) {
    //   LogUtil.info(`${TAG} getAppPowerDataFunSync fail. message:${err?.message}`);
    // }
    return [];
  }

  /**
   * 对耗电数据在内存中汇总，提高即时获取速度
   */
  // static async getStatisticPower(data: xPowerManager.AppPowerDataReply): Promise<Record<string, string | number>[]> {
  //   let appDataList: Record<string, string | number>[] = [];
  //   if (!data || !data.appDatas || data.appDatas?.length <= 0) {
  //     return appDataList;
  //   }
  //   let maps: Map<string, xPowerManager.AppEnergy> = new Map();
  //   let totalNum: number = 0;
  //   for (let item of data.appDatas) {
  //     if (!item && data.capacity === 0) {
  //       continue;
  //     }
  //     item.appEnergies.forEach((powerItem) => {
  //       totalNum += powerItem.backgroundPower;
  //       totalNum += powerItem.foregroundPower;
  //       let oldItem: xPowerManager.AppEnergy | undefined = maps.get(powerItem.name);
  //       if (oldItem && maps.has(powerItem.name)) {
  //         powerItem.foregroundTime += oldItem.foregroundTime;
  //         powerItem.backgroundTime += oldItem.backgroundTime;
  //         powerItem.backgroundPower += oldItem.backgroundPower;
  //         powerItem.foregroundPower += oldItem.foregroundPower;
  //       }
  //       maps.set(powerItem.name, powerItem);
  //     });
  //   }
  //   maps.forEach((powerInfo) => {
  //     let sum: number = powerInfo.backgroundPower + powerInfo.foregroundPower;
  //     let percentage: number = totalNum === 0 ? 0 : Math.round(sum * 100 / totalNum);
  //     appDataList.push({
  //       'bundleName': powerInfo.name,
  //       'foregroundTime': powerInfo.foregroundTime,
  //       'foregroundPower': powerInfo.foregroundPower,
  //       'backgroundTime': powerInfo.backgroundTime,
  //       'backgroundPower': powerInfo.backgroundPower,
  //       'percentage': percentage
  //     });
  //   });
  //   return appDataList;
  // }

  /**
   * 将接口数据组装成 折线图数据 与 应用耗电列表数据 分别插入到对应数据库表中
   */
  // public static getAppPowerData(data: xPowerManager.AppPowerDataReply, context: common.Context): void {
  //   if (data && data.appDatas?.length > 0) {
  //     let timestamp: ESObject = data.appDatas[data.appDatas.length - 1].timestamp;
  //     LogUtil.info(`${TAG} PreferencesUtil.putPreferencesData. lastTimestamp:${timestamp}`);
  //     let lineData: relationalStore.ValuesBucket[] = [];
  //     let sum: number = 0;
  //     let appEnergyArray: relationalStore.ValuesBucket[] = [];
  //     PreferencesUtil.putPreferencesData(LAST_APP_POWER_DATA_TIME, timestamp, context);
  //     // data.appDatas.forEach(item => {
  //     //   if (!item && data.capacity === 0) {
  //     //     return
  //     //   }
  //     //   lineData.push(BatteryManager.disassemblesLineData(item, data.capacity));
  //     //   sum += item.appEnergies.reduce((prev, curr) => prev + curr.foregroundPower + curr.backgroundPower, 0);
  //     //   appEnergyArray = [...appEnergyArray,
  //     //     ...BatteryManager.disassemblesPowerList(item.appEnergies, sum, item.timestamp)];
  //     // })
  //     BatteryHistoryManager.batchInsertBatteryHistoryData(context, lineData);
  //     BatteryListDataManager.batchInsertBatteryHistoryData(context, appEnergyArray);
  //   }
  // }

  /**
   * 将接口数据组装插入到对应数据库表中
   */
  // public static getDeviceUsage(data: xPowerManager.DeviceUsageDurationReply, context: common.Context): void {
  //   if (data && data.usageDurationDataInfo?.length > 0) {
  //     let lineData: relationalStore.ValuesBucket[] = [];
  //     data.usageDurationDataInfo.forEach(item => {
  //       let deviceUsageData: relationalStore.ValuesBucket = {
  //         timestamp: item.end,
  //         screenOnTime: item.screenOnTime,
  //         screenOffActivityTime: item.screenOffActivityTime,
  //       };
  //       lineData.push(deviceUsageData);
  //     })
  //     DeviceUsageManager.batchInsertDeviceUsageHistoryData(context, lineData);
  //   }
  // }

  /**
   * 组装折线图数据
   */
  // public static disassemblesLineData(data: xPowerManager.AppData, capacity: number): relationalStore.ValuesBucket {
  //   let percentage: number = 0;
  //   if (data.charge === -1 && data.gasGauge === -1) {
  //     percentage = 0;
  //   }
  //   if (data.gasGauge >= capacity) {
  //     percentage = 100;
  //   } else if (data.gasGauge > 0) {
  //     percentage = Math.floor(data.gasGauge * 100 / capacity);
  //   }
  //   let batteryHistoryData: relationalStore.ValuesBucket = {
  //     timestamp: data.timestamp,
  //     percentage: percentage,
  //     charge: data.charge,
  //   };
  //   return batteryHistoryData;
  // }

  /**
   * 组装应用耗电列表数据
   */
  // public static disassemblesPowerList(appEnergies: xPowerManager.AppEnergy[],
  //                                     sum: number, timestamp: number): relationalStore.ValuesBucket[] {
  //   let appEnergyArray: relationalStore.ValuesBucket[] = [];
  //   appEnergies.forEach((appEnergy) => {
  //     let totalPower: number = appEnergy.foregroundPower + appEnergy.backgroundPower;
  //     let percentage: number = sum === 0 ? 0 : Math.round(totalPower * 100 / sum);
  //     let processedAppEnergy: relationalStore.ValuesBucket = {
  //       bundleName: appEnergy.name,
  //       foregroundTime: appEnergy.foregroundTime,
  //       foregroundPower: appEnergy.foregroundPower,
  //       backgroundTime: appEnergy.backgroundTime,
  //       backgroundPower: appEnergy.backgroundPower,
  //       appType: appEnergy.appType ? appEnergy.appType : 0,
  //       totalPower: totalPower,
  //       percentage: percentage,
  //       timestamp: timestamp,
  //     };
  //     appEnergyArray.push(processedAppEnergy);
  //   });
  //   return appEnergyArray;
  // }
}