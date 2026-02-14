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

import { Configuration, UIExtensionAbility, UIExtensionContentSession, Want } from '@kit.AbilityKit';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'DarkModeExtensionSettingsAbility: ';
const WINDOW_BACKGROUND_COLOR: string = '#00000000';
const EVENT_ID_DARK_MODE_WINDOW: string = 'EVENT_ID_DARK_MODE_WINDOW';
/**
 * AbilityComponent加载该窗口Ability
 */
interface UIExtensionStorage {
  uIExtensionSession: UIExtensionContentSession,
}

/**
 * 深色模式控制中心二级页面Ability
 */
export default class DarkModeExtensionSettingsAbility extends UIExtensionAbility {
  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onCreate is called`);
    if (CheckEmptyUtils.isEmpty(session)) {
      LogUtil.error(`${TAG} session is invalid`);
      return;
    }
    AbilityContextManager.addContext(this.context);
    if (!CheckEmptyUtils.isEmpty(want?.parameters?.controlCenterSubPanelTextColor)) {
      AppStorage.setOrCreate<number>('control_center_sub_panel_color',
        want.parameters?.controlCenterSubPanelTextColor as number);
      LogUtil.info(`${TAG} control_center_sub_panel_color ${want.parameters?.controlCenterSubPanelTextColor}`);
    }
    let localStorage: LocalStorage = new LocalStorage({ uIExtensionSession: session } as UIExtensionStorage);
    try {
      session.loadContent(PageUrl.DARK_MODE_WINDOW_URL, localStorage);
      session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
    } catch (err) {
      LogUtil.error(`${TAG} setWindowBackgroundColor fail err.code ${err?.code} err.message ${err?.message}`);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    EventBus.getInstance().emit(EVENT_ID_DARK_MODE_WINDOW, !newConfig.colorMode);
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }
}