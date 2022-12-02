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
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubEntryComponentWithEndText } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';

/**
* System account home page.
 */
@Entry
@Component
struct UsersAccounts {
  @StorageLink("accountName") accountName: string = "";

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          // head
          HeadComponent({ headName: $r("app.string.usersAccountsTab"), isActive: true });

          SubHeader({ titleContent: $r('app.string.user') });

          // current user subEntry
          SubEntryComponentWithEndText({
            targetPage: "pages/multipleUsers",
            title: $r("app.string.currentLogin"),
            endText: $accountName
          });
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  onPageShow() {
    LogUtil.info("User account page on show.");
    SystemAccount.updateAccountName(name => {
      AppStorage.SetOrCreate("accountName", name)
    });
  }
}