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
import { PreferencesKey } from '../constant/PreferencesKey';
import { Response } from '../constant/Response';
import { CallMessage, IService } from '../stub/BaseServiceStub';
import { LogUtil } from '../utils/LogUtil';
import { PreferencesUtil } from '../utils/PreferencesUtil';

/* instrument ignore file */
const DISABLE_MENU: string = 'disableMenu';
const DISABLE_URI_PARAM: string = 'disableUriParam';
const TAG: string = 'DisableMenuService';

export class DisableItemService implements IService {
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
    if (method === DISABLE_MENU) {
      this.disableItemService(message);
    } else if (method === DISABLE_URI_PARAM) {
      this.disableUriParam(message);
    } else {
      LogUtil.showWarn(TAG, 'onCall invalid method');
      return Response.INVALID_METHOD;
    }

    return Response.SUCCESS;
  }

  disableItemService(message: CallMessage): void {
    let itemKey: Record<string, boolean> = message?.extra as Record<string, boolean>;
    let items: string[] = [];
    Object.keys(itemKey).forEach((item) => {
      PreferencesUtil.putSync(item, itemKey[item]);
      items.push(item);
      LogUtil.showInfo(TAG, `disableItemService item: ${item}, enable: ${itemKey[item]}`);
    })
    PreferencesUtil.putSync(PreferencesKey.DISABLE_ITEMS, items);
  }

  // 用于处理演示样机对外部输入菜单项置灰
  disableUriParam(message: CallMessage): void {
    let uriParams: Record<string, Record<string, boolean>> = message?.extra as Record<string, Record<string, boolean>>;
    Object.keys(uriParams).forEach((uriParam) => {
      LogUtil.showInfo(TAG, `disableUriParam uri: ${uriParam}`);
      PreferencesUtil.put(uriParam, uriParams[uriParam]);
    })
  }
}