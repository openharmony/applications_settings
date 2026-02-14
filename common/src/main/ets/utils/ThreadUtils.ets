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

import { process } from '@kit.ArkTS';

/**
 * 线程工具类
 */
export class ThreadUtils {
  /**
   * 当前进程ID
   */
  public static processId: number = process.pid;
  /**
   * 当前线程ID
   */
  public static threadId: number = process.tid;

  /**
   * 当前是否主线程
   *
   * @returns 是否主线程
   */
  public static isMainThread(): boolean {
    return ThreadUtils.processId === ThreadUtils.threadId;
  }
}