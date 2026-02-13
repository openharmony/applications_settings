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

import { UIExtensionAbility, UIExtensionContentSession, Want } from '@kit.AbilityKit';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'SoundExtensionAbility: ';

interface UIExtensionStorage {
  uIExtensionSession: UIExtensionContentSession,
}

export default class SoundExtensionAbility extends UIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onCreate is called`);
    if (CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} session is invalid`);
      return;
    }
    AbilityContextManager.addContext(this.context);
    let localStorage: LocalStorage = new LocalStorage({ uIExtensionSession: session } as UIExtensionStorage);
    try {
      session.loadContent(PageUrl.SOUND_MODE_WINDOW_URL, localStorage); // 加载页面
      session.setWindowBackgroundColor('#00000000');
    } catch (err) {
      LogUtil.error(`${TAG} SoundExtensionAbility onSessionCreate fail, err : ${err?.code},  ${err?.message} `);
    }
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }
}
