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

import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubEntryComponent } from '../../../../../../common/component/src/main/ets/default/subEntryComponent';
import { OuterLayoutComponentNoParam } from '../../../../../../common/component/src/main/ets/default/outerLayoutComponent';

/**
 * Application
 */
@Entry
@Component
struct Application {
  private TAG = `${ConfigData.TAG} Application `;

  @Builder mApplication() {
    Column() {
      HeadComponent({ headName: $r('app.string.applyTab'), isActive: true })

      Column() {
        SubEntryComponent({ targetPage: 'pages/appManagement', title: $r('app.string.appManagement') })
      }
      .margin({ top: $r("app.float.distance_8") })
    }
  }

  build() {
    Column(){
      OuterLayoutComponentNoParam({
        mContentComponentNoParam: this.mApplication
      })
    }
  }

  aboutToAppear() {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}