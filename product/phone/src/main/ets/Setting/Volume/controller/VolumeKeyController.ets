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

import { dataShare } from '@kit.ArkData';
import { BusinessError } from '@ohos.base';
import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  DEFAULT_VOLUME_CONTROL_KEY,
  VOLUME_CONTROL_MEDIA_VALUE,
  VOLUME_CONTROL_RINGTONE_VALUE
} from '../constant/VolumeConstant';

/* instrument ignore file */
const TAG: string = 'VolumeKeyController';

export class VolumeKeyController implements ComponentControl {
  private compId: string = '';
  private dataHelper?: dataShare.DataShareHelper;
  private onDataChangeCallback = () => {
    LogUtil.info(`${TAG} default volume key control changed`);
    this.refreshUI();
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.compId = compParam?.compId;
    this.registerDataChangeCallback();
    this.refreshUI();
  }

  private registerDataChangeCallback(): void {
    let helperPromise = SettingsDataUtils.createDataHelper(DEFAULT_VOLUME_CONTROL_KEY);
    if (!helperPromise) {
      LogUtil.warn(`${TAG} registerDataChangeCallback fail for helperPromise is undefined`);
      return;
    }
    helperPromise.then(helper => {
      if (!helper) {
        LogUtil.warn(`${TAG} registerDataChangeCallback failed for helper is undefined`);
        return;
      }
      this.dataHelper = helper;
      SettingsDataUtils.registerUserDataChange(helper, DEFAULT_VOLUME_CONTROL_KEY, this.onDataChangeCallback);
    })
    .catch((err: BusinessError) => {
      LogUtil.error(`${TAG} registerDataChangeCallback error occurred, code:${err?.code}, message: ${err?.message}`);
    });
  }

  private unregisterDataChangeCallback(): void {
    if (!this.dataHelper) {
      LogUtil.warn(`${TAG} unregisterDataChangeCallback fail for helper is undefined`);
      return;
    }
    SettingsDataUtils.unRegisterUserDataChange(this.dataHelper, DEFAULT_VOLUME_CONTROL_KEY, this.onDataChangeCallback);
  }

  private refreshUI(): void {
    let volumeKeyControl: string =
      SettingsDataUtils.getSettingsData(DEFAULT_VOLUME_CONTROL_KEY, VOLUME_CONTROL_MEDIA_VALUE,
        Settings.domainName.USER_PROPERTY);
    LogUtil.info(`${TAG} updateVolumeKeyControl with value: ${volumeKeyControl}`);
    let text: ResourceStr = volumeKeyControl === VOLUME_CONTROL_RINGTONE_VALUE ?
      $r('app.string.ringtone_volume_message') : $r('app.string.media_volume_message');
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: text }
        } as SettingResultState]]));
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unregisterDataChangeCallback();
  }
}