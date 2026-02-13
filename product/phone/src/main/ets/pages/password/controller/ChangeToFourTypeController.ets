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

/* instrument ignore file */
import { PasswordConstant } from '@ohos/settings.common/src/main/ets/constant/PasswordConstant';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { BACK_ENTRY, NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { FOUR_DIGIT_PIN_TYPE_ENTRY } from './CreateFourPinController';

const CERTIFICATION_ENTRY: string = NavEntryKey.BIOMETRICS_PASSWORD_ENTRY;
/**
 * 切4位数字密码控制器
 *
 * @since 2024-06-24
 */
export class ChangeToFourTypeController extends MenuController {
  public tag: string = 'ChangeSixToFourTypeController: ';

  static CreateChangeToFourTypeController(menu: SettingsBaseMenu): Controller {
    return new ChangeToFourTypeController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.updateTitle();
  }

  private async updateTitle(): Promise<void> {
    let message = await ResourceUtil.getNumberFormatString($r('app.string.pin_type'),
      PasswordConstant.FOUR_PIN_PASSWORD_TYPE_STR_LENGTH);
    this.menu.title = message;
    this.refreshUi();
  }

  onMenuClick(): boolean {
    LogUtil.info(`${this.tag} onMenuClick change to four`);
    HiSysEventUtil.reportEntryEvent(FOUR_DIGIT_PIN_TYPE_ENTRY, '');
    AppStorage.setOrCreate(BACK_ENTRY, CERTIFICATION_ENTRY);
    this.menu.pathInfos?.pop();
    this.menu.pushPath(NavEntryKey.CREATE_FOUR_PSD_ENTRY, this.menu.navRouterParam as PushParam);
    this.closeSelf();
    return true;
  }
}