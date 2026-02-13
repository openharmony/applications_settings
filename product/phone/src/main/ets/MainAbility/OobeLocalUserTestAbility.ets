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

import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'OobeLocalUserTestAbility : ';

// 此ability为OobeLocalUser测试专用，因调用UIExtensionAbility代码无法覆盖，所以添加UIAbility用于UI自动化测试
export default class OobeLocalUserTestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info(`${TAG} Ability onCreate`);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} Ability onDestroy`);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.info(`${TAG} Ability onWindowStageCreate`);
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);

    windowStage.getMainWindow((err, data) => {
      if (err.code) {
        LogUtil.error(`${TAG} Failed to obtain the main window. Cause: ${err.message}`);
        return;
      }
      let windowClass = data;
      windowClass.setWindowLayoutFullScreen(true);
    });
    windowStage.loadContent('Setting/UserSettings/oobe/OobeLocalUser', (err, data) => {
      if (err.code) {
        LogUtil.error(`${TAG} Failed to load the content. Cause: ${err.message}`);
        return;
      }
      LogUtil.info(`${TAG} Succeeded in loading the content.`);
    });
  }

  onWindowStageDestroy(): void {
    LogUtil.info(`${TAG} Ability onWindowStageDestroy`);
  }

  onForeground(): void {
    LogUtil.info(`${TAG} Ability onForeground`);
  }

  onBackground(): void {
    LogUtil.info(`${TAG} Ability onBackground`);
  }
}
