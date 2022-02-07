// @ts-nocheck
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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import SystemAccount from '../model/usersAndAccounts/systemAccountModel.ets'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import router from '@system.router';

@Entry
@Component
struct UsersAccounts {
  @State accountName: string = "";

  build() {
    Column() {
      // head
      HeadComponent({ headName: $r("app.string.usersAccountsTab"), isActive: true });
      // current user
      UserComponent({ accountName: this.accountName });
    }
  }

  onPageShow() {
    LogUtil.info("User account page on show.");
    SystemAccount.updateAccountName(name => {
      this.accountName = name;
    });
  }
}

@Component
struct UserComponent {
  @Prop accountName: string;

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
      Text($r('app.string.user'))
        .margin({ left: $r('app.float.wh_value_20'), bottom: $r('app.float.wh_value_12') })
        .fontSize($r('app.float.font_24'))
        .fontColor(Color.Black)

      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text($r("app.string.currentLogin"))
          .fontSize($r("app.float.font_24"))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .align(ItemAlign.Start)
          .width(ConfigData.WH_40_100)
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.End }) {
          Text(this.accountName)
            .fontSize($r("app.float.font_24"))
            .fontColor(Color.Black)
            .align(Alignment.Start)
            .margin({ right: $r("app.float.wh_value_5") })
          Image($r("app.media.ic_settings_arrow"))
            .width($r("app.float.wh_value_20"))
            .height($r("app.float.wh_value_20"))
        }
      }
      .margin({ left: $r("app.float.wh_value_20"), right: $r("app.float.wh_value_20") })
      .height($r("app.float.wh_value_70"))
      .onClick(() => {
        router.push({ uri: "pages/multipleUsers" })
      })
    }
    .width(ConfigData.WH_100_100)
  }

  aboutToAppear() {
    LogUtil.info("User account about to appear.")
  }
}