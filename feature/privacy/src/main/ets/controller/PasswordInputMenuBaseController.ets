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
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import InputMethod from '@ohos.inputMethod';
import { TextInputMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';

export const MSG_PASSWORD_INPUT_CLICK: number = 2500;

const STATUS_ON: number = 1;

const STATUS_OFF: number = 0;

/**
 * 隐私-密码输入框控制器-基类
 *
 * @since 2022-05-12
 */
export class PasswordInputMenuBaseController extends TextInputMenuController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  onTextInputChange(input: string): void {
    this.publishDataChange(input);
  }

  onEditChange(isEditing: boolean): void {
    this.publishDataChange(isEditing ? STATUS_ON : STATUS_OFF);
  }

  onSubmit(enterKey: EnterKeyType): void {
    InputMethod.getInputMethodController()?.stopInput();
  }

  onMenuClick(): boolean {
    this.publishDataChange(MSG_PASSWORD_INPUT_CLICK);
    return false;
  }

  clearInput(): void {
    this.menu.title = '';
    this.refreshUi();
    let emptyInput: string = '';
    this.publishDataChange(emptyInput);
  }
}