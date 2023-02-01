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

import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Ability from '@ohos.app.ability.UIAbility';

export default class MainAbility extends Ability {
    tag: string  = "ApplicationInfoSettings";
    windowStage;
    onCreate(want, launchParam) {
        LogUtil.info(this.tag + ' Application onCreate');
        globalThis.abilityWant = want;
        globalThis.settingsAbilityContext = this.context;
    }

    onDestroy() {
        LogUtil.info(this.tag + 'Application onDestroy')
    }

    onWindowStageCreate(windowStage) {
        // Main window is created, set main page for this ability
        LogUtil.info(this.tag + "  onWindowStageCreate is called");
        this.windowStage = windowStage;
        windowStage.setUIContent(this.context, "pages/applicationInfo", null);
    }

    onNewWant(want): void {
        globalThis.abilityWant = want;
        LogUtil.info(this.tag + " onNewWant is called");
        this.windowStage?.setUIContent(this.context, "pages/applicationInfo", null);
    }

};
