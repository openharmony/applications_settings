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
import { PADDING_6, PADDING_2, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  SettingIconStyle,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { AppListLoader } from '../AppListLoader';
import { AppEntry, AppType } from '../AppModel';

export interface appCloneBadgeParam {
  iconStyle: SettingIconStyle,
  iconMargin: LocalizedPadding,
  icon: ResourceStr
}

export class DefaultAncoBadgeStyle {
  public width: number = 20;
  public height: number = 16;
  public offsetX: number = -4;
  public offsetY: number = -4;
}

const TAG = 'AppCloneBadgeComponent: ';
const ICON_DEFAULT_SIZE: number = 54;

@Component
export struct AppCloneBadgeComponent {
  appCloneBadgeParam: SettingItemModel | null = null;
  iconStyle: SettingIconStyle = this.getIconStyle();
  @State icon?: ResourceStr | PixelMap | null = null;
  entry: AppEntry | null = null;
  isNeedEndPadding: boolean = true;
  @Prop appIndex: number = 0;
  @Prop @Watch('onEntryChange') bundleName: string;
  @State isNeedRefresh: number = 1;
  iconSize: number = ICON_DEFAULT_SIZE;
  private badgeStyle: DefaultAncoBadgeStyle = new DefaultAncoBadgeStyle();
  private scaleSize: number = 1;
  private isLtr: boolean = LanguageUtils.isLtrDirection();

  async onEntryChange(): Promise<void> {
    LogUtil.info(`${TAG} onEntryChange, ${this.bundleName} ${this.appIndex}`);
    if (this.bundleName) {
      // 外部跳转时需要刷新图标数据，避免缓存还未获取到导致图标不显示
      this.entry = await AppListLoader.getInstance().createAndCache(this.bundleName,
        this.appIndex ?? 0) as AppEntry;
      this.icon = this.entry?.icon;
      this.appIndex = this.entry?.appIndex as number;
      this.isNeedRefresh++;
    }
  }

  build() {
    RelativeContainer() {
      if (this.isNeedRefresh) {
        Image(this.icon)
          .iconStyle(this.iconStyle)
          .fillColor(this.iconStyle.fillColor)
          .id('baseIcon')

        if (this.appIndex) {
          // 分身应用的角标
          Image($r(`app.media.app_icon_clone_index_${this.appIndex}`))
            .height('18vp')
            .width('18vp')
            .offset({ start: PADDING_6, top: PADDING_2 })
            .alignRules({
              right: { anchor: 'baseIcon', align: HorizontalAlign.End },
              bottom: { anchor: 'baseIcon', align: VerticalAlign.Bottom },
            })
        }
      }
    }
    .width(this.iconStyle.width)
    .height(this.iconStyle.height)
    .borderRadius(16)
    .clip(true)
    .margin({ end: this.isNeedEndPadding ? PADDING_16 : LengthMetrics.vp(0) })
  }

  aboutToAppear(): void {
    if (this.appCloneBadgeParam) {
      this.iconStyle = this.appCloneBadgeParam?.icon?.style as SettingIconStyle;
      this.entry = this.appCloneBadgeParam?.extra as AppEntry;
    }
    this.icon = this.entry?.icon as ResourceStr;
    this.appIndex = this.entry?.appIndex as number;
    this.bundleName = this.entry?.name as string;
    LogUtil.info(`${TAG} aboutToAppear ${this.bundleName}, ${this.appIndex}`);

    this.scaleSize = this.iconSize / ICON_DEFAULT_SIZE;
    this.badgeStyle.width = this.badgeStyle.width * this.scaleSize;
    this.badgeStyle.height = this.badgeStyle.height * this.scaleSize;
    this.badgeStyle.offsetX = this.badgeStyle.offsetX * this.scaleSize;
    this.badgeStyle.offsetY = this.badgeStyle.offsetY * this.scaleSize;
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 64,
      height: 64,
      mirrored: false,
      interpolation: ImageInterpolation.Medium
    };
    return style;
  }
}

@Extend(Image)
function iconStyle(style: SettingIconStyle) {
  .width(style.width)
  .height(style.height)
  .objectFit(style.objectFit)
  .borderRadius(style.borderRadius || $r('sys.float.corner_radius_level6'))
  .draggable(style.draggable)
  .interpolation(style.interpolation)
  .edgeAntialiasing(style.edgeAntialiasing)
  .border(style.border)
  .clip(style.clip)
  .syncLoad(true)
  .matchTextDirection(style.mirrored)
  .accessibilityText(style?.accessibilityText)
  .accessibilityLevel(style?.accessibilityLevel)
}