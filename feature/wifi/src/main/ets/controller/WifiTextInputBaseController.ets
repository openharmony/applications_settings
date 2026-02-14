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
import { TextInputMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { BroadcastEventInfo, ENTER_KEY_CODE, EVENT_NAME_KEYBOARD, WIFI_IP_PREFIX_LENGTH } from '../WifiMenuManager';

/**
 * WIFI eap 输入框控制器
 */
@Observed
export class WifiTextInputBaseController extends TextInputMenuController {
  static CreateWifiTextInputBaseController(menu: SettingsBaseMenu): Controller {
    return new WifiTextInputBaseController(menu);
  }

  // 此处覆写父类MenuController中tag的值
  public tag: string = 'WifiTextInputBaseController : ';
  public supportMethod: Array<number>;
  public isCurrentVisible: boolean;
  public listenMenuKey: string;
  public isClearTitle: boolean;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!this.menu?.extra) {
      LogUtil.info(`${this.tag} router params apConfig is invalid`);
    }

    this.isCurrentVisible = (this.menu?.extra as extraType).isCurrentVisible as boolean;
    this.supportMethod = (this.menu?.extra as extraType).supportMethod as Array<number>;
    this.listenMenuKey = (this.menu?.extra as extraType).listenMenuKey as string;
    this.isClearTitle = (this.menu?.extra as extraType).isClearTitle ?? true;
  }

  updateStatus(): void {
    this.setVisible(this.isCurrentVisible);
    if (!this.isCurrentVisible && this.isClearTitle) {
      this.menu.title = '';
      this.publishDataChange(this.menu.title);
    }
  }

  onTextInputChange(input: string): void {
    if (this.menu.key === WIFI_IP_PREFIX_LENGTH) {
      let sub = false;
      while (input.startsWith('0')) {
        input = input.substr(1);
        this.menu.title = input;
        sub = true;
      }
      if (sub) {
        this.refreshUi();
      }
    }
    this.publishDataChange(input);
  }

  registerDataChange(): void {
    this.registerControllerDataChange(this.listenMenuKey);
  }

  unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(this.listenMenuKey);
  }

  onDataChange(fromKey: string, data: number): void {
    if (typeof data === 'number') {
      LogUtil.info(`${this.tag} onDataChange, fromKey: ${fromKey}`);
      this.isCurrentVisible = this.supportMethod.includes(data);
      this.updateStatus();
      this.refreshUi();
    }
  }

  onSubmit(enterKey: EnterKeyType): void {
    LogUtil.info(`${this.tag} onSubmit, enterKey: ${enterKey} `);
    this.publishDataChange(new BroadcastEventInfo(EVENT_NAME_KEYBOARD, ENTER_KEY_CODE));
  }
}