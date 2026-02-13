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
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceStateUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { CheckPsdParams } from '../../password/model/CheckPasswordPage';
import { CHECK_PASSWORD_ENTRY_FLAG } from '../../password/controller/PasswordEntryController';
import { HiSysRelocateEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const TAG: string = 'ResetFactoryButtonController : ';
const DISALLOW_RESET_FACTORY_PARAM_KEY: string = 'persist.edm.reset_factory_disallowed';

/**
 * 恢复出厂界面按钮控制器
 *
 * @since 2023-01-19
 */
export class ResetFactoryButtonController extends ButtonMenuController {
  static CreateResetFactoryButtonController(menu: SettingsBaseMenu): Controller {
    return new ResetFactoryButtonController(menu);
  }

  private hasPassword: boolean = false;
  private isResetFactoryDisallowed: boolean = SystemParamUtil.getParam(DISALLOW_RESET_FACTORY_PARAM_KEY, 'false') === 'true';
  private lastClickTime: number = 0;

  aboutToAppear(): void {
    super.aboutToAppear();
    PasswordUtil.hasPinPassword((hasPinPassword) => {
      if (hasPinPassword) {
        this.hasPassword = true;
      } else {
        this.hasPassword = false;
      }
    });
  }

  onButton1Click(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysRelocateEventGroup.ENTER_RESET_PHONE_ENTRY);
    LogUtil.info(`${TAG} router to checkPasswordPage first`);
    if (this.isResetFactoryDisallowed) {
      // 防止连续点击，间隔时间为弹窗显示时间2s
      let nowTime: number = new Date().getTime();
      if (this.lastClickTime !== 0 && nowTime - this.lastClickTime < ToastUtil.SHORT_DURATION) {
        LogUtil.info(`${TAG} onButton1Click, less than 2s since the last showToast`);
        return true;
      }
      this.lastClickTime = nowTime;
      ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.reset_factory_disabled_toast')), ToastUtil.SHORT_DURATION);
      return true;
    }

    if (this.hasPassword) {
      let params: CheckPsdParams = new CheckPsdParams(CHECK_PASSWORD_ENTRY_FLAG,
        NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY, true);
      this.menu.pushName(NavEntryKey.CHECK_PSD_ENTRY, new PushParam(params));
    } else {
      this.menu.pushName(NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY, undefined);
    }
    return true;
  }
}
