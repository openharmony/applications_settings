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
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { scenarioDataOut } from '../controller/NetworkNavigatorCustomController';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { LoadingBuilderParam, CUSTOM_SCENARIO_DATA_CHANGE_EVENT,
  SHEET1, SHEET2, SHEET3 } from '../controller/NetworkNavigatorCustomController';
import { TextWithInput } from './CustomComponentForNavigation';
/* instrument ignore file */
const ADD_TEXT1_ID: string = 'add_text1_id';
const ADD_TEXT2_ID: string = 'add_text2_id';
const START_POINT1: number = 78;
const START_POINT2: number = 90;

@Component
export struct CustomScenarioDataInputComponent {
  tag: string = 'CustomScenarioDataInputComponent: ';
  private param?: SettingItemModel;
  private loadingBuilderParam: LoadingBuilderParam =  {title1: '', title2: '', placeholder1: '', placeholder2: ''};
  private unit: string = '';
  private startPoint: number = START_POINT1;
  private maxWidth: string = '40%'
  @State inputText1: string = '';
  @State inputText2: string = '';
  build() {
    Column() {
        Row({ space: 20 }) {
          Column({ space: 0 }) {
              TextWithInput({
                title: this.loadingBuilderParam.title1,
                inputPlaceholder: this.loadingBuilderParam.placeholder1,
                inputText: this.inputText1,
                textInputId: ADD_TEXT1_ID,
                onChange: (value: string) => {
                  this.inputText1 = value.trim();
                  EventBus.getInstance().emit(CUSTOM_SCENARIO_DATA_CHANGE_EVENT,
                    this.param?.id, this.inputText1, this.inputText2);
                },
                maxWidth: this.maxWidth,
                unit: this.unit,
                isShowUnderline: true,
              })

              TextWithInput({
                title: this.loadingBuilderParam.title2,
                inputPlaceholder: this.loadingBuilderParam.placeholder2,
                inputText: this.inputText2,
                textInputId: ADD_TEXT2_ID,
                onChange: (value: string) => {
                  this.inputText2 = value.trim();
                  EventBus.getInstance().emit(CUSTOM_SCENARIO_DATA_CHANGE_EVENT,
                    this.param?.id, this.inputText1, this.inputText2);
                },
                maxWidth: this.maxWidth,
                unit: this.unit,
                isShowUnderline: false,
              })
          }
          .backgroundColor(Color.Transparent)
        }
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(this.tag, `aboutToAppear, isGrayed: ${this.param?.id}`);
    if (this.param?.id === SHEET1) {
      this.startPoint = START_POINT1;
      this.unit =
        ResourceUtil.getNumberFormatStringSync($r('app.string.network_navigator_downlink_bandwidth_example'), '');
      this.maxWidth = '40%';
      this.loadingBuilderParam = {
        title1: ResourceUtil.getStringSync($r('app.string.network_navigator_uplink_bandwidth')),
        title2: ResourceUtil.getStringSync($r('app.string.network_navigator_downlink_bandwidth')),
        placeholder1: ResourceUtil.getNumberFormatStringSync(
          $r('app.string.network_navigator_downlink_bandwidth_example'), '5000'),
        placeholder2: ResourceUtil.getNumberFormatStringSync(
          $r('app.string.network_navigator_downlink_bandwidth_example'), '10000')
      };
    } else if (this.param?.id === SHEET2) {
      this.startPoint = START_POINT2;
      this.unit = '%';
      this.maxWidth = '50%';
      this.loadingBuilderParam = {
        title1: ResourceUtil.getStringSync($r('app.string.network_navigator_uplink_droprate')),
        title2: ResourceUtil.getStringSync($r('app.string.network_navigator_downlink_droprate')),
        placeholder1: ResourceUtil.getFormatStringSync(
          $r('app.string.network_navigator_droprate_example'), '0.1 %'),
        placeholder2: ResourceUtil.getFormatStringSync(
          $r('app.string.network_navigator_droprate_example'), '0.1 %'),
      };
    } else if (this.param?.id === SHEET3) {
      this.startPoint = START_POINT1;
      this.unit = ResourceUtil.getNumberFormatStringSync($r('app.string.network_navigator_latency_example'), '');
      this.maxWidth = '40%';
      this.loadingBuilderParam = {
        title1: ResourceUtil.getStringSync($r('app.string.network_navigator_uplink_latency')),
        title2: ResourceUtil.getStringSync($r('app.string.network_navigator_downlink_latency')),
        placeholder1: ResourceUtil.getNumberFormatStringSync($r('app.string.network_navigator_latency_example'), '50'),
        placeholder2: ResourceUtil.getNumberFormatStringSync($r('app.string.network_navigator_latency_example'), '50')
      };
    }
    if (scenarioDataOut.scenarioName !== '') {
      let dataList: number[] = PreferencesUtil.getSync(scenarioDataOut.scenarioName, []) as number[];
      if (this.param?.id === SHEET1) {
        this.inputText1 = String(dataList[0]);
        this.inputText2 = String(dataList[1]);
      } else if (this.param?.id === SHEET2) {
        this.inputText1 = String(Math.round(dataList[2] * 10) / 10);
        this.inputText2 = String(Math.round(dataList[3] * 10) / 10);
      } else if (this.param?.id === SHEET3) {
        this.inputText1 = String(dataList[4]);
        this.inputText2 = String(dataList[5]);
      }
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}

