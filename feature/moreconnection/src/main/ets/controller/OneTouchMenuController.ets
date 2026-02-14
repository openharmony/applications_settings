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
import { BusinessError } from '@ohos.base';
import dataShare from '@ohos.data.dataShare';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
/* instrument ignore file */
const TAG: string = 'OneTouchMenuController : ';

const STATE_ON_FLAG = '1';
const STATE_KEY = 'one_touch_status';

export class OneTouchMenuController extends MenuController {
  private dataHelper: dataShare.DataShareHelper | undefined = undefined;

  static CreateOneTouchMenuController(menu: SettingsBaseMenu): Controller {
    return new OneTouchMenuController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
    if (!this.menu) {
      return
    }
    this.menu.state = this.checkState();
    (SettingsDataUtils?.createDataHelper(this.getKey()) as Promise<dataShare.DataShareHelper>).then((dataHelper) => {
      this.dataHelper = dataHelper;
      SettingsDataUtils.registerSecurityDataChange(dataHelper, STATE_KEY, () => {
        let state = this.checkState();
        LogUtil.info(`${TAG} one touch state change callback ${state}`);
        this.menu.state = state;
        this.refreshUi();
      })
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} createDataHelper error ${err?.message}`);
    })
  }

  aboutToDisappear(): void {
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, STATE_KEY);
  }

  private checkState(): ResourceStr {
    return SettingsDataUtils.getSettingsData(STATE_KEY,
      STATE_ON_FLAG, settings.domainName.USER_SECURITY) === STATE_ON_FLAG ? $r('app.string.key_mouse_share_state_on_text') : $r('app.string.key_mouse_share_state_off_text');
  }
}