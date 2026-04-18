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

import wifiManager from '@ohos.wifiManager';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { WlanItemModel } from '../model/WlanItemModel';
import { WifiMenuManager } from '../WifiMenuManager';

/* instrument ignore file */
export const AVAILABLE_WLAN_DETAIL_CLICK_EVENT: string = 'AvailableWlanDetailClick';
export const OTHER_WLAN_CLICK_EVENT: string = 'OtherWlanClick';

const CLICK_WLAN_NAME: string = 'click_wlan_name';

@Component
export struct WlanItemResultComponent {
  public tag: string = 'WlanItemResultComponent : ';
  private hideDetailIcon: boolean = false;
  @State itemInfo: WlanItemModel | undefined = undefined;

  build() {
    Row() {
      if (this.showLxLink() && !this.hideDetailIcon) {
        Image($r('app.media.ic_hiLink_pro_network_logo'))
          .width($r('app.float.width_24'))
          .height($r('app.float.height_24'))
          .opacity(0.6)
          .objectFit(ImageFit.Contain)
          .margin({
            start: PADDING_8
          })
          .draggable(false)
          .fillColor($r('sys.color.icon_secondary'))
      }
      if (this.showHiLink() && !this.hideDetailIcon) {
          Image($r('app.media.ic_wifi_hilink'))
            .width($r('app.float.width_24'))
            .height($r('app.float.height_24'))
            .objectFit(ImageFit.Contain)
            .margin({
              start: PADDING_8
            })
            .draggable(false)
            .fillColor($r('sys.color.icon_secondary'))
      }
      if (!this.itemInfo?.isLoading && !this.hideDetailIcon) {
        Image($r('app.media.ic_public_detail'))
          .width($r('app.float.width_24'))
          .height($r('app.float.height_24'))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .margin({
            start: PADDING_8
          })
          .fillColor($r('sys.color.icon_secondary'))
          .responseRegion({ x: -12, y: -12, width: 48, height: 48 })
          .accessibilityText($r('app.string.check_the_detail'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => {
            this.onDetailClick();
          })
      }
      if (this.itemInfo?.isLoading) {
        LoadingProgress()
          .width($r('app.float.width_24'))
          .height($r('app.float.height_24'))
          .margin({
            start: PADDING_8
          })
          .id('loading_progress_wifi_list_group')
      }
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.End)
    .width('100%')
    .constraintSize({
      minHeight: DeviceUtil.isDevicePc() ? undefined : 44,
    })
  }

  aboutToAppear(): void {
    this.hideDetailIcon = WifiMenuManager.isInOObeStage() || WifiMenuManager.isExternalNetworkStage();
  }

  aboutToDisappear(): void {
  }

  onDetailClick(): void {
    if (this.isAvailableNetworks() || this.itemInfo?.accessPoint) {
      HiSysEventUtil.reportButtonEvent(CLICK_WLAN_NAME, '');
      EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CLICK_EVENT, this.itemInfo);
    } else {
      EventBus.getInstance().emit(OTHER_WLAN_CLICK_EVENT, this.itemInfo);
    }
  }

  private showHiLink(): boolean {
    if (this.itemInfo?.isLoading) {
      return false;
    }
    if (this.itemInfo?.accessPoint?.isHiLinkNetwork ?? this.itemInfo?.isHiLinkNetwork) {
      return true;
    }
    return false;
  }

  private showLxLink(): boolean {
    if (this.itemInfo?.isLoading) {
      return false;
    }
    if (this.itemInfo?.accessPoint?.isHiLinkProNetwork ?? this.itemInfo?.isHiLinkProNetwork) {
      return true;
    }
    return false;
  }

  private isAvailableNetworks(): boolean {
    return !CheckEmptyUtils.isEmpty(this.itemInfo?.config) ||
      this.itemInfo?.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN;
  }
}