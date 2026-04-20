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

import sim from '@ohos.telephony.sim';
import { CARD_NUM_ZERO } from '../constant/SimConstant';
import { LogUtil } from './LogUtil';

const TAG = 'SimUtils: ';

export class SimUtils {
  private static firstIsWithCardSlot: boolean = true;
  private static cardSlotNum: number = 0;

  /**
   * 获取卡槽数
   */
  public static getCardSlotNum(): number {
    if (SimUtils.firstIsWithCardSlot) {
      try {
        SimUtils.cardSlotNum = sim.getMaxSimCount();
        LogUtil.info(`${TAG} getCardSlotNum cardSlotNum ${SimUtils.cardSlotNum}`);
      } catch (error) {
        LogUtil.error(`${TAG} getMaxSimCount error: ${error?.code} message: ${error?.message}`);
      }
    }
    return SimUtils.cardSlotNum;
  }

  /**
   * 遍历设备是否插入了sim卡
   */
  public static hasSimCard(): boolean {
    let simCount = SimUtils.getCardSlotNum();
    if (simCount === 0) {
      LogUtil.info(`${TAG} has no sim card`);
      return false;
    }
    for (let slotId = 0; slotId < simCount; slotId++) {
      if (sim.hasSimCardSync(slotId)) {
        LogUtil.info(`${TAG} ${slotId} has sim card`);
        return true;
      }
    }
    return false;
  }

  /**
   * 指定卡槽是否有sim卡
   */
  public static hasSimCardSync(slotId: number): boolean {
    try {
      if (sim.hasSimCardSync(slotId)) {
        LogUtil.info(`${TAG} ${slotId} has sim card`);
        return true;
      }
    } catch (error) {
      LogUtil.error(`${TAG} hasSimCardSync error: ${error?.code} message: ${error?.message}`);
    }
    return false;
  }

  /**
   * 设备是否支持sim卡
   */
  public static isSupportSim(): boolean {
    try {
      let simCount = SimUtils.getCardSlotNum();
      if (simCount > CARD_NUM_ZERO) {
        LogUtil.info(`${TAG} sim.getMaxSimCount number is ${simCount}`);
        return true;
      }
    } catch (err) {
      LogUtil.error(`${TAG} sim.getMaxSimCount err ${err?.code} message: ${err?.message}`);
    }
    return false;
  }

  /**
   * 指定卡槽卡是否激活
   */
  public static isSimActivating(slotId: number): boolean {
    try {
      let isActivated: boolean = sim.isSimActiveSync(slotId);
      return isActivated;
    } catch (err) {
      LogUtil.error(`${TAG} sim.isSimActive err ${err?.code} message: ${err?.message}`);
    }
    return false;
  }

  /**
   * 根据卡槽位置获取SIM卡具体信息
   *
   * @param slotId 卡槽位置
   * @returns 对应卡槽位置的SIM卡信息
   */
  public static getSimLabel(slotId: number): sim.SimLabel | undefined {
    if (!SimUtils.isValidSlotId(slotId)) {
      LogUtil.showError(TAG, `getSimLabel invalid slot id: ${slotId}!`)
      return undefined;
    }
    try {
      let start = new Date().getTime();
      let label: sim.SimLabel = sim.getSimLabelSync(slotId);
      let end = new Date().getTime();
      LogUtil.showInfo(TAG,
        `getSimLabel slotId ${slotId}, res simType: ${label.simType} index: ${label.index}, cost ${end - start}ms`);
      return label;
    } catch (err) {
      LogUtil.showError(TAG, `getSimLabel err, code: ${err?.code}, message: ${err?.message}`);
    }
    return undefined;
  }

  /**
   * 检查是否为有效的slotId
   *
   * @param slotId 卡槽索引
   * @returns true: 有效, false: 无效
   */
  public static isValidSlotId(slotId: number): boolean {
    return slotId >= 0 && slotId < SimUtils.getCardSlotNum();
  }
}