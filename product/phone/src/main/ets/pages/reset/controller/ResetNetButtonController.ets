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

import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CheckPsdParams } from '../../password/model/CheckPasswordPage';
import { CHECK_PASSWORD_ENTRY_FLAG } from '../../password/controller/PasswordEntryController';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysRelocateEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'ResetNetButtonController : ';

/**
 * Reset network settings: button controller
 *
 * @author yudenggao
 * @since 2023-08-29
 */
export class ResetNetButtonController extends ButtonMenuController {
  static CreateResetNetButtonController(menu: SettingsBaseMenu): Controller {
    return new ResetNetButtonController(menu);
  }

  private hasPassword: boolean = false;

  aboutToAppear(): void {
    super.aboutToAppear();
    PasswordUtil.hasPinPassword((hasPinPassword) => {
      this.hasPassword = hasPinPassword;
    });
  }

  onButton1Click(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysRelocateEventGroup.ENTER_RESTORE_NETWORK_PAGE);
    LogUtil.info(`${TAG} router to checkPasswordPage first`);
    if (this.hasPassword) {
      let params: CheckPsdParams = new CheckPsdParams(CHECK_PASSWORD_ENTRY_FLAG,
        NavEntryKey.CONFIRM_RESET_NET_ENTRY, true);
      this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
    } else {
      this.menu.pushName(NavEntryKey.CONFIRM_RESET_NET_ENTRY, undefined);
    }
    return true;
  }
}
