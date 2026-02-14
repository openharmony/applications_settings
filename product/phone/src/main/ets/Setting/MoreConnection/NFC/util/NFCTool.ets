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
import cardEmulation from '@ohos.nfc.cardEmulation';
import bundleManager from '@ohos.bundle.bundleManager';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
/* instrument ignore file */
const DEFAULT_PAY_APP = 'nfc_payment_default_app';

const TAG: string = 'NFCTool: '

export class NFCTool {
  /**
   * 通知界面刷新当前默认应用
   */
  static notifyRefreshDefaultApp(curDefaultPayAPPValue: string, compId: string, isClone: boolean = false): void {
    LogUtil.info(`${TAG} curDefaultPayAPPValue: ${curDefaultPayAPPValue}`);
    if (!isClone) {
      SettingsDataUtils.setSettingsData(DEFAULT_PAY_APP, curDefaultPayAPPValue);
    }
    try {
      let lastIndex: number = curDefaultPayAPPValue.indexOf('/');
      let bundleName: string = curDefaultPayAPPValue.substring(0, lastIndex);
      let nfcList: bundleManager.AbilityInfo[] = cardEmulation.getPaymentServices();
      let defaultPayAppItem: bundleManager.AbilityInfo | undefined =
        nfcList.find((nfcListItem) => nfcListItem?.bundleName === bundleName);
      if (!defaultPayAppItem) {
        LogUtil.error(`${TAG} getDefaultNFCApp failed.`);
        return;
      }
      const resourceManager = ResourceManagerUtil.getBundleResourceManager(defaultPayAppItem?.bundleName);
      if (!resourceManager) {
        LogUtil.info(`${TAG} resourceManager is null`);
        return;
      }
      resourceManager.getStringValue(defaultPayAppItem?.labelId).then((defaultApp: string) => {
        LogUtil.info(`${TAG} current defaultNFCApp is: ${defaultApp}`);
        notifyCompStateChange(compId,
          new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
            {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: defaultApp,
              }
            } as SettingResultState]]));
      }).catch((error: BusinessError) => {
        notifyCompStateChange(compId,
          new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
            {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: $r('app.string.not_set'),
              }
            } as SettingResultState]]));
        LogUtil.error(`${TAG} getStringValue error ${error?.message}`);
      })
      MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    } catch (error) {
      LogUtil.error(`${TAG} getDefaultNFCApp catch error, message:${error?.message}`);
    }
  }
}