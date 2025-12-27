/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { AsyncCallback, BusinessError } from '@ohos.base';

export namespace intelligentscene {

  loadLibrary("intelligentscene_ani.z");

  native function isDoNotDisturbEnabled_inner(): boolean;

  native function isNotifyAllowedInDoNotDisturb_inner(): boolean;

  export function isDoNotDisturbEnabled(callback: AsyncCallback<boolean>): void {
    taskpool.execute((): boolean => {
      return isDoNotDisturbEnabled_inner();
    })
      .then((ret: boolean): void => {
        callback(null, ret);
      })
      .catch((ret: BusinessError): void => {
        let data: boolean;
        callback(ret, data);
      });
  }

  export function isDoNotDisturbEnabled(): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return isDoNotDisturbEnabled_inner();
      })
        .then((ret: boolean): void => {
          resolve(ret);
        })
        .catch((ret: BusinessError): void => {
          reject(ret);
        });
    });
  }

  export function isNotifyAllowedInDoNotDisturb(callback: AsyncCallback<boolean>): void {
    taskpool.execute((): boolean => {
      return isNotifyAllowedInDoNotDisturb_inner();
    })
      .then((ret: boolean): void => {
        callback(null, ret);
      })
      .catch((ret: BusinessError): void => {
        let data: boolean;
        callback(ret, data);
      });
  }

  export function isNotifyAllowedInDoNotDisturb(): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return isNotifyAllowedInDoNotDisturb_inner();
      })
        .then((ret: boolean): void => {
          resolve(ret);
        })
        .catch((ret: BusinessError): void => {
          reject(ret);
        });
    });
  }
}