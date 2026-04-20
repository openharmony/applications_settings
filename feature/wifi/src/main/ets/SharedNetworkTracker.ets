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

// import lazy { default as networkSharing } from '@hms.collaboration.networksharing';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'SharedNetworkTracker';

export class SharedNetworkTracker {

  constructor() {
  }

  // async getDeviceInfos(): Promise<networkSharing.DeviceInfo[]> {
  //   try {
  //       return await networkSharing.getDeviceInfos();
  //   } catch (error) {
  //       LogUtil.error(`${TAG} getDeviceInfos error: ${error?.message}`);
  //   }
  //   return [];
  // }

  startConnect(networkId: string): void {
    try {
      // networkSharing.connect(networkId);
    } catch (error) {
       LogUtil.error(`${TAG} start connect error: ${error?.message}`);
    }
  }

  deleteConnect(networkId: string): void {
    try {
      // networkSharing.disconnect(networkId);
    } catch (error) {
      LogUtil.error(`${TAG} delete connect error: ${error?.message}`);
    }
  }
}

export let sharedNetworkTracker = new SharedNetworkTracker();