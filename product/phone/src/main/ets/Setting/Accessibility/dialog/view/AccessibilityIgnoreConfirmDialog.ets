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
import { AlertDialog } from '@kit.ArkUI';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import config from '@ohos.accessibility.config';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { MultiCheckboxController } from '../controller/SelectFunctionController';
import {
  SCREEN_READER_ON_KEY,
  CLICK_SWITCH_OFF,
  CLICK_SWITCH_ON,
  FunctionSelectOriginNameValue,
  IGNORE_REPEATED_CLICK_CACHE_FLAG,
  IGNORE_REPEATED_CLICK_EXCLUDE_FLAG,
  IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG
} from '../../constant/Constants';
import { IgnoreRepeatedStateModel } from '../../utils/AccessibilityIgnoreRepeatedModel';

const TAG: string = 'AccessibilityIgnoreConfirmDialog : ';

@Component
@Entry
export struct AccessibilityIgnoreConfirmDialog {
  @State isIgnoreConfirmStatus: boolean = false;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.screenreader_is_sure_open'),
      content: this.isIgnoreConfirmStatus ? $r('app.string.ignore_repeat_click_screen_reader_open') :
      $r('app.string.ignore_repeat_click_screen_reader_confirm'),
      primaryButton: {
        value: $r('app.string.dialog_cancel'),
        action: () => {
          this.disableScreenReader();
        },
      },
      secondaryButton: {
        value: $r('app.string.dialog_enable'),
        action: () => {
          LogUtil.info(`${TAG} onDialogConfirm`);
          this.enabledScreenReader();
        }
      },
    }),
    cancel: () => {
    },
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  build() {
  }

  private closeDialog(): void {
    this.dialogController?.close();
    (AppStorage.get<UIExtensionContentSession>(
      'accessibilityDialogSession') as UIExtensionContentSession)?.terminateSelf();
  }

  /**
   * 互斥弹框点击关闭，主动关闭屏幕朗读状态（为了防止小艺开启屏幕朗读场景，互斥弹框弹出时，屏幕朗读已经开启。）
   * @returns
   */
  async disableScreenReader(): Promise<void> {
    this.closeDialog();
    SettingsDataUtils.setSettingsData(SCREEN_READER_ON_KEY, CLICK_SWITCH_OFF);
  }

  /**
   * 互斥弹框点击开启，会先关闭忽略重复点击，并清理状态。然后开启屏幕朗读，如果处于试用流程，还会关闭试用页面。
   * @returns
   */
  async enabledScreenReader(): Promise<void> {
    IgnoreRepeatedStateModel.getInstance().closeRepeatClickState();
    this.closeDialog();
    let isIgnoreConfirmStatus: boolean = SettingsDataUtils.getSecureValue(
      IGNORE_REPEATED_CLICK_EXCLUDE_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    LogUtil.info(`${TAG} isIgnoreConfirmStatus: ${isIgnoreConfirmStatus}`);
    if (isIgnoreConfirmStatus) {
      SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_CACHE_FLAG, CLICK_SWITCH_OFF);
      SettingsDataUtils.setSecureValue(IGNORE_REPEATED_CLICK_EXCLUDE_FLAG, CLICK_SWITCH_OFF);
      SettingsDataUtils.setSettingsData(IGNORE_REPEATED_EXPERIMENT_MODEL_SHOW_FLAG, CLICK_SWITCH_ON);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.isIgnoreConfirmStatus = SettingsDataUtils.getSecureValue(
      IGNORE_REPEATED_CLICK_EXCLUDE_FLAG, CLICK_SWITCH_OFF) === CLICK_SWITCH_ON;
    this.dialogController?.open();
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