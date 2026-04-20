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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import Want from '@ohos.app.ability.Want';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NOT_DISTURB_WINDOW_PAGE_URL } from '../Setting/Volume/NotDisturbWindowSettings';

/* instrument ignore file */
const TAG: string = 'NotDisturbUIExtensionSettingsAbility : ';
const WINDOW_BACKGROUND_COLOR: string = '#00ffffff';

/**
 * AbilityComponent加载该窗口Ability
 */
interface UIExtensionStorage {
  extensionSession: UIExtensionContentSession,
}

export default class NotDisturbUIExtensionSettingsAbility extends UIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityContextManager.addContext(this.context);

    let localStorage: LocalStorage = new LocalStorage({
      extensionSession: session
    } as UIExtensionStorage);
    session.loadContent(NOT_DISTURB_WINDOW_PAGE_URL, localStorage);
    session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }
}