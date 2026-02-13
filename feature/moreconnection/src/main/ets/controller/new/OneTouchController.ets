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
import dataShare from '@ohos.data.dataShare';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'OneTouchController : ';
const STATE_ON_FLAG = '1';
const STATE_KEY = 'one_touch_status';

export class OneTouchController implements ComponentControl {
  private dataHelper: dataShare.DataShareHelper | undefined = undefined;
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.refreshUi(this.checkState());
    let helper =
      SettingsDataUtils.createDataHelper(NavEntryKey.ONE_TOUCH_ENTRY) as Promise<dataShare.DataShareHelper>;
    helper.then((dataHelper) => {
      this.dataHelper = dataHelper;
      SettingsDataUtils.registerSecurityDataChange(dataHelper, STATE_KEY, () => {
        let state = this.checkState();
        LogUtil.info(`${TAG} one touch state change callback ${state}`);
        this.refreshUi(state);
      })
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} createDataHelper error ${error?.message}`);
    })
  }

  destroy(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, STATE_KEY);
  }

  private checkState(): ResourceStr {
    return SettingsDataUtils.getSettingsData(STATE_KEY, STATE_ON_FLAG, settings.domainName.USER_SECURITY) ===
      STATE_ON_FLAG
      ? $r('app.string.key_mouse_share_state_on_text') : $r('app.string.key_mouse_share_state_off_text');
  }

  private refreshUi(content: ResourceStr): void {
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }
}