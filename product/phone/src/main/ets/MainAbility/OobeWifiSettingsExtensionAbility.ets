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

import { BusinessError } from '@ohos.base';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'OobeWifiSettingsExtensionAbility : ';
const SETUP_WIFI_ENTRY: string = 'oobe_wifi_ui_extension_entry';
const WINDOW_BACKGROUND_COLOR: string = '#00000000';

export interface extensionProperties {
  session?: UIExtensionContentSession;
}

export default class OobeWifiSettingsExtensionAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityUtils.setCacheProcess(false, this.context);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);
    AppStorage.setOrCreate<Object>('sceneType', want?.parameters?.sceneType);
    AppStorage.setOrCreate<Object>('isFastCloneScene', want?.parameters?.isFastCloneScene);
    let localStorage: LocalStorage = new LocalStorage({
      session: session,
    } as extensionProperties);
    AppStorage.setOrCreate('externalNavigationUrl', SETUP_WIFI_ENTRY);
    try {
      session.loadContent('Setting/Wlan/OObeWifiSettingsHome', localStorage);
      session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
    } catch (error) {
      LogUtil.error(`${TAG} updateFingerprintDatabase failed: ${(error as BusinessError)?.message}}`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }
}