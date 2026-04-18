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

/* instrument ignore file */
const TAG: string = 'ResetLogoutLoadingComponent : ';

/**
 * page for ResetLogoutLoadingComponent
 *
 * @since 2025-03-18
 */
@Entry
@Component
struct ResetLogoutLoadingComponent {
  private hasClickButton: boolean = false;
  onAccept() {
    LogUtil.showInfo(TAG, 'onAccept');
    this.hasClickButton = true;
    this.closeDialog();
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    this.hasClickButton = false;
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    // 手势上滑关闭走这里
    if (!this.hasClickButton) {
      this.hasClickButton = true;
      this.closeDialog();
    }
  }

  private closeDialog(): void {
    try {
      (AppStorage.get<UIExtensionContentSession>('ResetLogoutLoadingSession') as UIExtensionContentSession)?.terminateSelf();
    } catch (error) {
      LogUtil.error(`${TAG} destroyServiceExtensionAbility occur error ${error?.message}`);
    }
  }

  build() {
    Column() {
      LoadingProgress()
        .width(72)
        .height(72)
        .alignSelf(ItemAlign.Center)
        .color($r('sys.color.icon_on_primary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(Visibility.Visible)
  }
}