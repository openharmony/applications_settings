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

export enum WeakPasswordChooseType {
  CONTINUE_USE = 'continueUse',
  RESET = 'reSet',
}

export const CLICK_HOT_SPOT_EVENT: string = 'CLICK_HOT_SPOT_EVENT';

const TAG: string = 'WeakPasswordDialogView';

@Component
export struct WeakPasswordDialogView {
  build() {
    Column() {
      Text($r('app.string.weak_password_dialog_content'))
        .fontColor($r('sys.color.icon_primary'))
        .width('100%')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}