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

import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysHiWriteEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  EmptyInvisibleController,
  JumpController
} from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import Want from '@ohos.app.ability.Want';
import bundle from '@ohos.bundle.bundleManager';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
/* instrument ignore file */
export const HI_WRITE_WANT = {
  bundleName: 'com.ohos.hiwrite',
  abilityName: 'com.ohos.hiwrite.MainAbility',
} as Want;

export class HiWriteJumpController extends JumpController {
  public tag: string = 'HiWriteJumpController : ';

  static CreateHiWriteJumpController(menu: SettingsBaseMenu): Controller {
    return new HiWriteJumpController(menu);
  }

  onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysHiWriteEventGroup.ENTER_HI_WRITE_ENTRY);
    return super.onMenuClick();
  }
}

export class MoreConnectionInvisibleController extends EmptyInvisibleController {
  public tag: string = 'MoreConnectionInvisibleController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateMoreConnectionInvisibleController(menu: SettingsBaseMenu): Controller {
    return new MoreConnectionInvisibleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${this.tag} aboutToAppear`);
    try {
      bundle.getBundleInfoSync(HI_WRITE_WANT.bundleName, bundle.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    } catch (e) {
      LogUtil.error(`${this.tag} removeChildren ${NavEntryKey.HI_WRITE_SETTINGS_ENTRY} err: ${e}`);
      this.removeChildren(NavEntryKey.HI_WRITE_SETTINGS_ENTRY);
    }
  }
}

export class ConnectionVisibleController extends EmptyInvisibleController {
  public tag: string = 'ConnectionVisibleController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateConnectionVisibleController(menu: SettingsBaseMenu): Controller {
    return new ConnectionVisibleController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    LogUtil.info(`${this.tag} aboutToAppear`);

    if (!canIUse('SystemCapability.Communication.NFC.Core')) {
      LogUtil.info(`${this.tag} removeChildren ${NavEntryKey.NFC_ENTRY}`);
      this.removeChildren(NavEntryKey.NFC_ENTRY);
    }

    if (!CapabilitySupportUtils.isSupportNearLink()) {
      LogUtil.info(`${this.tag} removeChildren ${NavEntryKey.NEAR_LINK_ENTRY}`);
      this.removeChildren(NavEntryKey.NEAR_LINK_ENTRY);
    }
  }
}