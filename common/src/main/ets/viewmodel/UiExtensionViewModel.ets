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

import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { napi } from '@ohos/settings.native/src/main/ets/napi/NapiInstance';
import { EVENT_ID_ON_PAGE_FOREGROUND } from '../event/types';
import { UiExtensionConstant } from '../constant/UiExtensionConstant';
import { SettingsPerformanceDfx } from '../utils/SettingsPerformanceDfx';
import { EventBus } from '../framework/common/EventBus';
import { CommonEventConstant } from '../constant/CommonEventConstant';
import { CommonUtils } from '../utils/CommonUtils';
import { LogUtil } from '../utils/LogUtil';

@Observed
export class ObservedData {
  public reconnect: number = 0;
  public left: number = 0;
  public right: number = 0;
}

export class UiExtensionViewModel {
  public observedData: ObservedData;
  private shouldRefresh: boolean = false;
  private errorCode: number = 0;
  private tag: string = 'UiExtensionViewModel';
  private static controller: CustomDialogController | undefined = undefined;

  constructor(observedData: ObservedData) {
    this.observedData = observedData;
    let currentPadding: number = AppStorage.get<number>('navDesDynamicPadding') as number;
    this.observedData.left = CommonUtils.getSettingsPagePadding(currentPadding);
    this.observedData.right = this.observedData.left;
  }

  public refreshing(error: BusinessError, recoverController: CustomDialogController, bundleName: string,
    abilityName: string): void {
    const code: number = error?.code;
    this.errorCode = code;
    if (!UiExtensionConstant.isExceptionExit(code)) {
      return;
    }
    if (this.observedData.reconnect < UiExtensionConstant.REFRESH_TIMES) {
      this.observedData.reconnect++;
    } else {
      if (UiExtensionViewModel.controller) {
        UiExtensionViewModel.controller.close();
      }
      recoverController?.open();
      UiExtensionViewModel.controller = recoverController;
      this.shouldRefresh = true;
    }
    SettingsPerformanceDfx.reportUiextensionLoadFailureEvent(bundleName, abilityName, this.observedData.reconnect,
      this.errorCode);
  }

  public refreshingNoNeedDialog(error: BusinessError, bundleName: string, abilityName: string): void {
    const code: number = error?.code;
    this.errorCode = code;
    if (!UiExtensionConstant.isExceptionExit(code)) {
      return;
    }
    LogUtil.info(`${this.tag} refreshingNoNeedDialog, reconnect: ${this.observedData.reconnect}`);
    this.observedData.reconnect = this.observedData.reconnect === 0 ? 1 : 0;
    SettingsPerformanceDfx.reportUiextensionLoadFailureEvent(bundleName, abilityName, this.observedData.reconnect,
      this.errorCode);
  }

  public listening(recoverController?: CustomDialogController): void {
    emitter.on({ eventId: EVENT_ID_ON_PAGE_FOREGROUND }, () => {
      LogUtil.info(`${this.tag} page foreground, shouldRefresh: ${this.shouldRefresh}, errorCode: ${this.errorCode}`);
      if (this.shouldRefresh) {
        recoverController?.close();
        this.observedData.reconnect++;
      }
      this.shouldRefresh = false;
    });

    EventBus.getInstance().on(CommonEventConstant.EVENT_SETTINGS_CONTENT_PADDING, (currentPadding: number) => {
      this.observedData.left = CommonUtils.getSettingsPagePadding(currentPadding);
      this.observedData.right = this.observedData.left;
    });
  }

  public destroyListening(): void {
    UiExtensionViewModel.controller?.close();
    UiExtensionViewModel.controller = undefined;
    emitter.off(EVENT_ID_ON_PAGE_FOREGROUND);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_SETTINGS_CONTENT_PADDING, () => {});
  }

  public delayTransition(delayTime: number = 50): void {
    // delay start page transition animation
    napi.sleep(delayTime);
  }
}