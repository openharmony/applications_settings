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

import { bundleManager } from '@kit.AbilityKit';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_12,
  PADDING_16,
  PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingAppGroupModel } from '../model/SettingAppItemModel';
import { AppEntry, AppType } from '../AppModel';
import { AppCloneBadgeComponent } from './AppCloneBadgeComponent';
import { AppListLoader } from '../AppListLoader';

const TAG: string = 'AppItemHeaderComponent: ';

@Component
export struct AppItemHeaderComponent {
  @State entry: AppEntry | null = null;
  @State isAppEnable: boolean = true;
  @State bundleName: string = '';
  @State appIndex: number = 0;
  @State description?: string = '';
  private appId?: string;
  private appItem: SettingAppGroupModel | null = null;

  build() {
    Row() {
      AppCloneBadgeComponent({
        iconStyle:{
          border: { width: '0px', color: '#00000000', radius: 0 },
          borderRadius: 0,
          width: 64,
          height: 64,
          mirrored: false,
          interpolation: ImageInterpolation.Medium,
          draggable: false
        } as SettingIconStyle,
        bundleName: this.bundleName,
        appIndex: this.appIndex,
        entry: this.entry,
        iconSize: 64,
        isNeedEndPadding:false
      })
        .accessibilityDescription(this.description)
        .onClick(() => {
          this.jumpToAppGallery();
        })

      Column() {
        Text(this.entry?.label)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(this.getVersionName(this.entry))
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .margin({ start: PADDING_16 })
      .padding({ end: PADDING_8 })
      .width('calc(100% - 80vp)')
      .accessibilityGroup(true)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: PADDING_8, bottom: PADDING_8 })
    .borderRadius($r('sys.float.corner_radius_level4'))
    .margin({ bottom: $r('app.float.margin_16') })
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear ${this.appItem?.bundleName}`);
    this.initEntry();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private async initEntry(): Promise<void> {
    this.entry = this.appItem?.entry as AppEntry;
    this.getAppId();
  }

  private getAppId(): void {
    let bundleName = this.entry?.name;
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE;
    try {
      bundleManager.getBundleInfo(bundleName, bundleFlags).then((data) => {
        this.appId = `C${data.signatureInfo.appIdentifier}`;
        LogUtil.info(`${TAG} appId success ${this.appId}`);
        this.description = this.needJump() ? '' : ' ';
      });
    } catch (err) {
      LogUtil.error(`${TAG} getBundleInfo failed ${err?.message}`);
    }
  }

  private jumpToAppGallery() {
    LogUtil.info(`${TAG} jumpToAppGallery ${this.appId} ${this.entry?.appInfo?.systemApp}`);
    if (this.needJump()) {
      const URL: string = ResourceUtil.getStringSync($r('app.string.app_gallery_link'));
      let targetUrl = `${URL}${this.appId}`;
      AbilityUtils.startAbilityForResult({
        bundleName: 'com.ohos.appgallery',
        abilityName: 'MainAbility',
        uri: targetUrl
      }, () => {
        LogUtil.info(`${TAG} jumpToAppGallery success ${this.appId}`);
      });
    }
  }

  private needJump(): boolean {
    return !(!this.appId || !this.entry || this.entry?.appInfo?.systemApp ||
      (AppListLoader.getInstance().getAppType(this.entry) === AppType.CONTAINER_APP) ||
      (AppListLoader.getInstance().getAppType(this.entry) === AppType.SERVICE_APP));
  }

  private getVersionName(entry: AppEntry | null): string {
    return ResourceUtil.getFormatStringSync($r('app.string.app_info_version'), entry?.versionName as string);
  }
}