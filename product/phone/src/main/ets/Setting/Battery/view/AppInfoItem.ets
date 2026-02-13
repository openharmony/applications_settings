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

/* instrument ignore file */
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import { SettingAppGroupModel } from '@ohos/settings.application/src/main/ets/model/SettingAppItemModel';
import { SettingIconStyle } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PADDING_12 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysBatteryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { BatteryParamUtil } from '../utils/BatteryParamUtil';

@Builder
export function appInfoItemBuilder(param: object): void {
  AppInfoItem({ item: param as SettingAppGroupModel });
}

const TAG: string = 'AppInfoItem:';

@Component
export struct AppInfoItem {
  item?: SettingAppGroupModel;
  @State icon: ResourceStr | PixelMap | undefined = undefined;
  @State title: ResourceStr = '';
  @State version: string = '';

  build() {
    Row() {
      if (!this.item?.entry) {
        Image(this.icon)
          .draggable(false)
          .size({
            height: 64,
            width: 64,
          })
      } else {
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
          bundleName: this.item.entry.name,
          appIndex: this.item.entry.appIndex,
          entry: this.item.entry,
          iconSize: 64,
          isNeedEndPadding:false
        })
      }

      Column() {
        Text(this.title)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .lineHeight(21)
        Text(this.version)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_M'))
          .lineHeight(19)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({
        start: PADDING_12,
      })
    }
    .accessibilityGroup(true)
    .width('100%')
    .padding({
      top: 8,
      bottom: 16,
      left: 8,
      right: 8,
    })
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} aboutToAppear`);
    const appPowerEntry = BatteryParamUtil.getAppPowerEntryFromPathInfo();
    this.icon = appPowerEntry?.icon;
    this.title = appPowerEntry?.title;
    this.version = ResourceUtil.getFormatStringSync($r('app.string.app_info_version'), appPowerEntry?.version);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysBatteryEventGroup.ENTER_APP_BATTERY_USAGE_DETAILS,
      `${this.title}`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}