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
  HiSysEventUtil,
  CommonInterfaceCallFaultParams
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';

const SCHEDULED_POWER_FAULT_CATEGORY = 'ScheduledPowerFault';

/**
 * 创建Timer异常
 */
export const FAULT_TYPE_CREATE_TIMER: string = 'CREATE_TIMER_FAULT';

/**
 * 销毁Timer异常
 */
export const FAULT_TYPE_DESTROY_TIMER: string = 'DESTROY_TIMER_FAULT';

/**
 * 通话中取消当前定时关机任务
 */
export const FAULT_TYPE_SCHEDULED_SHUTDOWN_FAILED: string = 'SCHEDULED_SHUTDOWN_FAILED_FAULT';

/**
 * 定时开关机场景打点工具类
 *
 * @since 2025-04-29
 */
export class ScheduledPowerOffSysEventUtil {
  /**
   * 上报错误打点
   *
   * @param faultType 错误类型
   * @param faultInfo 错误信息
   */
  public static reportFailureEvent(faultType: string, faultInfo: string): void {
    let params: CommonInterfaceCallFaultParams = {
      FAULT_CATEGORY: SCHEDULED_POWER_FAULT_CATEGORY,
      FAULT_SUBCATEGORY: faultType,
      FAULT_INFO: faultInfo
    };
    HiSysEventUtil.reportFaultEvent(HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME, params,
      HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME);
  }
}