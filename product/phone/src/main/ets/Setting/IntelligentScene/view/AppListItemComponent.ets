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

import { LengthMetrics } from '@ohos.arkui.node';
import {
  PADDING_0,
  PADDING_2,
  PADDING_4,
  PADDING_6,
  PADDING_8,
  PADDING_12,
  PADDING_16,
  PADDING_24,
  PADDING_72,
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
/* instrument ignore file */
import { AppInfo } from '../model/bean/AppInfo';

@Component
export struct AppListItemComponent {
  totalCount: number = 0;
  index: number = 0;
  tag: string = 'AppListItemComponent';
  item?: AppInfo;
  isSelectedList?: boolean;
  isSearchList?: boolean;
  itemEnd?: LengthMetrics;
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
        if (this.isAppCloneBadge(this.item)) {
          RelativeContainer() {
            Image(this.item?.icon == undefined ? $r('app.media.notification_icon') : this.item.icon)
              .id('baseIcon')
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Contain)
              .draggable(false)

            // 分身应用的角标
            Image($r(`app.media.app_icon_clone_index_${this.item?.appIndex}`))
              .height('18vp')
              .width('18vp')
              .offset({ start: PADDING_6, top: PADDING_2 })
              .alignRules({
                right: { anchor: 'baseIcon', align: HorizontalAlign.End },
                bottom: { anchor: 'baseIcon', align: VerticalAlign.Bottom },
              })
          }
          .width('48vp')
          .height('48vp')
        } else {
          Row() {
            Image(this.item?.icon == undefined ? $r('app.media.notification_icon') : this.item.icon)
              .width('100%')
              .height('100%')
              .borderRadius(12)
              .objectFit(ImageFit.Contain)
              .draggable(false)
          }
          .width('48vp')
          .height('48vp')
        }

        Column() {
          Text(this.item?.label)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ start: PADDING_16 })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        this.toggleView();
      }
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
      .padding({
        start: PADDING_8,
        end: this.itemEnd ?? PADDING_8,
        top: FontScaleUtils.getSafetyPadding(),
        bottom: FontScaleUtils.getSafetyPadding(),
      })
      .stateStyles({
        pressed: {
          .backgroundColor(this.isSelectedList ? Color.Transparent : $r('sys.color.interactive_click'))
          .borderRadius($r('sys.float.corner_radius_level8'))
        },
        normal: {
          .backgroundColor(this.hoverItem === this.item?.label && this.isHover ?
          $r('sys.color.interactive_hover') : Color.Transparent)
          .borderRadius($r('sys.float.corner_radius_level8'))
        }
      })
      .onHover((hover: boolean) => {
        this.isHover = hover;
        this.hoverItem = this.item?.label as string;
      })

      if (!this.isLastItem()) {
        Divider()
          .color($r('sys.color.comp_divider'))
          .strokeWidth('1px')
          .margin({
            start: PADDING_72,
            end: this.itemEnd ?? PADDING_6,
          })
      }
    }
    .padding({
      top: this.isFirstItem() ? PADDING_4 : PADDING_0,
      bottom: this.isLastItem() ? PADDING_4 : PADDING_0,
    })
    .margin({
      start: PADDING_12,
      end: this.isSearchList || this.isSelectedList ? PADDING_12 : PADDING_24,
    })
  }

  aboutToAppear(): void {
    EventBus.getInstance().on('intelligenceAppInfoRefresh', this.dataChangeCallBack);
    LogUtil.info(`${this.tag} ${this.item?.name} aboutToAppear`);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach('intelligenceAppInfoRefresh', this.dataChangeCallBack);
    LogUtil.info(`${this.tag} ${this.item?.name} aboutToDisappear`);
  }

  private isFirstItem(): boolean {
    return this.index === 0;
  }

  private isLastItem(): boolean {
    return this.index === this.totalCount - 1;
  }

  private isAppCloneBadge(appInfo?: AppInfo): boolean {
    const appIndex: number = appInfo?.appIndex || 0;
    // 分身应用个数最大是5
    return appIndex > 0 && appIndex <= 5;
  }
}