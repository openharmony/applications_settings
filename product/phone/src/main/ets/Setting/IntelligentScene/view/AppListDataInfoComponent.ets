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

import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import {
  PADDING_0,
  PADDING_16,
  PADDING_2,
  PADDING_64,
  PADDING_8,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AppInfo } from '../model/bean/AppInfo';

/* instrument ignore file */
@Component
export struct AppListDataInfoComponent {
  totalCount: number = 0;
  index: number = 0;
  item?: AppInfo;
  isSelectedList?: boolean;
  @State isRefresh: boolean = false;
  @State hoverItem: string = '';
  @State isHover: boolean = false;
  private onAppItemClicked: (index: number, item: AppInfo) => void = () => {
  };
  private dataChangeCallBack = (name?: string, label?: string, isSelected?: boolean) => {
    if (name === this.item?.name && this.item && label === this.item?.label) {
      this.item.isSelected = isSelected ? true : false;
      this.isRefresh = !this.isRefresh;
    }
  };

  @Builder
  toggleView(): void {
    Checkbox()
      .width(24)
      .height(24)
      .padding(2)
      .borderRadius(48)
      .hitTestBehavior(HitTestMode.None)
      .selectedColor($r('sys.color.comp_background_emphasize'))
      .select(this.isRefresh ? this.item?.isSelected : this.item?.isSelected)
      .onChange((isOn: boolean) => {
        if (this.item && this.item.isSelected != isOn) {
          this.item.isSelected = isOn;
          this.onAppItemClicked(this.index, this.item);
        }
      })
      .margin({ start: PADDING_8 })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.item?.icon == undefined ? $r('app.media.app_uninstall_icon') : this.item.icon)
            .width('48vp')
            .height('48vp')
            .objectFit(ImageFit.Contain)
            .draggable(false)
        }
        .width('48vp')
        .height('48vp')

        Column() {
          Text(this.item?.label)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .lineHeight(21)
            .fontWeight(FontWeight.Medium)
            .margin({ start: PADDING_16 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)

        this.toggleView();
      }
      .padding({
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
      })
      .width('100%')
      .constraintSize({
        minHeight: '64vp'
      })
      .onClick(() => {
        if (this.item) {
          this.item.isSelected = !this.item.isSelected;
          this.isRefresh = !this.isRefresh;
          this.onAppItemClicked(this.index, this.item);
        }
      })
      if (this.index !== this.totalCount - 1) {
        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
          .margin({
            start: PADDING_64,
            end: PADDING_0
          })
      }
    }
    .stateStyles({
      normal: {
        .backgroundColor(this.hoverItem === this.item?.label && this.isHover ?
        $r('sys.color.interactive_hover') : Color.Transparent)
      },
      pressed: {
        .backgroundColor(this.isSelectedList ? Color.Transparent : $r('sys.color.ohos_id_color_click_effect'))
      },
    })
    .padding({
      start: PADDING_8,
      end: PADDING_8,
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
      this.hoverItem = this.item?.label as string;
    })
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  aboutToAppear(): void {
    EventBus.getInstance().on('intelligenceAppInfoRefresh', this.dataChangeCallBack);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach('intelligenceAppInfoRefresh', this.dataChangeCallBack);
  }
}