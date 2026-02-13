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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'BluetoothUIExtensionSettingsAbility : ';
const WINDOW_BACKGROUND_COLOR: string = '#00ffffff'; // 窗口背景色

/**
 * AbilityComponent加载该窗口Ability
 */
interface UIExtensionStorage {
  UIExtensionSession: UIExtensionContentSession,
}

export default class BluetoothUIExtensionSettingsAbility extends UIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onCreate is called`);
    if (CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} session is invalid`);
      return;
    }

    AbilityContextManager.addContext(this.context);

    let localStorage: LocalStorage = new LocalStorage({ UIExtensionSession: session } as UIExtensionStorage);
    let url: string = CapabilitySupportUtils.isSupportFusion() ? PageUrl.FUSION_WINDOW_PAGE_URL :
    PageUrl.BLUETOOTH_WINDOW_PAGE_URL;
    try {
      session.loadContent(url, localStorage);
      session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
    } catch (err) {
      LogUtil.error(`${TAG} UIExtensionAbility on session create error: ${err.message}`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }
}