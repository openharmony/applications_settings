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
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import bundleManager from '@ohos.bundle.bundleManager';

const TAG: string = 'SuperLauncherVisibleController : ';

/**
 * SuperLauncher menu visible controller
 */
@Observed
export class SuperLauncherVisibleController extends MenuController {
  static CreateSuperLauncherVisibleController(menu: SettingsBaseMenu): Controller {
    return new SuperLauncherVisibleController(menu);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.setVisible(false);
    this.checkSuperLauncherInstallationState();
    super.aboutToAppear();
  }

  private async checkSuperLauncherInstallationState() {
    let bundleName = 'com.ohos.slassistant';
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    let userId = 100;

    try {
      bundleManager.getBundleInfo(bundleName, bundleFlags, userId, (err, data) => {
        if (err) {
          LogUtil.error(`${TAG} getBundleInfo failed: ${err.message}`);
        } else {
          LogUtil.info(`${TAG} getBundleInfo successfully`);
          if (data.name === bundleName) {
            this.setVisible(true);
          }
        }
      })
    } catch (err) {
      LogUtil.error(`${TAG} getBundleInfo failed: ${err.message}`);
    }
  }
}