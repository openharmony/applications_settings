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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { MenuPageComponent } from '@ohos/settings.uikit';
import OsAccount from '@ohos.account.osAccount';
import { fullExperienceData, objData } from './controller/otherInputRadioController';
import { InputSetting } from './model/inputSetting';

const TAG: string = 'InputSettings : ';

/**
 * InputSettings
 */
@Builder
export function InputSettingsLoader($$: Params): void {
  InputSettings({ params: $$ as Object as PushParam });
}

@Component
export struct InputSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.input'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  @State params: PushParam | null = null;

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        Row() {
          MenuPageComponent({ menuPage: this.pageRoot.menuPage });
        }
        .margin({bottom: $r('app.float.navigation_56')})
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      LogUtil.info(`${TAG} UIextension onPageShow`);
      this.onPageShow();
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} onPageHide`);
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new InputSetting(this.pathInfos, this.params as PushParam));
    this.initList();
  }

  private async initList(): Promise<void> {
    let curAccountInfo = await OsAccount.getAccountManager().getCurrentOsAccount();
    let userId = curAccountInfo.localId.toString();
    AppStorage.setOrCreate<string>('userId', userId);
    this.initenableImeList('settings.inputmethod.enable_ime', userId);
    this.initFullExperienceList('settings.inputmethod.full_experience', userId);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
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

  private async initenableImeList(key: string, userId: string): Promise<void> {
    let defaultInputRadioArrayObj: objData = {
      enableImeList: {}
    };
    let defaultInputSwitchArray: objData =
      JSON.parse(await SettingsDataUtils.getSettingsDataAsync(key, JSON.stringify(defaultInputRadioArrayObj)));
    if (defaultInputSwitchArray.enableImeList[userId] ===
      undefined || defaultInputSwitchArray.enableImeList[userId] === null) {
      defaultInputSwitchArray.enableImeList[userId] = [];
    }
    SettingsDataUtils.setSettingsDataAsync(key, JSON.stringify(defaultInputSwitchArray));
  }

  private async initFullExperienceList(key: string, userId: string): Promise<void> {
    let defaultInputRadioArrayObj: fullExperienceData = {
      fullExperienceList: {}
    };
    let defaultInputSwitchArray: fullExperienceData =
      JSON.parse(await SettingsDataUtils.getSettingsDataAsync(key, JSON.stringify(defaultInputRadioArrayObj)));
    if (defaultInputSwitchArray.fullExperienceList[userId] ===
      undefined || defaultInputSwitchArray.fullExperienceList[userId] === null) {
      defaultInputSwitchArray.fullExperienceList[userId] = [];
    }
    SettingsDataUtils.setSettingsDataAsync(key, JSON.stringify(defaultInputSwitchArray));
  }
}