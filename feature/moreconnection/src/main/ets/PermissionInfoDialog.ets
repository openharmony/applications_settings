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

import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
/* instrument ignore file */
const TAG: string = 'PermissionInfoDialog';

/**
 * 权限说明弹框
 */
@CustomDialog
export struct PermissionInfoDialog {
  @Link privacyWant: Want | null;
  dialogController?: CustomDialogController;

  build() {
    Column() {
      this.buildPageContent();
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildPageContent(): void {
    Column() {
      if (this.privacyWant && this.isSettingsPrivacyWant(this.privacyWant)) {
        // 权限说明页面Component
        UIExtensionComponent({
          bundleName: this.privacyWant.bundleName,
          abilityName: this.privacyWant.abilityName,
          parameters: this.privacyWant.parameters,
        })
          .width('100%')
          .height('100%')
          .onError((error: BusinessError) => {
            LogUtil.error(`${TAG} UIExtensionComponent onError, message=${error?.message}.`);
            this.closeDialog();
          })
          .onRelease((code: number) => {
            LogUtil.info(`${TAG} UIExtensionComponent onRelease, code=${code}.`);
            this.closeDialog();
          })
      }
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }

  /**
   * 关闭弹框
   */
  private closeDialog() {
    if (this.dialogController) {
      LogUtil.info(`${TAG} close privacy dialog`);
      this.dialogController.close();
    }
  }

  private isSettingsPrivacyWant(privacyWant?: Want): boolean {
    if (privacyWant && privacyWant.bundleName && privacyWant.abilityName &&
      privacyWant.bundleName !== PackagesConstant.SETTINGS_BUNDLE_NAME) {
      return true;
    }
    return false;
  }
}