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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SUPPORT_HDR } from '../constant/DisplayConstant';

const TAG: string = 'DisplayMeunShowUtils: ';
const EBOOK_SWITCH: string = 'settings.display.EbookSwitch';
const EBOOK_COLOR_SWITCH: string = 'settings.display.EbookColorSwitch';
const SWING_EYE: string = 'settings.display.supportSwingEye';
const LOW_FREQUENCY_FLASH: string = 'settings.display.lowFrequencyFlashSwitch';

/**
 * 显示页面menu显示工具类
 */
export class DisplayMeunShowUtils {

  public static isColorEBookSupport(): boolean {
    let isSupport: boolean = PreferencesUtil.getSync(EBOOK_COLOR_SWITCH, false) as boolean;
    LogUtil.info(`${TAG} DisplayPreferencesUtils getSupported EbookColorSwitch : ${isSupport}`);
    return isSupport;
  }

  public static isLowFrequencyFlashSupport(): boolean {
    let isSupport: boolean = PreferencesUtil.getSync(LOW_FREQUENCY_FLASH, false) as boolean;
    LogUtil.info(`${TAG} DisplayPreferencesUtils getSupported lowFrequencyFlashSwitch : ${isSupport}`);
    return isSupport;
  }

  public static isHdrSupport(): boolean {
    let isSupport: boolean = PreferencesUtil.getSync(SUPPORT_HDR, false) as boolean;
    LogUtil.info(`${TAG} DisplayPreferencesUtils getSupported supportHdr : ${isSupport}`);
    return isSupport;
  }

  public static isBionicVisionSupport(): boolean {
    let isSupport: boolean = false;
    try {
      isSupport =
        (systemParameterEnhance.getSync('const.photos.enable_pixelmap_readapt', 'true') === 'true') as boolean;
    } catch (err) {
      LogUtil.error(`get enable_pixelmap_readapt failed. error msg: ${(err as BusinessError).message}`);
    }
    return isSupport;
  }
}
