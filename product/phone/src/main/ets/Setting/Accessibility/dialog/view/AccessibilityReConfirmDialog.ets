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

/* instrument ignore file */
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import config from '@ohos.accessibility.config';
import { BusinessError } from '@ohos.base';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FunctionSelectOriginNameValue } from '../../constant/Constants';
import { ReConfirmDialogComponent } from './ReConfirmDialogComponent';
import { AccessibilityCommonModel } from '../../utils/AccessibilityCommonModel';

const TAG: string = 'AccessibilityReConfirmDialog : ';

@Component
@Entry
export struct AccessibilityReConfirmDialog {
  private targetsInfo: string = '';
  reConfirmController: CustomDialogController | null = new CustomDialogController({
    builder: ReConfirmDialogComponent({
      targetsInfo: this.targetsInfo,
    }),
    cancel: () => {
    },
    autoCancel: false,
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: $r('sys.color.mask_fourth'),
  });

  build() {
  }

  async getTargetsInfo(): Promise<string> {
    LogUtil.info(`${TAG} getTargetsInfo`);
    let targetsString: string = '';
    let shortKeyTargets: string[] = await config.shortkeyMultiTargets.get();
    let targetsList: string[] = [];
    for (let shortKeyTarget of shortKeyTargets) {
      if (!targetsList.find(target => target === shortKeyTarget)) {
        targetsList.push(shortKeyTarget);
        if (targetsString) {
          targetsString = targetsString + '、';
        }
        switch (shortKeyTarget) {
          case FunctionSelectOriginNameValue.HIGH_CONTRAST_TEXT:
            targetsString = targetsString + ResourceUtil.getStringSync($r('app.string.highContrast_text'));
            break;
          case FunctionSelectOriginNameValue.SINGLE_AUDIO:
            targetsString = targetsString + ResourceUtil.getStringSync($r('app.string.single_audio'));
            break;
          case FunctionSelectOriginNameValue.INVERT_COLOR:
            targetsString = targetsString + ResourceUtil.getStringSync($r('app.string.invert_color'));
            break;
          default:
            break;
        }
      }
    }
    LogUtil.info(`${TAG} getTargetsInfo end:  ${targetsString}`);
    return targetsString;
  }

  private closeDialog(): void {
    this.reConfirmController?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getTargetsInfo().then((data: string) => {
      this.targetsInfo = data;
      this.reConfirmController?.open();
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get target info failed: ${error?.message}`);
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.closeDialog();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}