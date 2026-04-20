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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { IntelligentSceneWindowManager } from '../Setting/IntelligentScene/manager/IntelligentSceneWindowManager';
import { AppAndMetaServiceManager } from '../Setting/IntelligentScene/manager/NotDisturbNotificationManager';
import { IntelligentSceneSessionUtil } from '../Setting/IntelligentScene/utils/IntelligentSceneSessionUtil';
import { EVENT_APP_LIST_LOAD_COMPLETE } from '../Setting/IntelligentScene/event/types';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneAppListExtensionAbility : ';
const WINDOW_BACKGROUND_COLOR: string = '#00000000';
const APP_LIST_PAGE: string = 'Setting/IntelligentScene/IntelligentSceneAppSelectComponent';
const APP_META_SERVICE_LIST_PAGE: string = 'Setting/IntelligentScene/AppAndMetaServices/AppAndMetaServicesComponent';

export interface extensionProperties {
  session?: UIExtensionContentSession;
}

enum AppListType {
  APP_LIST,
  APP_META_SERVICE_LIST,
}

export default class IntelligentSceneAppSelectExtensionAbility extends UIExtensionAbility {
  private pagePath: string = APP_LIST_PAGE;

  onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
    AbilityUtils.setCacheProcess(false, this.context);
    FontScaleUtils.setConfig(this.context.config.fontSizeScale as number);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    AbilityContextManager.addContext(this.context);
    switch (want?.parameters?.appListType) {
      case AppListType.APP_LIST:
        this.appListInit(want);
        break;
      case AppListType.APP_META_SERVICE_LIST:
        this.appMetaServiceListInit(want);
        break;
      default:
        LogUtil.warn(`${TAG} appListType is incorrect`);
        break;
    }
    let localStorage: LocalStorage = new LocalStorage({
      session: session,
    } as extensionProperties);
    try {
      session.loadContent(this.pagePath, localStorage);
      session.setWindowBackgroundColor(WINDOW_BACKGROUND_COLOR);
      session.setReceiveDataCallback((data: Record<string, Object>) => {
        this.onReceiveDataChange(data);
      });
    } catch (error) {
      LogUtil.error(`${TAG} loadContent failed: ${error?.message}`);
    }
    IntelligentSceneWindowManager.getInstance().registerDataChange();
    LogUtil.info(`${TAG} onSessionCreate end`);
  }

  onSessionDestroy(): void {
    LogUtil.info(`${TAG} onSessionDestroy is called`);
    IntelligentSceneWindowManager.getInstance().unRegisterDataChange();
    AbilityContextManager.removeContext(this.context);
  }

  /**
   * 处理接受参数
   *
   * @param data 消息数据
   */
  private onReceiveDataChange(data: Record<string, Object>): void {
    LogUtil.showInfo(TAG, `receive data change action: ${data?.action}`);
    if (data && data['action'] === EVENT_APP_LIST_LOAD_COMPLETE) {
      EventBus.getInstance().emit(EVENT_APP_LIST_LOAD_COMPLETE);
      return;
    }
    if (data && data['action'] === 'getLoadState' && data['loadState'] as boolean === true) {
      LogUtil.showInfo(TAG, `loadState: ${data['loadState']}`);
      EventBus.getInstance().emit(EVENT_APP_LIST_LOAD_COMPLETE);
    }
  }

  private appListInit(want: Want): void {
    LogUtil.info(`${TAG} appListInit`);
    AppStorage.setOrCreate<Object>('isAdd', want?.parameters?.isAdd);
    AppStorage.setOrCreate<Object>('enabled', want?.parameters?.enabled);
    this.pagePath = APP_LIST_PAGE;
  }

  private appMetaServiceListInit(want: Want): void {
    LogUtil.info(`${TAG} appMetaServiceListInit`);
    AppAndMetaServiceManager.getInstance().init();
    AppStorage.setOrCreate<Object>('hasSetWhiteList', want?.parameters?.hasSetWhiteList);
    AppStorage.setOrCreate<Object>('notificationWhiteList', want?.parameters?.notificationWhiteList);
    this.pagePath = APP_META_SERVICE_LIST_PAGE;
  }
}