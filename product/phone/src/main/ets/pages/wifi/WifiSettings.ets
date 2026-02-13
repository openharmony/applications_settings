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

import common from '@ohos.app.ability.common';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageUrl } from '../PageUrl';
import { WifiPage } from './model/WifiPage';
import { WifiMenuPageComponent } from './WifiMenuPageComponent';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { HiSysWlanEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'WifiSettings : ';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';

@Builder
export function WifiSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} wifi settings loader`)) {
    WifiSettings();
  }
}

@Component
export struct WifiSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  title: string = ResourceUtil.getStringSync($r('app.string.wifi_settings_title'));
  private context = getContext(this) as common.UIAbilityContext;
  isFromExternal: boolean = false;

  build() {
    NavDestination() {
      WifiMenuPageComponent({ menuPage: this.pageRoot.menuPage });
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({
    //   content: {
    //     title: {
    //       mainTitle: this.title
    //     },
    //     menu: {
    //       value: [
    //         {
    //           content: {
    //             icon: $r('app.media.ic_public_more'),
    //             label: 'app.string.wifi_install_certificates',
    //             isEnabled: false,
    //             action: () => {
    //               this.jumpToCertificatePage();
    //             }
    //           }
    //         }
    //       ]
    //     }
    //   }
    // })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.info(`${TAG} onBackPressed`);
        this.termiteAbility();
      }
      return this.isFromExternal;
    })
  }

  @Builder pageMenu(): void {
    Button({ type: ButtonType.Circle, stateEffect: true }){
      Image($r('app.media.ic_public_more'))
        .width('24vp')
        .height('24vp')
        .fillColor($r('sys.color.icon_primary'))
    }
    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
    .width('40vp')
    .height('40vp')
    .margin({
      right: '24vp',
      top: '8vp',
    })
    .draggable(false)
    .bindMenu(this.menuBuilder(), { placement: Placement.BottomRight })
  }

  @Builder
  menuBuilder() {
    Menu() {
      MenuItem({ content: $r('app.string.wifi_install_certificates') })
        .onClick(() => {
          this.jumpToCertificatePage();
        })
        .id(`${TAG}_MenuItem_01`)
        .width('192vp')
    }.id(`${TAG}_Menu_01`)
  }

  private jumpToCertificatePage(): void {
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    DynamicLoader.getInstance().fire(NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY).then(() => {
      pathInfoStack?.pushPathByName(NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY, undefined);
    });
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('OOBEWifi', false);
    LogUtil.info(`${TAG} aboutToAppear`);
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, 'pageUrl: ' + PageUrl.WIFI_PAGE_URL);
    this.pageRoot.aboutToAppear(new WifiPage(this.pathInfos));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysWlanEventGroup.INTO_WLAN);
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
    AbilityUtils.pageReportCallback(TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }
}
