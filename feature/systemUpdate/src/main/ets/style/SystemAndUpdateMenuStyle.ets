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

import { CommonBadgeStyle, ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  DefaultEntryMenuStyle,
  IconImageStyle, RootContainerStyle56 } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { SettingBadgeStyle } from '@ohos/settings.uikit/src/main/ets/styles/SettingBadgeStyle';

class HomeRootContainerStyle extends RootContainerStyle56 {
  public space: Length = '8vp';
  public padding: Padding = {
    left: $r('app.float.padding_4'),
    right: $r('app.float.padding_4'),
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
  };
  public margin: Margin = {
    top: $r('app.float.margin_0'),
    bottom: $r('app.float.margin_0'),
    left: $r('app.float.margin_4'),
    right: $r('app.float.margin_4'),
  };
}

export class HomeIconImageStyle extends IconImageStyle {
  public margin: Margin = {
    right: $r('app.float.margin_12'),
    left:$r('app.float.margin_4')
  };
  public borderRadius: Length = '16vp';
}

class StateContainerStyle extends ContainerStyle {
  public margin: Margin = {
    left: undefined
  }
}

class HomeMenuTextStyle extends TextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_secondary');
  public overflow: TextOverflow = TextOverflow.Ellipsis;
  public margin: Margin = {
    top: '2vp',
  };
  public padding: Padding = { left: '10vp' }
  public maxLines: number = 1;
  public textAlign: TextAlign = TextAlign.End;
  public layoutWeight: number = 3;
}

export class HomeMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer = new HomeRootContainerStyle();
  public iconImage = new HomeIconImageStyle();
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
  public state: TextStyle = new HomeMenuTextStyle();
}

export class PhoneHomeMenuStyle extends HomeMenuStyle {
  public marginStatus: Margin = {
    left: '4vp',
    right: '4vp',
  }
}

let stateContainerStyle = new StateContainerStyle();

let stateTextStyle = new HomeMenuTextStyle();
let originStateMarginLeft = stateTextStyle?.margin?.left;

let settingBadgeStyle = new SettingBadgeStyle();



/**
 * 系统和更新目录样式
 *
 * @since 2024-04-29
 */
export class SystemAndUpdateMenuStyle extends PhoneHomeMenuStyle {
  public state: TextStyle = stateTextStyle;
  public stateContainer: ContainerStyle = stateContainerStyle;
  public badge: CommonBadgeStyle = settingBadgeStyle;

  private setBadgeMarginRight: (badgeCount: number) => void = (badgeCount: number) => {
    this.badge.setMarginRight(badgeCount);
  };

  private setBadgePaddingRight: (badgeCount: number) => void = (badgeCount: number) => {
    this.badge.setPaddingRight(badgeCount);
  }

  private setStateMarginLeft(badgeCount: number | undefined): void {
    // 还原 无badge时的样式
    if (!badgeCount) {
      stateTextStyle.margin.left = originStateMarginLeft;
      return;
    }
    // 有badge时的样式
    stateTextStyle.margin.left = '0vp';
  }

  private setStateContainerMarginLeft(menu: SettingsBaseMenu | undefined): void {
    // 还原 无badge时的样式
    if (!menu) {
      stateContainerStyle.margin.left = undefined;
      return;
    }
    // 有badge时的样式
    if (!(menu?.state) && menu?.stateIcon && menu?.badge) {
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
      this.setStateMarginLeft(menu?.badge);
      this.setStateContainerMarginLeft(menu);
    } else {
      this.setStateMarginLeft(undefined);
      this.setStateContainerMarginLeft(undefined);
    }
  }
}