import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Ability from '@ohos.application.Ability'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        LogUtil.info(ConfigData.TAG + 'Application onCreate')
        globalThis.abilityWant = want;
        globalThis.settingsAbilityContext =this.context
    }

    onDestroy() {
        AppStorage.SetOrCreate('settingsList', []);
        LogUtil.info(ConfigData.TAG + 'Application onDestroy')
    }

    onWindowStageCreate(windowStage) {
        // Main window is created, set main page for this ability
        console.log("[Demo] MainAbility onWindowStageCreate")

        windowStage.setUIContent(this.context, "pages/settingList", null)
        globalThis.settingsAbilityContext =this.context
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        console.log("[Demo] MainAbility onWindowStageDestroy")
    }

    onForeground() {
        // Ability has brought to foreground
        console.log("[Demo] MainAbility onForeground")
    }

    onBackground() {
        // Ability has back to background
        console.log("[Demo] MainAbility onBackground")
    }
};
