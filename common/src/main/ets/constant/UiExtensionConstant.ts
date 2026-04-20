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

/**
 * UIExtensionCompoment 常量定义
 */
export class UiExtensionConstant {
  // OnExtensionDied（异常退出，如kill crash等），通过OnRelease返回1
  public static readonly ON_EXTENSION_DIED: number = 1;

  // OnDisconnect（正常退出，由提供方主动调用），通过OnRelease返回0
  public static readonly ON_DISCONNEC: number = 0;

  // OnExtensionDied（异常退出，如kill crash等），onerror返回100014
  public static readonly ONERROR_EXTENSION_DIED: number = 100014;

  // Lifecycle Timeout（生命周期超时），onerror返回100015
  public static readonly ONERROR_LIFECYCLE_TIMEOUT: number = 100015;

  // 拉起前台失败(参数错误、拉起失败等等)，onerror返回100018
  public static readonly ONERROR_START_FOREGROUND_FAILED: number = 100018;

  // 异常退出后重新拉起次数
  public static readonly REFRESH_TIMES: number = 1;

  /**
	 * 判断是否是异常退出需要重新拉起
	 *
	 * @param code 返回编码
	 * @returns boolean
	 */
  public static isExceptionExit(code: number): boolean {
    return code === this.ONERROR_EXTENSION_DIED || code === this.ONERROR_LIFECYCLE_TIMEOUT ||
			code === this.ONERROR_START_FOREGROUND_FAILED;
  }
}