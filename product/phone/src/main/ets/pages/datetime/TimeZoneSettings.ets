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
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import Want from '@ohos.app.ability.Want';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { TimeZoneMenuPageComponent } from './model/TimeZoneComponent';
import { TimeZonePage } from './model/TimeZonePage';

/* instrument ignore file */
const TAG: string = 'TimeZoneSettings : ';

@Builder
export function TimeZoneSettingsLoader($$: Params): void {
  TimeZoneSettings();
}

@Component
export struct TimeZoneSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  title: string = ResourceUtil.getStringSync($r('app.string.time_zone_settings_title'));

  build() {
    NavDestination() {
      Column() {
        TimeZoneMenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: { title: { mainTitle: this.title } }
    // })
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new TimeZonePage(this.pathInfos));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  onBackPress(): void {
    if (AppStorage.get<boolean>('isWorldClock')) {
      LogUtil.info(`${TAG} onBackPress world_clock`);
      let want:Want = {
        bundleName: 'com.ohos.clock',
        abilityName: 'com.ohos.clock.phone',
        parameters: {
          cityId: '',
        },
      };
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want);
    } else {
      this.pathInfos?.pop();
    }
  }
}

