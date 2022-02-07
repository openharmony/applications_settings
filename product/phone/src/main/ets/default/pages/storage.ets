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
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/entryComponent.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import StorageController from '../controller/storage/storageController.ets';

/**
 * Storage
 */
@Entry
@Component
struct Storage {
  @State storageList: any[] = [];
  private controller: StorageController = new StorageController();

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.storageTab'), isActive: true });
      // TODO need UX
      List() {
        ForEach(this.storageList, (item) => {
          ListItem() {
            EntryComponent({
              settingIcon: '',
              settingTitle: item.settingTitle,
              settingSummary: '',
              settingValue: item.settingValue,
              settingArrow: '',
              settingArrowStyle: '',
              settingUri: ''
            });
          }
        });
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.storage_common_margin'),
        endMargin: $r('app.float.storage_common_margin')
      })
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);
    }
  }

  aboutToAppear(): void{
    // bind component and initialize
    if (this.controller) {
      this.controller.bindComponent(this)
        .bindProperties(["storageList"])
        .initData();
    }
    LogUtil.info(ConfigData.TAG + 'aboutToAppear storageList in' + JSON.stringify(this.storageList));
  }
}



