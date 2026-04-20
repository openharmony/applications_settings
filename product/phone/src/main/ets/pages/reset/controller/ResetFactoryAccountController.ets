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

import distributedAccount from '@ohos.account.distributedAccount';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { DefaultStateMenuStyle, IconImageStyle, StateMenu } from '@ohos/settings.uikit/src/main/ets/menus/Menu';

/* instrument ignore file */
const TAG: string = 'phoneResetFactoryAccountController : ';

class IconImageSize extends IconImageStyle {
  public borderRadius?: Length | undefined = 16;
  public margin: Margin = {
    right: $r('app.float.margin_16'),
  };
}

class HwAccountMenuStyle extends DefaultStateMenuStyle {
  public iconImage: ImageStyle = new IconImageSize();
}

let hwAccountMenuStyle = new HwAccountMenuStyle();

/**
 * 恢复出厂界面显示各类帐户控制器
 *
 * @since 2022-10-24
 */
export class ResetFactoryAccountController extends MenuGroupController {
  static CreateResetFactoryAccountController(menu: SettingsBaseMenu): Controller {
    return new ResetFactoryAccountController(menu);
  }

  updateStatus() {
    super.updateStatus();
    this.loadAccounts();
  }

  private async loadAccounts() {
    let menus: SettingsBaseMenu[] = [];
    let info: distributedAccount.DistributedInfo | null = null;
    try {
      info = await distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo();
    } catch (error) {
      LogUtil.error(`${TAG} get osAccount distributedInfo failed: ${error?.message}`);
    }
    if (info?.nickname) {
      let hwAccountMenu = new StateMenu({ key: 'hwaccount_info' });
      hwAccountMenu.title = info?.nickname;
      hwAccountMenu.icon = info?.avatar as string;
      hwAccountMenu.style = hwAccountMenuStyle;
      hwAccountMenu.isAccountMenu = true;
      hwAccountMenu.focusable = false;
      menus.push(hwAccountMenu);
    }

    // 后期还可以添加其他种类的帐户
    if (menus.length == 0) {
      LogUtil.info(`${TAG} accounts is null, hide the list!`);
      this.setVisible(false);
    } else {
      this.clearChildren();
      this.addChildren(menus);
    }
    this.refreshUi();
  }
}
