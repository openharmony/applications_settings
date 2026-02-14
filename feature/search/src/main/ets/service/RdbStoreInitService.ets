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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { CallMessage, IService } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { SearchDataController } from '../controller/SearchController';
import { SettingPageDescController } from '../controller/SettingPageDescController';
/* instrument ignore file */
const INIT_SEARCH_DATA: string = 'initSearchData';
const TAG: string = 'RdbStoreInitService';

export class RdbStoreInitService implements IService {
  async onCall(json: string): Promise<string> {
    let message: CallMessage;
    try {
      message = JSON.parse(json) as CallMessage;
    } catch (err) {
      LogUtil.showError(TAG, 'parse input message invalid');
      return Response.UNKNOWN_METHOD;
    }

    const method: string = message?.method;
    LogUtil.showInfo(TAG, `onCall method = ${method} start`);
    if (method !== INIT_SEARCH_DATA) {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      return Response.INVALID_METHOD;
    }

    DeviceNameUtil.initDeviceName();
    await SearchDataController.initSearchTable();
    await SearchDataController.deleteSearchData();
    await SettingPageDescController.initPageInfoTable();
    await SettingPageDescController.deletePageInfoData();
    await SettingPageDescController.initPageInfoData();
    await SearchDataController.initSearchData();
    LogUtil.showInfo(TAG, `onCall method = ${method} end`);

    return Response.SUCCESS;
  }
}