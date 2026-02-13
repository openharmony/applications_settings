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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ContainerStyle, ImageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  DefaultEntryMenuStyle,
  NewTitleTextStyle,
  RootContainerStyle,
  StateIconStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { WifiListBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiListBaseController';
import { ApMenu, ApMenuData } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { wifiTracker } from '@ohos/settings.wifi/src/main/ets/WifiTracker';
import {
  SCAN_INTERVAL,
  SCAN_LOADING_INTERVAL,
  SETTINGS_SWITCH_WLAN_LOGS,
  WifiUtils
} from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiEntryController } from './WifiEntryController';

/* instrument ignore file */
const TAG: string = 'WifiListController : ';

/**
 * Wifi 列表加载控制器
 *
 * @since 2022-03-21
 */
@Observed
export class WifiListController extends WifiListBaseController {
  static CreateWifiListController(menu: SettingsBaseMenu): Controller {
    return new WifiListController(menu);
  }

  public isWlanLog: boolean = false;

  public scanList(): void {
    LogUtil.info(`${TAG} wifi state refresh : `);
    this.startTimer();
    wifiTracker.scanAp();
  }

  public setListScrolling(isScroll: boolean): void {
    wifiTracker.setListScrolling(isScroll);
  }

  protected getScanInternal(): number {
    return SCAN_INTERVAL;
  }

  protected getScanLoadingInternal(): number {
    return SCAN_LOADING_INTERVAL;
  }

  protected createApMenu(item: Partial<ApMenuData>): ApMenu {
    let menu = new ApMenu(item);
    if (this.isWlanLog) {
      menu.state = WifiUtils.getWifiInfoDescription(item);
    }
    menu.style = wifiApStyle;
    menu.controller = {
      createControllerConstructorInter: WifiEntryController.createWifiEntryController,
    };
    menu.pathInfos = this.menu.pathInfos;
    return menu;
  }

  aboutToAppear(): void {
    this.isWlanLog = SettingsDataUtils.getSettingsData(SETTINGS_SWITCH_WLAN_LOGS, 'false') === 'true';
    super.aboutToAppear();
  }

  aboutToDisappear() {
    super.aboutToDisappear();
    this.setListScrolling(false);
  }
}

class ApStateIconStyle extends StateIconStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public borderRadius = 0;
  public margin: Margin = {};
  public imageFit = ImageFit.Contain;
  public fillColor = $r('sys.color.ohos_id_color_secondary');
}

class ApContainerStyle extends RootContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '64vp',
  };
  public padding: Padding = {
    left: $r('app.float.padding_8'),
  };
}

class WifiApStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new ApContainerStyle();
  public stateIcon: ImageStyle = new ApStateIconStyle();
  public title: WifiListTextStyle = new WifiListTextStyle();
  public homeSpacing: Length = FontScaleUtils.getCurrentTopPadding();
}

class WifiListTextStyle extends NewTitleTextStyle {
  public wordBreak: number = WordBreak.BREAK_ALL;
}

let wifiApStyle = new WifiApStyle();
