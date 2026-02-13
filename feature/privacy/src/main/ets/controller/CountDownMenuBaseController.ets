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
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PasswordResolveInfoManager } from '../PasswordResolveInfoManager';

export const MIN_COUNT_DOWN_TIME: number = 1000;

/**
 * 倒计时弹窗-文本信息控制器-基类
 *
 * @since 2023-01-18
 */
export class CountDownMenuBaseController extends MenuController {
  public tag: string = 'CountDownMenuBaseController : ';
  public passwordResolveInfoManager: PasswordResolveInfoManager | null = null;
  protected isHideRemoveFromUxTree: boolean = false;

  constructor(menu: SettingsBaseMenu, passwordResolveInfoManager: PasswordResolveInfoManager) {
    super(menu);
    this.passwordResolveInfoManager = passwordResolveInfoManager;
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
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
        this.onFreezingEnd();
      }
    });
    this.passwordResolveInfoManager?.startTimer();
  }

  onFreezingEnd(): void {
    this.setVisible(false);
  }

  isVisibleStatus(): boolean {
    LogUtil.info(`${this.tag} isVisibleStatus ${this.isVisible} ${this.isHideRemoveFromUxTree}`);
    return (this.isVisible || !this.isHideRemoveFromUxTree);
  }
}