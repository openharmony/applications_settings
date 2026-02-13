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

import sim from '@ohos.telephony.sim';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG = 'ESimUtils: ';

export class ESimUtils {
  /**
   * 根据slotId获取sim卡名称
   *
   * @param slotId 卡槽slotID
   * @returns 对应slotID卡名称
   */
  public static getSimCardName(slotId: number): string {
    if (!SimUtils.isValidSlotId(slotId)) {
      return '';
    }
    if (!DeviceUtil.isSupportEsim()) {
      return ResourceUtil.getFormatStringSync($r('app.string.sim_card_one'), (slotId + 1).toString());
    }
    let simLabel = SimUtils.getSimLabel(slotId);
    if (!simLabel) {
      LogUtil.showError(TAG, `getSimCardName slotId ${slotId} got invalid simLabel!`);
      return '';
    }
    let cardNameRes =
      (simLabel.simType === sim.SimType.ESIM) ? $r('app.string.esim_card') : $r('app.string.sim_card_one');
    let simName: string = ResourceUtil.getFormatStringSync(cardNameRes, String(simLabel.index));
    return simName;
  }
}