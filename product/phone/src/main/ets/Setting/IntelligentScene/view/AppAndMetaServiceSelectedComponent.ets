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

import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppInfo } from '../model/bean/AppInfo';
/* instrument ignore file */
import { AppListItemComponent } from './AppListItemComponent';

@Component
export struct AppAndMetaServiceSelectedComponent {
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {};
  @Link appGroups: AppInfoDataSource;

  build() {
    Column() {
      List({ space: 0, initialIndex: 0 }) {
        LazyForEach(this.appGroups, (item: AppInfo, index: number) => {
          ListItem() {
            AppListItemComponent({
              item: item,
              index: index,
              onAppItemClicked: this.onAppItemClicked,
              totalCount: this.appGroups.totalCount(),
              itemEnd: PADDING_8,
              isSelectedList: true,
            })
              .borderRadius({
                topLeft: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                topRight: this.isFirstItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomLeft: this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
                bottomRight:  this.isLastItem(index) ? $r('sys.float.corner_radius_level10') : 0,
              })
              .backgroundColor($r('sys.color.comp_background_list_card'))
          }
        }, (item: AppInfo, index: number) => (this.getId(item, index)))
      }
      .borderRadius($r('sys.float.corner_radius_level10'))
      .listDirection(Axis.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
  }

  private getId(item: AppInfo, index: number): string {
    let totalCount: number = this.appGroups.totalCount();
    let ifFirst: boolean = index === 0;
    let ifLast: boolean = index === totalCount - 1;
    return `${item.name}${item.isSelected}${ifFirst}${ifLast}`;
  }

  private isFirstItem(index: number): boolean {
    return index === 0;
  }

  private isLastItem(index: number): boolean {
    return index === this.appGroups.totalCount() - 1;
  }
}