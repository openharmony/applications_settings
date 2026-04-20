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

import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { ContainerStyle, Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PasswordUtil, PinSubType } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import {
  ButtonMenu,
  ButtonMenuContainerStyle,
  DefaultButtonMenuStyle,
  DefaultDialogPageStyle, DialogPage, DialogTitleMenu,
  SafeTipsButtonMenuStyle,
  StateMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';

import { PageUrl } from '../../PageUrl';
/* instrument ignore file */
import { CustomButtonMenuStyle } from '../controller/CreateNumberPsdController';

// 弹框延迟弹出
const DELAYED_DIALOG: number = 300;

export class WeakPasswordDialogPageStyle extends DefaultDialogPageStyle {
  public padding: Padding = {
    left: $r('app.float.margin_6'),
    right: $r('app.float.margin_6'),
  };
}

export class WeakPasswordDialogMessageStyle extends DefaultButtonMenuStyle {
  public rootContainer = new DefaultDialogContainerStyle();
}

export class DefaultDialogContainerStyle extends ButtonMenuContainerStyle {
  public margin: Margin = {
    bottom: $r('app.float.margin_8'),
  };

  public padding: Padding = {
    right: $r('app.float.margin_8'),
    left: $r('app.float.margin_8')
  }
}

/**
 * 创建弱密码弹框
 *
 * @since 2023-10-05
 */
export class SafeTipsDialogPage extends DialogPage {
  private highSecurityFlag : boolean | undefined = false;

  constructor(highSecurityFlag? : boolean) {
    super({
      pageUrl: PageUrl.SAFE_TIPS_DIALOG_PAGE_URL,
      title: $r('app.string.weak_password_dialog_title'),
      style: new WeakPasswordDialogPageStyle() as Style,
      scrollable: false,
    });
    this.highSecurityFlag = highSecurityFlag;
    this.addMenus(
      [
        new DialogTitleMenu(
          {
            key: 'weak_password_dialog_title',
            index: 100,
            title: $r('app.string.weak_password_dialog_title'),
          }
        ),
        SafeTipsDialogPage.getStateMenu(this.highSecurityFlag as boolean),
        SafeTipsDialogPage.getButtonMenu(this.highSecurityFlag as boolean)
      ]
    );
  }

  /**
   * 根据有无钱包高安标记，更改StateMenu.title
   * @param highSecurityFlag
   * @returns 返回一个StateMenu
   */
  static getStateMenu(highSecurityFlag: boolean): StateMenu {
    let res: StateMenu = new StateMenu({
      key: 'ap_connected_speed',
      index: 200,
      title: $r('app.string.weak_password_dialog_content'),
      style: new WeakPasswordDialogMessageStyle() as Style,
      focusable: false
    })
    if (highSecurityFlag) {
      res.title = $r('app.string.weak_password_dialog_content_with_wallet_card');
    }
    return res;
  }

  /**
   * 根据有无钱包高安标记，决定是否屏蔽 继续使用 按钮
   * @param highSecurityFlag
   * @returns 返回一个ButtonMenu
   */
  static getButtonMenu(highSecurityFlag: boolean): ButtonMenu {
    let res: ButtonMenu | undefined = undefined;
    if (highSecurityFlag) {
      res = new ButtonMenu(
        {
          key: 'cancel_button',
          index: 300,
          buttonTittle1: $r('app.string.weak_password_dialog_positive_button'),
          controller: {
            createControllerConstructorInter:
            HighSecurityPasswordDialogController.CreateHighSecurityPasswordDialogController,
          },
          style: new CustomButtonMenuStyle() as Style,
        }
      )
    } else {
      res = new ButtonMenu(
        {
          key: 'cancel_button',
          index: 300,
          menuType: 'DivideButton',
          buttonTittle1: $r('app.string.weak_password_dialog_negative_button'),
          buttonTittle2: $r('app.string.weak_password_dialog_positive_button'),
          controller: {
            createControllerConstructorInter:
              WeakPasswordDialogController.CreateWeakPasswordDialogController,
          },
          style: new SafeTipsButtonMenuStyle() as Style,
        }
      )
    }
    return res;
  }

  /**
   * 无障碍模式弹框延迟弹出
   *
   * @param menu 菜单
   * @param isHighSecurity 是否高安
   */
  public static createSafeTipsDialog(menu: MenuController, isHighSecurity?: boolean): void {
    if (AccessibilityUtils.isAccessibilityMode()) {
      setTimeout(() => {
        menu.openDialog(new SafeTipsDialogPage(isHighSecurity), false);
      }, DELAYED_DIALOG);
    } else {
      menu.openDialog(new SafeTipsDialogPage(isHighSecurity), false);
    }
  }
}

/**
 * 弱密码弹框控制器
 *
 * @since 2023-09-17
 */
export class WeakPasswordDialogController extends ButtonMenuController {
  static CreateWeakPasswordDialogController(menu: SettingsBaseMenu): Controller {
    return new WeakPasswordDialogController(menu);
  }

  public tag: string = 'WeakPasswordDialogController: ';
  private isHighSecurityFlag: boolean = WalletManageUtils.checkIfHighSecurity();

  isButton1Enabled(): boolean {
    return !this.isHighSecurityFlag;
  }

  onButton1Click(): void {
    if (!this.isHighSecurityFlag) {
      this.closeSelf(Constants.continueAnyWay);
    }
  }

  isButton2Enabled(): boolean {
    return true;
  }

  onButton2Click(): void {
    this.closeSelf(Constants.repeatPinInput);
  }
}

/**
 * 高安密码弹框控制器
 */
export class HighSecurityPasswordDialogController extends ButtonMenuController {
  static CreateHighSecurityPasswordDialogController(menu: SettingsBaseMenu): Controller {
    return new HighSecurityPasswordDialogController(menu);
  }

  onButton1Click(): void {
    this.closeSelf(Constants.repeatPinInput);
  }
}