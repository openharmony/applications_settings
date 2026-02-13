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
import {
  CommonBadgeStyle,
  ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  NavigationEntryMenuStyle,
  StateIconStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { SettingBadgeStyle } from '@ohos/settings.uikit/src/main/ets/styles/SettingBadgeStyle';

let stateIconStyle = new StateIconStyle();
let originStateIconMarginLeft = stateIconStyle.margin?.left;

class StateContainerStyle extends ContainerStyle {
  public margin: Margin = {
    left: undefined
  }
}
let stateContainerStyle = new StateContainerStyle();

let settingBadgeStyle = new SettingBadgeStyle();

/**
 * 软件更新目录样式
 *
 * @since 2023-12-08
 */
export class SoftwareUpdateBadgeMenuStyle extends NavigationEntryMenuStyle {
  public stateIcon: ImageStyle = stateIconStyle;
  public stateContainer: ContainerStyle = stateContainerStyle;
  public secondStateContainer: ContainerStyle = stateContainerStyle;
  public badge: CommonBadgeStyle = settingBadgeStyle;

  private setBadgeMarginRight: (badgeCount: number) => void = (badgeCount: number) => {
    this.badge.setMarginRight(badgeCount);
  };

  private setBadgePaddingRight: (badgeCount: number) => void = (badgeCount: number) => {
    this.badge.setPaddingRight(badgeCount);
  }

  private setStateIconMarginLeft(menu: SettingsBaseMenu | undefined): void {
    // 还原 无badge时的样式
    if (!menu) {
      stateIconStyle.margin.left = originStateIconMarginLeft;
      return;
    }
    // 有badge时的样式
    if (!menu?.state && this.stateIcon?.margin?.left) {
      stateIconStyle.margin.left = '0vp';
    }
  }

  private setStateContainerMarginLeft(badgeCount: number | undefined): void {
    // 还原 无badge时的样式
    if (!badgeCount) {
      stateContainerStyle.margin.left = undefined;
      return;
    }
    // 有badge时的样式
    if (badgeCount) {
      stateContainerStyle.margin.left = '0vp';
    }
  }

  /**
   * 根据是否有角标，更改样式
   *
   * @param menu 目录
   */
  changeStyle(menu: SettingsBaseMenu): void {
    if (menu?.badge) {
      this.setBadgeMarginRight(menu?.badge);
      this.setBadgePaddingRight(menu?.badge);
      this.setStateIconMarginLeft(menu);
      this.setStateContainerMarginLeft(menu?.badge);
    } else {
      this.setStateIconMarginLeft(undefined);
      this.setStateContainerMarginLeft(undefined);
    }
  }
}