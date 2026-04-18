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

import worker from '@ohos.worker';
import { LogUtil } from './LogUtil';
import { Constants } from '../constant/PackagesConstant';
import { FileValidator } from './Validator';
import { DeviceUtil } from './BaseUtils';

const TAG = 'ThreadWorkerUtil: ';
const CURRENT_DEVICE_TYPE = DeviceUtil.deviceType;
const PHONE_WORKER_ENTRY_NAME: string = 'phone_settings/ets/workers/';
const PC_WORKER_ENTRY_NAME: string = 'pc_settings/ets/workers/';

/**
 * Worker线程工具类
 */
export class ThreadWorkerUtil {
  /**
   * 创建worker线程实例
   * @param workerFile worker.ts文件名称
   *
   * @returns worker线程实例
   */
  public static createWorker(workerFile: string): worker.ThreadWorker | null {
    if (!FileValidator.validateWorkerFile(workerFile)) {
      LogUtil.error(`${TAG} create worker failed, invalid worker file: ${workerFile}`);
      return null;
    }
    LogUtil.info(`${TAG} create worker, relativePath: ${workerFile}, device type: ${CURRENT_DEVICE_TYPE}`);
    let workerEntryName = CURRENT_DEVICE_TYPE === Constants.DEVICE_TYPE_2IN1 ? PC_WORKER_ENTRY_NAME
      : PHONE_WORKER_ENTRY_NAME;
    let workerInstance: worker.ThreadWorker | null = null;
    try {
      workerInstance = new worker.ThreadWorker(workerEntryName + workerFile);
    } catch (err) {
      LogUtil.error(`${TAG} create worker instance failed: ${err?.message}`);
    }
    return workerInstance as worker.ThreadWorker;
  }

  /**
   * 销毁worker线程
   * @param worker: worker.ThreadWorker
   */
  public static terminateWorker(worker: worker.ThreadWorker): void {
    LogUtil.info(`${TAG} terminate worker`);
    if (!worker) {
      LogUtil.error(`${TAG} worker is null`);
      return;
    }
    try {
      worker.terminate();
    } catch (err) {
      LogUtil.error(`${TAG} worker terminate error: ${err?.message}`);
    }
  }
}