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

import { sim } from '@kit.TelephonyKit';
import { ItemRestriction, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
/* instrument ignore file */
export const SLOT_INDEX_0: number = 0;

export const SLOT_INDEX_1: number = 1;

const TAG: string = 'RingtoneSimUtil'

export class RingtoneSimUtil {
  private static simNameMap: Map<number, string> = new Map<number, string>();

  /**
   * 通过卡槽id获取SIM卡名称，包括普通SIM卡和eSIM
   *
   * @param slotId 卡槽id，当前最多支持两个，即：0、1
   * @returns SIM卡名称
   */
  public static getSimCardName(slotId: number): string {
    if (!SimUtils.isValidSlotId(slotId)) {
      return '';
    }
    if (!DeviceUtil.isSupportEsim()) {
      return ResourceUtil.getFormatStringSync($r('app.string.sim_card_one'), (slotId + 1).toString());
    }
    let simName = RingtoneSimUtil.simNameMap.get(slotId);
    if (simName) {
      return simName;
    }
    let simLabel = SimUtils.getSimLabel(slotId);
    if (!simLabel) {
      LogUtil.showError(TAG, `getSimCardName slotId ${slotId} got invalid simLabel!`);
      return '';
    }
    let cardNameRes =
      (simLabel.simType === sim.SimType.ESIM) ? $r('app.string.esim_card') : $r('app.string.sim_card_one');
    simName = ResourceUtil.getFormatStringSync(cardNameRes, String(simLabel.index));
    RingtoneSimUtil.simNameMap.set(slotId, simName)
    return simName;
  }

  public static resetSimCardName(): void {
    if (DeviceUtil.isSupportEsim()) {
      RingtoneSimUtil.simNameMap.clear();
    }
  }

  /**
   * 获取sim卡 tab页组件配置
   *
   * @returns sim卡 tab页组件配置
   */
  public static getSimCardTabs(): SegmentButtonOptions | undefined {
    let simName1 = RingtoneSimUtil.getSimCardName(SLOT_INDEX_0);
    let simName2 = RingtoneSimUtil.getSimCardName(SLOT_INDEX_1);
    if (CheckEmptyUtils.checkStrIsEmpty(simName1) || CheckEmptyUtils.checkStrIsEmpty(simName2)) {
      LogUtil.showError(TAG, `getSimCardTabs invalid name! simName1: ${simName1}, simName2: ${simName2}`);
      return undefined;
    }
    let tabOptions = SegmentButtonOptions.tab({
      buttons: [
        { text: simName1 },
        { text: simName2 },
      ] as ItemRestriction<SegmentButtonTextItem>,
      fontSize: $r('sys.float.Body_M'),
      selectedFontSize: $r('sys.float.Body_M'),
      fontColor: $r('sys.color.font_secondary'),
      selectedFontColor: $r('sys.color.font_primary'),
      fontWeight: FontWeight.Medium,
      selectedFontWeight: FontWeight.Medium,
      textPadding: {
        top: $r('app.float.wh_value_6'),
        right: $r('app.float.wh_value_10'),
        bottom: $r('app.float.wh_value_6'),
        left: $r('app.float.wh_value_10')
      },
      backgroundColor: $r('sys.color.comp_background_tertiary'),
      selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
      backgroundBlurStyle: BlurStyle.NONE
    });
    return tabOptions;
  }
}