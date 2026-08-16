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
import accessibility from '@ohos.accessibility';
import config from '@ohos.accessibility.config';
import Settings from '@ohos.settings';
import { BusinessError } from '@ohos.base';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ExtensionInfo, FunctionSelectOriginNameValue } from '../../constant/Constants';
import { AccessibilityCommonModel } from '../../utils/AccessibilityCommonModel';
import { ShortKeyDialogComponent } from './ShortKeyDialogComponent';

const TAG: string = 'AccessibilityShortKeyDialog : ';
const DOMAIN_NAME: string = Settings.domainName.USER_PROPERTY;

@Component
@Entry
export struct AccessibilityShortKeyDialog {
  private targetsInfo: ExtensionInfo[] = [];
  shortKeyontroller: CustomDialogController | null = new CustomDialogController({
    builder: ShortKeyDialogComponent({
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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getTargetsInfo().then((data: ExtensionInfo[]) => {
      this.targetsInfo = data;
      this.shortKeyontroller?.open();
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get target info failed: ${error?.message}`);
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  async getTargetsInfo(): Promise<ExtensionInfo[]> {
    LogUtil.info(`${TAG} getTargetsInfo`);
    let enabledExtensionServices = await accessibility.getAccessibilityExtensionList('all', 'enable');
    let shortKeyTargets = await config.shortkeyMultiTargets.get();
    let enabledTargetsIdList: ExtensionInfo[] = [];
    let enabledExtensionServiceIds: string[] = [];
    for (let extensionService of enabledExtensionServices) {
      enabledExtensionServiceIds.push(extensionService.id);
    }
    for (const shortKeyTarget of Object.values(FunctionSelectOriginNameValue)) {
      LogUtil.debug(`${TAG} getTargetsInfo shortKeyTarget: ${shortKeyTarget}`);
      if (!shortKeyTargets.includes(shortKeyTarget)) {
        continue;
      }
      let targetId: ResourceStr = '';
      let isEnabled: boolean = false;
      switch (shortKeyTarget) {
        case FunctionSelectOriginNameValue.HIGH_CONTRAST_TEXT:
          targetId = ResourceUtil.getStringSync($r('app.string.highContrast_text'));
          isEnabled = await config.highContrastText.get();
          break;
        case FunctionSelectOriginNameValue.SINGLE_AUDIO:
          targetId = ResourceUtil.getStringSync($r('app.string.single_audio'));
          isEnabled = await config.audioMono.get();
          break;
        case FunctionSelectOriginNameValue.INVERT_COLOR:
          targetId = ResourceUtil.getStringSync($r('app.string.invert_color'));
          isEnabled = await config.invertColor.get();
          break;
        default:
          break;
      }
      enabledTargetsIdList.push({
        id: shortKeyTarget,
        name: targetId,
        state: isEnabled
      });
    }
    LogUtil.debug(`${TAG} getTargetsInfo end`);
    return enabledTargetsIdList;
  }
}