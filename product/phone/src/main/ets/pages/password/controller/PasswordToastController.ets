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

import { BusinessError } from '@kit.BasicServicesKit';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

/* instrument ignore file */
const TAG: string = 'PasswordToastController: ';

export class PasswordToastController {
  /**
   * 密码验证失败toast弹框
   *
   */
  static passwordFailToast(result: number): void {
    const tipsString: Resource = result === ResultCode.INVALID_TOKEN ? $r('app.string.fp_timeout_content') :
      $r('app.string.secure_chip_pin_set_fail');
    ResourceUtil.getString(tipsString).then(value => {
      ToastUtil.showToast(value, ToastUtil.SHORT_DURATION);
    }).catch((err: BusinessError)=>{
      LogUtil.error(`${TAG} get string err, errcode:${err?.code}, errmessage:${err?.message}`);
    });
  }
}