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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'OobePasswordSettingExtensionAbility';
const LOCK_SCREEN_ENTRY: string = NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY;

export interface ExtensionProperties {
  session?: UIExtensionContentSession;
}

export default class OobePasswordSettingExtensionAbility extends UIExtensionAbility {

  /**
   * UIExtensionAbility创建时回调，执行初始化业务逻辑操作。
   */
  public onCreate(): void {
    LogUtil.info(`${TAG} onCreate is called`);
  }

  /**
   * 当UIExtensionAbility界面内容对象创建后调用。
   *
   * @param want 当前UIExtensionAbility的Want类型信息，包括ability名称、bundle名称等。
   * @param session UIExtensionAbility界面内容相关信息。
   */
  public onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionCreate is called`);
    AbilityContextManager.addContext(this.context);
    let localStorage: LocalStorage = new LocalStorage({
      session: session,
    } as ExtensionProperties);
    AppStorage.setOrCreate<Want>('wantParams', want);
    AppStorage.setOrCreate('externalNavigationUrl', LOCK_SCREEN_ENTRY);
    AppStorage.setOrCreate<UIExtensionContentSession>('uiExtensionContentSession', session);
    session.loadContent(PageUrl.EXTERNAL_SETTINGS_HOME_PAGE_URL, localStorage);
  }

  /**
   * 当UIExtensionAbility界面内容对象销毁后调用。
   *
   * @param session UIExtensionAbility界面内容相关信息。
   */
  public onSessionDestroy(session: UIExtensionContentSession): void {
    LogUtil.info(`${TAG} onSessionDestroy is called`);
    AbilityContextManager.removeContext(this.context);
  }

  /**
   * UIExtensionAbility生命周期回调，当UIExtensionAbility从后台转到前台时触发。
   */
  public onForeground(): void {
    LogUtil.info(`${TAG} onForeground is called`);
  }

  /**
   * UIExtensionAbility生命周期回调，当UIExtensionAbility从前台转到后台时触发。
   */
  public onBackground(): void {
    LogUtil.info(`${TAG} onBackground is called`);
  }

  /**
   * UIExtensionAbility生命周期回调，在销毁时回调，执行资源清理等操作。
   * 在执行完onDestroy生命周期回调后，应用可能会退出，从而可能导致onDestroy中的异步函数未能正确执行，比如异步写入数据库。
   * 可以使用异步生命周期，以确保异步onDestroy完成后再继续后续的生命周期。
   * @returns 操作结果
   */
  public onDestroy(): void | Promise<void> {
    LogUtil.info(`${TAG} onDestroy is called`);
  }
}