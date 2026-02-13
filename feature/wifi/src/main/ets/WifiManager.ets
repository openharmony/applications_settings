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

/* instrument ignore file */
const TAG: string = 'WifiManager : ';

/**
 * Wifi 管理工具类
 *
 * @since 2025-07-06
 */
export class WifiManager {
  private static instance: WifiManager;
  private isWifiSecuritySwitchOn: boolean = false;

  /**
   * 获取WifiManager实例
   *
   * @returns WifiManager类对象
   */
  public static getInstance(): WifiManager {
    if (!WifiManager.instance) {
      WifiManager.instance = new WifiManager();
    }
    return WifiManager.instance;
  }

  /**
   * 设置安全开关检测状态
   *
   * @param value 安全开关状态
   */
  public setWifiSecuritySwitchStatus(value: boolean): void {
    this.isWifiSecuritySwitchOn = value;
  }

  /**
   * 获取安全检测开关状态
   *
   * @returns 返回开关是否打开
   */
  public getWifiSecuritySwitchStatus(): boolean {
    return this.isWifiSecuritySwitchOn;
  }

}