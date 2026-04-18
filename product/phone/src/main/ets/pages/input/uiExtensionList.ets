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

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';

const TAG: string = 'UiExtensionList : ';
const INPUT: string = 'celia input';
@Builder
export function UiExtensionListLoader($$: Params): void {
  UiExtensionList({ params: $$ as object as PushParam });
}

@Component
export struct UiExtensionList {
  title: string = ResourceUtil.getStringSync($r('app.string.celia_input'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: 'com.ohos.inputmethod',
        abilityName: 'LanguageSettingAbility',
        parameters: {
          'ability.want.params.uiExtensionType' : 'sys/commonUI',
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
        }
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady`);
        })
        .onError((error) => {
          const code: number = error?.code;
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${code} message: ${error?.message}`);
          this.pathInfos.pop();
        })
        .onTerminated(() => {
          this.pathInfos.pop();
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
      // delay start page transition animation
      this.viewModel.delayTransition(150);
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.SELECT_DIFFERENT_INPUT_METHOD, INPUT);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToAppear, config: ${this.params?.config}, subUri: ${this.params?.subUri}`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}