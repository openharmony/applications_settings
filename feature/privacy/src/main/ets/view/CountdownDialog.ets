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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TIME_INTERVAL, PasswordResolveInfoManager } from '../PasswordResolveInfoManager';

export const COUNTDOWN_DIALOG_EVENT: string = 'countdownDialogEvent';
export const OPEN_CHECK_PASSWORD_DIALOG: string = 'open_check_password_dialog';
let pwdResolveInfoManager: PasswordResolveInfoManager | null = PasswordResolveInfoManager.getInstance();

@Component
export struct CountdownDialog {
  private tag: string = `CountdownDialogContent`;
  @State text: ResourceStr = '';

  build() {
    Row() {
      Text(this.text)
        .constraintSize({ minHeight: '14vp' })
        .size({
          height: '24vp',
          width: '100%',
        })
        .margin({ top: '24vp' })
        .padding({
          start: PADDING_16,
          end: PADDING_16
        })
        .font({
          size: $r('sys.float.ohos_id_text_size_body1'),
          weight: FontWeight.Medium,
        })
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .maxLines(5)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.startCountDownTimer();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    pwdResolveInfoManager?.stopTimer();
  }

  /**
   * 开始计时，每秒刷新一次倒计时弹窗中的 message 时间信息
   */
  private startCountDownTimer(): void {
    this.text = PasswordUtil.getCountDownDialogMessage(pwdResolveInfoManager?.getFreezingTime() as number);
    pwdResolveInfoManager?.stopTimer();
    pwdResolveInfoManager?.newTimer((freezingTime: number) => {
      if (freezingTime >= TIME_INTERVAL) {
        this.text = PasswordUtil.getCountDownDialogMessage(freezingTime);
      } else {
        EventBus.getInstance().emit(COUNTDOWN_DIALOG_EVENT, OPEN_CHECK_PASSWORD_DIALOG);
      }
    });
    pwdResolveInfoManager?.startTimer();
  }
}