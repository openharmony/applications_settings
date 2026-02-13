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
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'OpenNetworkUIExtensionAbility: ';

interface UIExtensionStorage {
  session: UIExtensionContentSession,
}

/**
 * 外部拉起wlan网络配置界面入口ability
 */
export default class OpenNetworkUIExtensionAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityUtils.setCacheProcess(false, this.context);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    AbilityContextManager.addContext(this.context);
    FontScaleUtils.setConfig(this.context.config.fontSizeScale as number);
    let localStorage: LocalStorage = new LocalStorage({
      session: session
    } as UIExtensionStorage);
    try {
      session.loadContent(PageUrl.EXTERNAL_NETWORK_SETTINGS_HOME_PAGE_URL, localStorage);
      session.setWindowBackgroundColor('#00000000');
    } catch (err) {
      LogUtil.error(`${TAG} setWindowBackgroundColor fail`);
    }
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onSessionDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }

  onForeground(): void {
    LogUtil.info(`${TAG} onForeground is called`);
  }

  onBackground(): void {
    LogUtil.info(`${TAG} onBackground is called`);
  }
}