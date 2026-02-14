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

import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'IntelligentSceneSessionUtil: ';

/**
 * UEC session通信工具类
 */
export class IntelligentSceneSessionUtil {
  /**
   * 发送消息给情景模式 session
   *
   * @param intent 消息对象
   */
  public static sendMessageToAppDataSession(intent: Record<string, Object>): void {
    try {
      LogUtil.showInfo(TAG, 'send message to app data session');
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session')?.sendData(intent);
    } catch (error) {
      LogUtil.showError(TAG, `sendMessageToAppDataSession error: ${error?.code}, ${error?.message}`);
    }
  }

  /**
   * 向情景模式进程获取加载状态
   */
  public static sendMessageToGetLoadState(): void {
    const intent: Record<string, Object> = { 'action': 'getLoadState' };
    IntelligentSceneSessionUtil.sendMessageToAppDataSession(intent);
  }
}
