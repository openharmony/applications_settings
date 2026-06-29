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

import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const SETTING_DETECTABLE_STATE: string = 'instantshare_detect_state';
const TAG: string = 'ShareStateController:';

export class ShareStateController implements ComponentControl {
  private hasRegisterDetectTypeObserver: boolean = false;
  private compId: string = '';
  public onDataChange = () => {
    this.changStateAsync();
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.changStateAsync();
    this.registerDataChange();
  }

  destroy(): void {
    this.unRegisterDataChange();
  }

  private registerDataChange(): void {
    if (this.hasRegisterDetectTypeObserver) {
      LogUtil.info(`${TAG} hasRegisterDetectTypeObserver: ${this.hasRegisterDetectTypeObserver}`);
      return;
    }
    this.hasRegisterDetectTypeObserver = SettingsDataUtils.registerKeyObserverWithDomain(SETTING_DETECTABLE_STATE,
      Settings.domainName.USER_SECURITY, this.onDataChange);
    LogUtil.info(`${TAG} hasRegisterDetectTypeObserver isSuccess: ${this.hasRegisterDetectTypeObserver}`);
  }

  private unRegisterDataChange(): void {
    if (!this.hasRegisterDetectTypeObserver) {
      LogUtil.info(`${TAG} hasRegisterDetectTypeObserver: ${this.hasRegisterDetectTypeObserver}`);
      return;
    }
    if (SettingsDataUtils.unregisterKeyObserverWithDomain(SETTING_DETECTABLE_STATE,
      Settings.domainName.USER_SECURITY)) {
      this.hasRegisterDetectTypeObserver = false;
    }
  }

  private changStateAsync(): void {
    SettingsDataUtils.getSettingsDataAsync(SETTING_DETECTABLE_STATE, '0',
      Settings.domainName.USER_SECURITY).then(isOpen => {
      let newState: ResourceStr = '';
      notifyCompStateChange(this.compId,
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: newState } } as SettingResultState]]));
    })
  }
}