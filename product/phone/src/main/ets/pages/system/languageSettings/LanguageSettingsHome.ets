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
import { MenuPageComponent } from '@ohos/settings.uikit';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LanguageSettingsHomePage } from '../model/LanguageSettingsHomePage';
import { LanguageAndRegionPage } from './languageAndRegion/LanguageAndRegionPage';

/* instrument ignore file */
const TAG: string = 'Settings LanguageSettings : ';

/**
 * Home Page Of Language Settings
 */
@Builder
export function LanguageSettingsHomeLoader($$: Params): void {
  LanguageAndRegionPage();
}

@Component
export struct LanguageSettingsHome {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  private context = getContext(this) as common.UIAbilityContext;
  isFromExternal: boolean = false;

  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new LanguageSettingsHomePage());
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    // 外部页面拉起一步返回
    if (this.isFromExternal) {
      LogUtil.info(`${TAG} from external, teminate ability`);
      this.termiteAbility();
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }
}

