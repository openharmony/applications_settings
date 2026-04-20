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
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DateAndTimeUtil } from '@ohos/settings.datetime/src/main/ets/utils/DateAndTimeUtil';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DateAndTimePage } from './model/DateAndTimePage';
import { PageUrl } from '../PageUrl';

/* instrument ignore file */
const TAG: string = 'DateAndTimeSettings : ';

/**
 * Date and time settings
 */
@Builder
export function DateAndTimeSettingsLoader($$: Params): void {
  DateAndTimeSettings({ params: $$ as Object as PushParam });
}

@Component
export struct DateAndTimeSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.date_time_settings_title'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  private context = getContext(this) as common.UIAbilityContext;
  isFromExternal: boolean = false;
  @State params: PushParam | null = null;

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage }).margin({bottom: $r('app.float.navigation_56')});
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
      DateAndTimeUtil.recordCurrentDate();
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
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.ENTER_DATE_TIME,
      'pageUrl: ' + PageUrl.DATE_TIME_PAGE_URL);
    this.pageRoot.aboutToAppear(new DateAndTimePage(this.pathInfos, this.params as PushParam));
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

