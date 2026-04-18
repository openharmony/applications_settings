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

import Router from '@ohos.router';
import common from '@ohos.app.ability.common';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { TimeZoneExtensionPage } from './model/TimeZoneExtensionPage';
import { TimeZoneMenuPageComponent } from './model/TimeZoneComponent';
import Want from '@ohos.app.ability.Want';

/* instrument ignore file */
const TAG: string = 'TimeZoneSettings : ';

@Entry
@Component
struct TimeZoneSettingsExtensionPage {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());

  build() {
    Column() {
      TimeZoneMenuPageComponent({ menuPage: this.pageRoot.menuPage });
    }
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .size({ width: '100%', height: '100%' })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new TimeZoneExtensionPage());
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

  onBackPress(): boolean {
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
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
      Router.back();
    }
    return true;
  }
}

