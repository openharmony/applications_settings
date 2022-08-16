/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import ISettingsController from '../../../../../../../common/component/src/main/ets/default/controller/ISettingsController'
import SwitchController from '../../../../../../../common/component/src/main/ets/default/controller/SwitchController'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import {LogAll} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import parameter from '@ohos.systemparameter';
const MODULE_TAG = ConfigData.TAG + '.LayoutBoundariesController -> ';
@LogAll
export default class LayoutBoundariesController extends SwitchController {
  /**
   * Initialize data.
   */
  initData(): ISettingsController {
    super.initData();
    return this;
  }
  /**
   * Get usb current functions state
   */
  getUsbCurrentFunctions() {
  }

  /**
   * After current value changed event
   */
  afterCurrentValueChanged() {
    if(this.isOn){
       parameter.set("persist.ace.debug.boundary.enabled", "true").then(()=>{
       LogUtil.info(MODULE_TAG + "open boundary success ")
    }).catch((error)=>{
        LogUtil.info(MODULE_TAG + "open boundary fail " + JSON.stringify(error))
    })
    } else {
       parameter.set("persist.ace.debug.boundary.enabled", "false").then(()=>{
           LogUtil.info(MODULE_TAG + "close boundary success ")
       }).catch((error)=>{
           LogUtil.info(MODULE_TAG + "close boundary fail " + JSON.stringify(error))
       });
    }
  }
}