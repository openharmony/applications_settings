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
import accessibility from '@ohos.accessibility';
import { BusinessError } from '@ohos.base';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { FunctionSelectOriginNameValue } from '../../constant/Constants';
import { HighContrastTextSwitchController } from '../../controller/HighContrastTextSwitchController';

/* instrument ignore file */
export class MultiCheckboxController {
  public tag: string = 'MultiCheckboxController : ';
  public isChecked: boolean = false;
  public menuTitle: string = '';
  private menuKey: string = '';
  public targetName: string = '';
  public static capabilities: Array<accessibility.Capability> =
    ['retrieve', 'keyEventObserver', 'gesture', 'zoom', 'touchGuide'];
  private controller?: CustomDialogController;

  constructor(compId: string, value: string, isSelected: boolean) {
    this.menuKey = compId;
    this.targetName = value;
    this.isChecked = isSelected;
  }

  private closeSelf(): void {
    this.controller?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }

  onMenuChange(isChecked: boolean): void {
    LogUtil.info(`${this.tag} onMenuChange: ${isChecked} value:${this.targetName}`);
    this.setCheckBox(isChecked);
    if (this.menuKey) {
      LogUtil.info(`${this.tag} onMenuChange: isChecked:${this.isChecked}`);
      this.enabledSelectFunction(this.menuKey, !this.isChecked).then(() => {
        this.closeSelf();
      }).catch((error: BusinessError) => {
        LogUtil.error(`${this.tag} call enabledSelectFunction failed: ${error?.message}`);
      });
    } else {
      LogUtil.error(`${this.tag} get targetName fail`);
    }
  }

  private setCheckBox(isChecked: boolean): void {
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
    }
  }

  private openCaptionAbility(state: boolean): void {
    let uriAddress: string = state ? 'hw://vassistant/caption?action=close' : '';
    let want: Want = {
      'bundleName': 'com.ohos.vassistant',
      'abilityName': 'AiCaptionServiceExtAbility',
      'uri': uriAddress
    };
    AbilityUtils.startAbility(want);
  }

  async enabledSelectFunction(target: string, state: boolean): Promise<boolean> {
    switch (target) {
      case FunctionSelectOriginNameValue.HIGH_CONTRAST_TEXT:
        if (!state && HighContrastTextSwitchController.isDarkModeOn()) {
          HighContrastTextSwitchController.setDarkModeOff();
        }
        await config.highContrastText.set(!state);
        break;
      case FunctionSelectOriginNameValue.SINGLE_AUDIO:
        await config.audioMono.set(!state);
        break;
      case FunctionSelectOriginNameValue.INVERT_COLOR:
        await config.invertColor.set(!state);
        break;
      default:
        break;
    }
    HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ACCESSIBILITY_FUNCTION_RADIO, target, !state ? 'on' : 'off');
    return true;
  }
}

export class ShortKeyButtonController {
  public tag: string = 'ShortKeyButtonController : ';
  private controller?: CustomDialogController;

  constructor(controller?: CustomDialogController) {
    this.controller = controller;
  }

  /**
   * 点击取消按钮回调
   */
  onCancelClick(): void {
    LogUtil.info(`${this.tag} onCancelClick`);
    let name = '';
    let value = 'Cancel';
    HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
      HiSysAccessibilityEventGroup.ACCESSIBILITY_FUNCTION_RADIO, name, value);
    this.closeDialog();
  }

  private closeDialog(): void {
    this.controller?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }
}