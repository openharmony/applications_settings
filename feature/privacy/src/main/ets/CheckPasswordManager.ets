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
import window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingDialogState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PrivacyConstant } from '@ohos/settings.common/src/main/ets/constant/PrivacyConstant';
import { PasswordResolveInfoManager } from './PasswordResolveInfoManager';
import { PrivacyDialogManager } from './PrivacyDialogManager';
import {
  CountdownDialog,
  COUNTDOWN_DIALOG_EVENT,
  OPEN_CHECK_PASSWORD_DIALOG
} from './view/CountdownDialog';
import {
  CheckLockScreenPasswordDialog,
  CHECK_PASSWORD_DIALOG_EVENT,
  NEXT_ACTION,
  OPEN_COUNTDOWN_DIALOG,
} from './view/CheckLockScreenPasswordDialog';

@Builder
function checkLockScreenPasswordDialogBuilder(param: object): void {
  CheckLockScreenPasswordDialog();
}

@Builder
function countdownDialogContentBuilder(param: object): void {
  CountdownDialog();
}

const TAG: string = `CheckPasswordManager`;
const CHECK_PASSWORD_DIALOG: string = 'checkPasswordDialog';
const COUNTDOWN_DIALOG: string = 'countdownDialog';
export const CHECK_PASSWORD_SUCCESS_EVENT: string = 'checkPasswordSuccessEvent'

export class CheckPasswordManager {
  private compId: string = '';
  private pwdResolveInfoManager: PasswordResolveInfoManager | null = PasswordResolveInfoManager.getInstance();
  private checkSuccessAction?: string = '';

  init(compParam: CompCtrlParam, action?: string): void {
    LogUtil.showInfo(TAG, 'on init');
    this.compId = compParam.compId;
    this.checkSuccessAction = action;
    EventBus.getInstance().on(CHECK_PASSWORD_DIALOG_EVENT, this.checkPasswordDialogEventCallback);
    EventBus.getInstance().on(COUNTDOWN_DIALOG_EVENT, this.countdownDialogEventCallback);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'on destroy');
    EventBus.getInstance().detach(CHECK_PASSWORD_DIALOG_EVENT, this.checkPasswordDialogEventCallback);
    EventBus.getInstance().detach(COUNTDOWN_DIALOG_EVENT, this.countdownDialogEventCallback);
  }

  private checkPasswordDialogEventCallback = async (action: string, data?: string) => {
    LogUtil.showInfo(TAG, `checkPasswordDialogEventCallback, ${action}`);
    this.closeDialog(CHECK_PASSWORD_DIALOG);
    if (action === NEXT_ACTION) {
      if (data === OPEN_COUNTDOWN_DIALOG) {
        this.openCountdownDialog();
        return;
      }
      EventBus.getInstance().emit(CHECK_PASSWORD_SUCCESS_EVENT, this.checkSuccessAction);
    }
  };

  private countdownDialogEventCallback = async (data?: string) => {
    LogUtil.showInfo(TAG, `countdownDialogEventCallback, ${data}`);
    this.closeDialog(COUNTDOWN_DIALOG);
    if (data === OPEN_CHECK_PASSWORD_DIALOG) {
      this.openCheckLockScreenPasswordDialog();
      this.pwdResolveInfoManager?.stopTimer();
    }
  };

  /**
   * 存在锁屏，显示锁屏密码校验弹窗
   */
  public openCheckLockScreenPasswordDialog(): void {
    LogUtil.showInfo(TAG, `openDialog: ${CHECK_PASSWORD_DIALOG} `);
    this.setWindowPrivacyMode(CHECK_PASSWORD_DIALOG, true);
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {
          title: $r('app.string.input_lock_screen_password_dialog_title'),
          contentBuilder: wrapBuilder(checkLockScreenPasswordDialogBuilder),
          onWillDismiss: () => {
            PrivacyDialogManager.isPrivacyDialogOpen = false;
            this.safetyCloseWindowPrivacyMode(CHECK_PASSWORD_DIALOG);
          },
          style: {
            autoCancel: false,
            titleStyle: {
              textAlign: TextAlign.Center
            },
            padding: {
              top: PADDING_12,
            }
          }
        } as SettingDialogState]]
      )
    );
  }

  /**
   * 剩余尝试次数已用完，显示倒计时弹窗
   */
  public openCountdownDialog(): void {
    LogUtil.showInfo(TAG, `openDialog: ${COUNTDOWN_DIALOG} `);
    notifyCompStateChange(`${this.compId}`,
      new Map<SettingStateType, SettingDialogState>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {
          contentBuilder: wrapBuilder(countdownDialogContentBuilder),
          buttons: [
            {
              value: $r('app.string.dialog_button_confirm'),
              action: () => {
                LogUtil.showInfo(TAG, 'showCountdownDialog close');
              },
              style: {
                buttonStyle: ButtonStyleMode.NORMAL,
                fontColor: $r('sys.color.font_emphasize'),
              }
            },
          ],
          buttonVertical: FontScaleUtils.isExtraLargeFontMode() ? false : true,
          style: {
            autoCancel: false,
            padding: {
              top: PADDING_12,
            }
          }
        } as SettingDialogState]]
      )
    );
  }

  public closeDialog(dialogKey: string): void {
    LogUtil.showInfo(TAG, `closeDialog: ${dialogKey}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingDialogState>([
      [SettingStateType.STATE_TYPE_ITEM_DIALOG, {} as SettingDialogState]
    ]));
    PrivacyDialogManager.isPrivacyDialogOpen = false;
    this.safetyCloseWindowPrivacyMode(dialogKey);
  }

  public safetyCloseWindowPrivacyMode(key?: string): void {
    setTimeout(() => {
      if (!PrivacyDialogManager.isPrivacyDialogOpen) {
        this.setWindowPrivacyMode(key as string, false);
      }
    }, PrivacyConstant.PC_DIALOG_CLOSE_ANIM_TIME);
  }

  public setWindowPrivacyMode(key: string, isPrivacyMode: boolean): void {
    if (key === CHECK_PASSWORD_DIALOG) {
      if (isPrivacyMode) {
        PrivacyDialogManager.isPrivacyDialogOpen = true;
      }
      PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
        isPrivacyMode);
    }
  }
}