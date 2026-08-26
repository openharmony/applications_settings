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

import config from '@ohos.accessibility.config';
import { BusinessError } from '@ohos.base';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'AccessibilityReConfirmButtonController : ';
const SHORTCUT_ENABLED_ON_LOCK_SCREEN: string = 'accessibility_shortcut_enabled_on_lock_screen';

export class ReConfirmButtonController {
  private controller?: CustomDialogController;

  constructor(controller?: CustomDialogController) {
    this.controller = controller;
  }

  /**
   * 点击取消按钮回调
   */
  onCancelClick(): void {
    LogUtil.info(`${TAG} onCancelClick`);
    config.shortkey.set(false).then(() => {
      LogUtil.info(`${TAG} shortkey set false success`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} shortkey set false err: ${err?.message}`);
    });
    this.closeDialog();
  }

  /**
   * 点击开启按钮回调
   */
  onOpenClick(): void {
    LogUtil.info(`${TAG} onOpenClick`);
    SettingsDataUtils.setSecureValue(SHORTCUT_ENABLED_ON_LOCK_SCREEN, '1');
    this.closeDialog();
  }

  private closeDialog(): void {
    this.controller?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }
}