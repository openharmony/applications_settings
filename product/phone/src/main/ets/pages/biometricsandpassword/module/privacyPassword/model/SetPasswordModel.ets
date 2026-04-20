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

import settings from '@ohos.settings';
import { common } from '@kit.AbilityKit';
import Log from '../common/utils/Log';

/* instrument ignore file */
const TAG = 'SetPasswordModel';
const PRIVATE_PASSWORD_PROTECT = 'private_password_protect';

export default class SetPasswordModel {
  public static getPasswordProtectQuestion(context: common.Context): string {
    Log.info(TAG, `start get password protect question`);
    let res = settings.getValueSync(context, PRIVATE_PASSWORD_PROTECT, '', settings.domainName.USER_SECURITY);
    if (!res) {
      Log.error(TAG, `get password protect question failed`);
      return '';
    }
    return res;
  }
}