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

import netQuality from '@hms.networkboost.netquality';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingContentState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CustomScenarioDataInputComponent } from '../view/CustomScenarioDataInputComponent';
import { CustomScenarioNameInputComponent } from '../view/CustomScenarioNameInputComponent';
/* instrument ignore file */
const TAG = 'NetworkNavigatorCustomController: ';
const INITIAL_VALUE: number = -1;
export const CUSTOM_SCENARIO_NAME_CHANGE_EVENT = 'CUSTOM_SCENARIO_NAME_CHANGE_EVENT';
export const CUSTOM_SCENARIO_DATA_CHANGE_EVENT = 'CUSTOM_SCENARIO_DATA_CHANGE_EVENT';
export const SHEET1: string = 'Sheet1';
export const SHEET2: string = 'Sheet2';
export const SHEET3: string = 'Sheet3';

export interface LoadingBuilderParam {
  title1: string;
  title2: string;
  placeholder1: string;
  placeholder2: string;
}

export let scenarioDataOut: netQuality.CustomNetScenarioDetails = {
  scenarioName: '',
  uplinkBandwidth: INITIAL_VALUE,
  downlinkBandwidth: INITIAL_VALUE,
  uplinkLatency: INITIAL_VALUE,
  downlinkLatency: INITIAL_VALUE,
  uplinkDropRate: INITIAL_VALUE,
  downlinkDropRate: INITIAL_VALUE
};

@Builder
export function CustomScenarioNameInputBuilder(param: object): void {
  CustomScenarioNameInputComponent({
    item: param,
  });
}

@Builder
export function CustomScenarioDataInputBuilder(param: object): void {
  CustomScenarioDataInputComponent({ param: param as SettingItemModel })
}

export class NetworkNavigatorCustomController implements ComponentControl {
  private settingPageModel?: SettingPageModel;
  private scenarioData: netQuality.CustomNetScenarioDetails = {
    scenarioName: '',
    uplinkBandwidth: INITIAL_VALUE,
    downlinkBandwidth: INITIAL_VALUE,
    uplinkLatency: INITIAL_VALUE,
    downlinkLatency: INITIAL_VALUE,
    uplinkDropRate: INITIAL_VALUE,
    downlinkDropRate: INITIAL_VALUE
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    scenarioDataOut = this.scenarioData;
    EventBus.getInstance().on(CUSTOM_SCENARIO_DATA_CHANGE_EVENT, this.customSceneDataChangeEventCallback);
    EventBus.getInstance().on(CUSTOM_SCENARIO_NAME_CHANGE_EVENT, this.customSceneNameChangeEventCallback);
    this.settingPageModel = compParam.component as SettingPageModel;
    let scenarioId: number | undefined = Number(AppStorage.get('sceneType'));
    if (scenarioId === undefined || Number.isNaN(scenarioId)) {
      scenarioId = 0;
    }
    let sheetName: string = '';
    if (scenarioId !== 0) {
      try {
        scenarioDataOut = netQuality.getNetSimulatorCustomScenarioDetails(scenarioId);
      } catch (err) {
        LogUtil.error(`${TAG} getNetSimulatorCustomScenarioDetails err:${err?.code}-${err?.message}`);
      }
      sheetName = scenarioDataOut.scenarioName;
    } else {
      sheetName = ResourceUtil.getStringSync($r('app.string.network_navigator_add_custom_scene'));
    }
    notifyCompStateChange(`${PageRouter.getRouterName()}.SheetPage.add_custom_scenario_config`,
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_TITLE,
        { content: sheetName } as SettingContentState]]
      ));
    this.addNameInputGroup();
    let scenarioDataList: number[] = [ scenarioDataOut.uplinkBandwidth, scenarioDataOut.downlinkBandwidth,
      scenarioDataOut.uplinkDropRate, scenarioDataOut.downlinkDropRate, scenarioDataOut.uplinkLatency,
      scenarioDataOut.downlinkLatency];
    PreferencesUtil.putSync(scenarioDataOut.scenarioName, scenarioDataList);
    this.addNetworkSimulationItem(SHEET1);
    this.addNetworkSimulationItem(SHEET2);
    this.addNetworkSimulationItem(SHEET3);
  }

  private addNameInputGroup(): void {
    let nameMenu: SettingGroupModel = {
      id: 'key_input_custom_scenario_name',
      type: GroupType.GROUP_TYPE_STANDARD,
      visible: true,
      layout: {
        backgroupColor: Color.Transparent
      },
      items: [
        {
          id: 'key_input_custom_scenario_name_item',
          type: ItemType.ITEM_TYPE_CUSTOM,
          builder: wrapBuilder(CustomScenarioNameInputBuilder),
          enabled: false,
        }
      ]
    };
    this.settingPageModel?.groups?.push(nameMenu);
  }

  private addNetworkSimulationItem(sheetid: string): void {
    let addScenarioModel: SettingGroupModel = {
      id: 'addNetworkSimulationItem',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: sheetid,
          type: ItemType.ITEM_TYPE_CUSTOM,
          builder: wrapBuilder(CustomScenarioDataInputBuilder),
        }
      ]
    };
    this.settingPageModel?.groups?.push(addScenarioModel);
  }

  protected customSceneDataChangeEventCallback = (sheetid: string, text1: string, text2: string) => {
    LogUtil.info(`${TAG} customSceneDataChangeEventCallback ${sheetid}, ${text1}, ${text2}`);
    if (text1 === '') {
      text1 = '-1';
    }
    if (text2 === '') {
      text2 = '-1';
    }
    if (sheetid === SHEET1) {
      this.scenarioData.uplinkBandwidth = Number(text1);
      this.scenarioData.downlinkBandwidth = Number(text2);
    } else if (sheetid === SHEET2) {
      this.scenarioData.uplinkDropRate = Number(text1);
      this.scenarioData.downlinkDropRate = Number(text2);
    } else if (sheetid === SHEET3) {
      this.scenarioData.uplinkLatency = Number(text1);
      this.scenarioData.downlinkLatency = Number(text2);
    }
    scenarioDataOut = this.scenarioData;
  };

  protected customSceneNameChangeEventCallback = (name: string) => {
    this.scenarioData.scenarioName = name;
    scenarioDataOut = this.scenarioData;
  };

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  destroy(): void {
    AppStorage.setOrCreate('sceneType', 0);
    EventBus.getInstance().detach(CUSTOM_SCENARIO_DATA_CHANGE_EVENT, this.customSceneDataChangeEventCallback);
    EventBus.getInstance().detach(CUSTOM_SCENARIO_NAME_CHANGE_EVENT, this.customSceneNameChangeEventCallback);
  }
}

