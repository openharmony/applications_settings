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

import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PasswordManager } from '@ohos/settings.common/src/main/ets/passwordManager/PasswordManager';
import {
  ButtonMenu,
  DialogPage,
  DialogTitleMenu,
  EdmPasswordStateMenuStyle,
  EdmTipsButtonMenuStyle,
  StateMenu,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PageUrl } from '../../PageUrl';


/**
 * edm密码强度控制提示弹框
 */
export class EdmTipsDialogPage extends DialogPage {
  constructor() {
    super({
      pageUrl: PageUrl.EDM_TIPS_DIALOG_PAGE_URL,
      title: $r('app.string.weak_password_dialog_title'),
      scrollable: false,
    });
    this.addMenus(
      [
        new DialogTitleMenu(
          {
            key: 'edm_password_dialog_title',
            index: 100,
            title: $r('app.string.weak_password_dialog_title'),
          }
        ),
        new StateMenu(
          {
            key: 'edm_password_dialog_message',
            index: 200,
            title: PasswordManager.getEdmPasswordWarningMessage(),
            style: new EdmPasswordStateMenuStyle() as Style
          }
        ),
        new ButtonMenu(
          {
            key: 'cancel_button',
            index: 300,
            menuType: 'Button',
            buttonTittle1: $r('app.string.weak_password_dialog_positive_button'),
            controller: {
              createControllerConstructorInter: EdmPasswordDialogController.CreateEdmPasswordDialogController,
            },
            style: new EdmTipsButtonMenuStyle() as Style
          }
        )
      ]
    );
  }
}

/**
 * edm策略密码弹框控制器
 */
export class EdmPasswordDialogController extends ButtonMenuController {
  static CreateEdmPasswordDialogController(menu: SettingsBaseMenu): Controller {
    return new EdmPasswordDialogController(menu);
  }

  public tag: string = 'EdmPasswordDialogController: ';

  isButton1Enabled(): boolean {
    return true;
  }

  onButton1Click(): void {
    this.closeSelf(Constants.repeatPinInput);
  }
}