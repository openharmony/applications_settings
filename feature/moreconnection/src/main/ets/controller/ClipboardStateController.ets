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
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { BusinessError } from '@ohos.base';
import dataShare from '@ohos.data.dataShare';
/* instrument ignore file */
const TAG: string = 'ClipboardStateController : ';

interface switchState {
  open: string;
  close: string;
};

const switchStatus: switchState = {
  open: '1',
  close: '0'
};
const STATE_KEY = 'distributed_pasteboard_switch';

export class ClipboardStateController extends MenuController {
  private dataHelper: dataShare.DataShareHelper | undefined = undefined;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateClipboardStateController(menu: SettingsBaseMenu): Controller {
    return new ClipboardStateController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
    if (!this.menu) {
      LogUtil.info(`${TAG} this.menu is null`);
      return;
    }
    this.menu.state = this.checkState();
    (SettingsDataUtils?.createDataHelper(this.getKey()) as Promise<dataShare.DataShareHelper>).then((dataHelper) => {
      this.dataHelper = dataHelper;
      SettingsDataUtils.registerSecurityDataChange(dataHelper, STATE_KEY, () => {
        let state = this.checkState();
        LogUtil.info(`${TAG} clipboard switch state change callback ${state}`);
        this.menu.state = state;
        this.refreshUi();
      })
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} createDataHelper error ${err?.message}`);
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    SettingsDataUtils.unRegisterSecurityDataChange(this.dataHelper, STATE_KEY);
  }

  private checkState(): ResourceStr {
    return SettingsDataUtils.getSettingsData(STATE_KEY, switchStatus.open, settings.domainName.USER_SECURITY) ===
      switchStatus.open
      ? $r('app.string.clipboard_switch_state_on_text') : $r('app.string.clipboard_switch_state_off_text');
  }
}