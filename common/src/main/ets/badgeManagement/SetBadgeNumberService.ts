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

import { Response } from '../constant/Response';
import type { CallMessage, IService } from '../stub/BaseServiceStub';
import { LogUtil } from '../utils/LogUtil';
import { BadgeManagement } from './BadgeManagement';

/* instrument ignore file */
const SET_BADGE_NUMBER: string = 'setBadgeNumber';
const TAG: string = 'SetBadgeNumberService';

export class SetBadgeNumberService implements IService {

  async onCall(json: string): Promise<string> {
    let message: CallMessage;
    try {
      message = JSON.parse(json) as CallMessage;
    } catch (err) {
      LogUtil.showError(TAG, 'parse input message invalid');
      return Response.UNKNOWN_METHOD;
    }
    const method: string = message?.method;
    LogUtil.showInfo(TAG, `onCall method = ${method}`);
    if (method !== SET_BADGE_NUMBER) {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      return Response.INVALID_METHOD;
    }

    let badgeNumber = message?.extra as Number;
    LogUtil.showInfo(TAG, `onCall badgeNumber = ${badgeNumber}`);
    let result: boolean = await BadgeManagement.setBadgeNumber(badgeNumber as number);
    LogUtil.showInfo(TAG, `success set badgeNumber = ${badgeNumber}`);

    return result ? Response.SUCCESS : Response.FAIL;
  }
}