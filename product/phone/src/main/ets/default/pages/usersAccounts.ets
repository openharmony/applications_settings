/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import {SubEntryComponentWithEndText} from '../../../../../../../common/component/src/main/ets/default/subEntryComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import SystemAccount from '../model/usersAndAccounts/systemAccountModel.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import router from '@system.router';

/**
* System account home page.
 */
@Entry
@Component
struct UsersAccounts {
  @State accountName: string = "";

  build() {
    Column() {
      // head
      HeadComponent({ headName: $r("app.string.usersAccountsTab"), isActive: true })

      Text($r('app.string.user'))
        .padding({ left: $r('app.float.distance_24'), right: $r("app.float.distance_24") })
        .margin({ bottom: $r('app.float.distance_8') })
        .fontSize($r('app.float.font_18'))
        .fontColor(Color.Black)
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)

      // current user subEntry
      SubEntryComponentWithEndText({
        targetPage: "pages/multipleUsers",
        title: $r("app.string.currentLogin"),
        endText: this.accountName
      });
    }
    .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
    .align(Alignment.Center)
    .height(ConfigData.WH_100_100)
    .width(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_E3E3E3_grey"));
  }

  onPageShow() {
    LogUtil.info("User account page on show.");
    SystemAccount.updateAccountName(name => {
      this.accountName = name;
    });
  }
}