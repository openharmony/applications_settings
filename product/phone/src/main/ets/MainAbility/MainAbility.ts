/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

import Ability from '@ohos.app.ability.UIAbility';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { GlobalContext } from '../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalContext';

export default class MainAbility extends Ability {
  private funcAbilityWant;
  onCreate(want, launchParam) {
    LogUtil.info(ConfigData.TAG + 'Application onCreate')
    this.funcAbilityWant = want;
    GlobalContext.getContext().setObject(GlobalContext.globalKeyAbilityWant, want);
    GlobalContext.getContext().setObject(GlobalContext.globalKeySettingsAbilityContext, this.context);
  }

  onDestroy() {
    AppStorage.SetOrCreate('settingsList', []);
    LogUtil.info(ConfigData.TAG + 'Application onDestroy')
  }

  onWindowStageCreate(windowStage) {
    // Main window is created, set main page for this ability
    LogUtil.log("[Main] MainAbility onWindowStageCreate")
    let url = 'pages/settingList';
    if (this.funcAbilityWant?.parameters?.router && this.funcAbilityWant.parameters.router === 'volumeControl') {
      url = 'pages/volumeControl';
    }
    windowStage.setUIContent(this.context, url, null);
    GlobalContext.getContext().setObject(GlobalContext.globalKeySettingsAbilityContext, this.context);
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    LogUtil.log("[Main] MainAbility onWindowStageDestroy")
  }

  onForeground() {
    // Ability has brought to foreground
    LogUtil.log("[Main] MainAbility onForeground")
  }

  onBackground() {
    // Ability has back to background
    LogUtil.log("[Main] MainAbility onBackground")
  }
};
