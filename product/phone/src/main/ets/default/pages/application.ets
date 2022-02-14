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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import {SubEntryComponent} from '../../../../../../../common/component/src/main/ets/default/subEntryComponent.ets';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil.ets';

/**
 * Application
 */
@Entry
@Component
struct Application {
  @State columnMargin: string = '24vp';
  private TAG = `${ConfigData.TAG} Application`;

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.applyTab'), isActive: true })
      Column({space: this.columnMargin}){
        SubEntryComponent({targetPage:'pages/appManagement', title:$r('app.string.appManagement')})
      }
      .width(ConfigData.WH_100_100)
    }
    .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_E3E3E3_grey"));
  }

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    ResourceUtil.getString($r('app.float.distance_24')).then(value => this.columnMargin = value);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}