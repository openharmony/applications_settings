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
import { PasswordResolveInfoManager } from '../PasswordResolveInfoManager';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

export const MIN_COUNT_DOWN_TIME: number = 1000;

/**
 * 倒计时弹窗-文本信息控制器-基类
 *
 * @since 2022-05-12
 */
export class CountDownMessageBaseController extends MenuController {
  public passwordResolveInfoManager: PasswordResolveInfoManager | null = null;

  constructor(menu: SettingsBaseMenu, passwordResolveInfoManager: PasswordResolveInfoManager | null) {
    super(menu);
    this.passwordResolveInfoManager = passwordResolveInfoManager;
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.startCountDonwTimer();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    this.passwordResolveInfoManager?.stopTimer();
    this.passwordResolveInfoManager = null;
  }

  /**
   * 开始计时，每秒刷新一次倒计时弹窗中的 message 时间信息
   */
  startCountDonwTimer(): void {
    this.menu.title =
    PasswordUtil.getCountDownDialogMessage(this.passwordResolveInfoManager?.getFreezingTime() as number);
    this.passwordResolveInfoManager?.stopTimer();
    this.passwordResolveInfoManager?.newTimer((freezingTime: number) => {
      if (freezingTime >= MIN_COUNT_DOWN_TIME) {
        this.menu.title = PasswordUtil.getCountDownDialogMessage(freezingTime);
        this.refreshUi();
      } else {
        this.closeSelf(this.getMessage() as Object);
      }
    });
    this.passwordResolveInfoManager?.startTimer();
  }

  getMessage(): string | null {
    return null;
  }
}