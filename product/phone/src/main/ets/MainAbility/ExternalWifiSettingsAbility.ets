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

import Ability from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'ExternalWifiSettingsAbility : ';
const EXTERNAL_WIFI_ENTRY: string = 'external_wifi_entry';

export interface initializingProperties {
  externalWindowStage?: window.WindowStage;
  windowStage?: window.WindowStage;
}

export default class ExternalWifiSettingsAbility extends Ability {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
    let apConfig = want?.parameters?.apConfig;
    AppStorage.SetOrCreate<Object>('apConfig', apConfig);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info(`${TAG} onNewWant is called`);
    let apConfig = want?.parameters?.apConfig;
    AppStorage.SetOrCreate<Object>('apConfig', apConfig);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }

  setNavigationUrl() : void {
    AppStorage.SetOrCreate('externalNavigationUrl', EXTERNAL_WIFI_ENTRY);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LogUtil.info('onWindowStageCreate is called navigationUrl : WIFI_ENTRY');
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    let localStorage: LocalStorage = new LocalStorage({
      externalWindowStage: windowStage,
    } as initializingProperties);
    this.setNavigationUrl();
    windowStage?.loadContent(PageUrl.EXTERNAL_SETTINGS_HOME_PAGE_URL, localStorage).then(()=> {
      WindowManager.setMainWindowBackgroundColor(windowStage, '#F1F3F5');
    });
  }
}