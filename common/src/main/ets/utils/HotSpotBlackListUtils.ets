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

import wifiManager from '@ohos.wifiManager';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { LogUtil } from './LogUtil';

const TAG: string = 'HotSpotBlackListUtils : ';

/**
 * 个人热点黑名单工具类
 *
 * @since 2024-04-12
 */
export class HotSpotBlackListUtils {

  /**
   * 将指定设备移出热点黑名单
   *
   * @param station 待移出热点黑名单的设备
   */
  static deleteFromBlackList(station: wifiManager.StationInfo): void {
    if (!station) {
      LogUtil.error(`${TAG} deleteFromBlackList failed, station is undefined.`);
      return;
    }
    LogUtil.info(`${TAG} deleteFromBlackList station: ${station.name}`);
    try {
      return wifiManager.delHotspotBlockList(station);
    } catch (error) {
      LogUtil.error(`${TAG} deleteFromBlackList failed: ${error?.message}`);
    }
  }

  /**
   * 获取个人热点黑名单数据
   *
   * @param isRemoveBlockList true 移出黑名单 false 加入黑名单
   * @param macAddress 待处理的设备mac
   * @returns 设备信息
   */
  static getStationByMac(isRemoveBlockList: boolean, macAddress: string): wifiManager.StationInfo | undefined {
    if (CheckEmptyUtils.isEmpty(macAddress)) {
      LogUtil.error(`${TAG} getStationByIp failed, macAddress is empty.`);
      return undefined;
    }
    try {
      let list: undefined | Array<wifiManager.StationInfo> = undefined;
      if (isRemoveBlockList) {
        list = wifiManager.getHotspotBlockList();
      } else {
        list = wifiManager.getStations();
      }
      if (!list) {
        LogUtil.error(`${TAG} station list is empty.`);
        return undefined;
      }
      let station = list.find((item) => item.macAddress === macAddress);
      if (!station) {
        LogUtil.error(`${TAG} find station failed.`);
      }
      return station;
    } catch (error) {
      LogUtil.error(`${TAG} getStationByIp failed: ${error?.message}`);
      return undefined;
    }
  }

  /**
   * 获取个人热点黑名单数据
   *
   * @returns 黑名单数据
   */
  static getBlockList(): Array<wifiManager.StationInfo> {
    try {
      let list: wifiManager.StationInfo[] = wifiManager.getHotspotBlockList();
      LogUtil.info(`${TAG} getBlockList, length is :${list.length}`);
      return list;
    } catch (error) {
      LogUtil.error(`${TAG} getBlockList failed: ${error?.message}`);
      return [];
    }
  }

  /**
   * 添加至热点黑名单
   *
   * @param station 待添加的设备
   */
  static addToBlockList(station: wifiManager.StationInfo): void {
    if (!station) {
      LogUtil.error(`${TAG} addToBlockList failed, station is undefined.`);
      return;
    }
    LogUtil.info(`${TAG} addToBlockList station: ${station.name}`);
    try {
      return wifiManager.addHotspotBlockList(station);
    } catch (error) {
      LogUtil.error(`${TAG} addToBlockList failed: ${error?.message}`);
    }
  }
}