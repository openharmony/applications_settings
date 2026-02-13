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

import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppListDataInfoComponent } from './AppListDataInfoComponent';
import { AppInfo } from '../model/bean/AppInfo';

/* instrument ignore file */
@Component
export struct AppSelectedGroupsComponent {
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {};
  @Link appGroups: AppInfoDataSource;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        LazyForEach(this.appGroups, (item: AppInfo, index: number) => {
          ListItem() {
            AppListDataInfoComponent({
              item: item,
              index: index,
              totalCount: this.appGroups.totalCount(),
              onAppItemClicked: this.onAppItemClicked,
              isSelectedList: true,
            })
          }
        }, (item: AppInfo) => (`${item.name}${item.isSelected}`))
      }
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
  }
}