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
} from '../systemEvent/HiSysEventUtil';

const COMMON_FAILED_FAULT_CATEGORY = 'CommonFailedFault';

/**
 * 返回账户头像异常
 */
export const FAULT_TYPE_ACCOUNT_AVATAR: string = 'ACCOUNT_AVATAR_FAULT';

export class CommonFailedEventUtils {
  /**
   * 上报错误打点
   *
   * @param faultType 错误类型
   * @param faultInfo 错误信息
   */
  public static reportFailureEvent(faultType: string, faultInfo: string): void {
    let params: CommonInterfaceCallFaultParams = {
      FAULT_CATEGORY: COMMON_FAILED_FAULT_CATEGORY,
      FAULT_SUBCATEGORY: faultType,
      FAULT_INFO: faultInfo
    };
    HiSysEventUtil.reportFaultEvent(HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME, params,
      HiSysEventUtil.COMMON_INTERFACE_CALL_FAULT_EVENT_NAME);
  }
}