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

import Want from '@ohos.application.Want';
import netQuality from '@hms.networkboost.netquality';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { getNetworkNavigatorLink } from '../controller/NetworkNavigatorEntryController';
/* instrument ignore file */
const TAG: string = 'HintComponent : ';
const LAST_INDEX: number = 4;
export function getIntroductionByNetScenario(scenario: netQuality.NetScenarioType): string[] {
  let subtext1: string = '';
  let subtext2: string = '';
  let subtext3: string = '';
  switch (scenario) {
    case netQuality.NetScenarioType.SCENARIO_ELEVATOR:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_elevator_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 6);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 5);
      break;
    case netQuality.NetScenarioType.SCENARIO_LEAVE_HOME_WLAN_OFF:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_leave_home_wlan_off_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 4);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 3);
      break;
    case netQuality.NetScenarioType.SCENARIO_ARRIVE_HOME_WLAN_ON:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_arrive_home_wlan_on_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 3);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 3);
      break;
    case netQuality.NetScenarioType.SCENARIO_CROWDED_CAFETERIA:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_crowded_cafeteria_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 3);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 5);
      break;
    case netQuality.NetScenarioType.SCENARIO_LOW_SIGNAL_PARKING:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_low_signal_parking_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 3);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 5);
      break;
    case netQuality.NetScenarioType.SCENARIO_SUBWAY:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_subway_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 5);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 5);
      break;
    case netQuality.NetScenarioType.SCENARIO_HIGH_SPEED_RAIL:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_high_speed_rail_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 5);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 10);
      break;
    case netQuality.NetScenarioType.SCENARIO_HIGHWAY_DRIVING:
      subtext1 = ResourceUtil.getStringSync($r('app.string.scenario_highway_driving_introduction'));
      subtext2 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_phase_num'), 5);
      subtext3 = ResourceUtil.getPluralStringValueSync($r('app.plural.network_simulation_total_time'), 5);
      break;
    default:
      break;
  }
  return [subtext1, subtext2, subtext3];
}

@Component
export struct HintComponent {
  @Prop scenarioType: netQuality.NetScenarioType;
  tag: string = 'HintComponent: ';
  introduction: string = '';
  text0: ResourceStr = ''
  text1: ResourceStr = $r('app.string.detailed_network_parameters');
  text2: ResourceStr = '';
  text3: ResourceStr = $r('app.string.network_navigator_tips_link');

  @Consume('pathInfos') pathInfos: NavPathStack;
  @State isShow: boolean = true;
  @State inputValue: string = '';

  private isGrayed: boolean = PreferencesUtil.getSync('DeviceNameSettings', false) as boolean;

  build() {
    Scroll() {
      Text() {
        Span(this.text0)
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))

        Span(this.text1)
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isGrayed ? $r('sys.color.font_secondary') : $r('sys.color.font_emphasize'))
          .onClick(() => {
            this.onEntryClick();
            LogUtil.info(`detailed network parameters onclick, isShow: ${this.isShow}`);
          })

        Span('\n')
          .width('100%')

        Span(this.text2)
          .fontSize($r('sys.float.Body_M'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))

        Span(this.text3)
          .fontSize($r('sys.float.Body_M'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isGrayed ? $r('sys.color.font_secondary') : $r('sys.color.font_emphasize'))
          .onClick(() => {
            this.onEntryClick();
            LogUtil.info(`network navigator tips link onclick, isShow: ${this.isShow}`);
          })
      }
      .enabled(!this.isGrayed)
      .visibility(Visibility.Visible)
      .textAlign(TextAlign.JUSTIFY)
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
    }
    .scrollBar(BarState.Off)
    .constraintSize({maxHeight: '65%'})
  }

  private transFormResource(): void {
    let result: string =
      ResourceUtil.getAnyNumFormatStringSync($r('app.string.network_code_development_suggestions'), 10);
      if (result.length > LAST_INDEX) {
        this.text2 = result.slice(0, result.length - LAST_INDEX);
      } else {
        this.text2 = '';
      }
    return;
  }

  private async onEntryClick(): Promise<void> {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.ENTER_PRIVACY_STATEMENT_ENTRY);
    LogUtil.info(`${this.tag} onEntryClick`);
    let uriAddress: string = await getNetworkNavigatorLink();
    if (CheckEmptyUtils.checkStrIsEmpty(uriAddress)) {
      LogUtil.showError(TAG, 'on openBrowser uriAddress is empty');
      return;
    }
    let want: Want = {
      'bundleName': 'com.ohos.browser',
      'abilityName': 'MainAbility',
      'action': 'ohos.want.action.viewData',
      'entities': ['entity.system.browsable'],
      'uri': uriAddress,
    };
    AbilityUtils.startAbility(want);
  }

  aboutToAppear(): void {
    LogUtil.showInfo(this.tag, `aboutToAppear, isGrayed: ${this.isGrayed}`);
    this.transFormResource();
    let textAll: string[] = getIntroductionByNetScenario(this.scenarioType);
    this.text0 = ResourceUtil.getAnyStrFormatStringSync($r('app.string.network_simulation_total_introduction'),
      textAll[0], textAll[1], textAll[2], '');
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}