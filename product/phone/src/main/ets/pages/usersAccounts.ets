/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import SystemAccount from '../model/usersAndAccounts/systemAccountModel';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubEntryComponentWithEndText } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import { OuterLayoutComponentNoParam } from '../../../../../../common/component/src/main/ets/default/outerLayoutComponent';

/**
* System account home page.
 */
@Entry
@Component
struct UsersAccounts {
  @State accountName: string = "";

  @Builder mUsersAccounts() {
    Column() {
      // head
      HeadComponent({ headName: $r("app.string.usersAccountsTab"), isActive: true });

      SubHeader({ titleContent: $r('app.string.user') });

      // current user subEntry
      SubEntryComponentWithEndText({
        targetPage: "pages/multipleUsers",
        title: $r("app.string.currentLogin"),
        endText: this.accountName
      });
    }
  }

  build() {
    Column(){
      OuterLayoutComponentNoParam({
        mContentComponentNoParam: this.mUsersAccounts
      })
    }
  }

  onPageShow() {
    LogUtil.info("User account page on show.");
    SystemAccount.updateAccountName(name => {
      this.accountName = name;
    });
  }
}