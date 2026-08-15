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

import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { usersAccountController } from './UsersAccountController';

const CURRENT_LOGIN_ITEM_ID: string = 'current_login_item';

class CurrentLoginItemController implements ComponentControl {
  private compId: string = '';

  init(compParam: CompCtrlParam): void {
    this.compId = compParam.compId ?? '';
    this.refreshName();
  }

  destroy(): void {
  }

  onPageShow(): void {
    this.refreshName();
  }

  private refreshName(): void {
    usersAccountController.refreshCurrentLoginName();
  }
}

export class UsersAccountsPageController implements ComponentControl {
  private settingPageModel?: SettingPageModel;

  init(compParam: CompCtrlParam): void {
    if (compParam) {
      this.settingPageModel = compParam.component as SettingPageModel;
    }
    this.addUserGroup();
  }

  destroy(): void {
  }

  onPageShow(_component: SettingBaseModel): void {
    usersAccountController.refreshCurrentLoginName();
  }

  private addUserGroup(): void {
    let model: SettingGroupModel = {
      id: 'users_account_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      header: {
        id: 'users_account_header',
        content: $r('app.string.user_list_title'),
      },
      items: [
        {
          id: CURRENT_LOGIN_ITEM_ID,
          type: ItemType.ITEM_TYPE_STANDARD,
          title: {
            content: $r('app.string.current_login_title')
          },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: { content: '' }
          },
          detail: {
            type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
            icon: $r('sys.symbol.chevron_right'),
            isSymbolIcon: true,
            destination: NavEntryKey.USER_SETTING_ENTRY,
          },
          compControl: new CurrentLoginItemController(),
        }
      ]
    };
    this.settingPageModel?.groups?.push(model);
  }
}
