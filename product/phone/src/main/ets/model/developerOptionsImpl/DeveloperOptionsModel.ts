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
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import usb from '@ohos.usb';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import {LogAll} from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

/**
 * Developer options model
 */
@LogAll
export class DeveloperOptionsModel extends BaseModel {

  /**
   * Get usb current functions state
   * @return state
   */
  getUsbCurrentFunctions() {
    return usb.getCurrentFunctions()
  }

  /**
   * set current functions
   * @param usbDebuggingState UsbDebugging state
   */
  setCurrentFunctions(usbDebuggingState) {
    let funcs;
    if (usbDebuggingState) {
      funcs = ConfigData.FUNCTION_TYPE_HDC | this.getUsbCurrentFunctions()
    } else {
      funcs = (ConfigData.FUNCTION_TYPE_HDC | this.getUsbCurrentFunctions()) - ConfigData.FUNCTION_TYPE_HDC
    }
    usb.setCurrentFunctions(funcs).then((val) => {
    }).catch((err) => {
      LogUtil.info(ConfigData.TAG + `setCurrentFunctions fail:` + err);
    })
  }
}

let developerOptionsModel = new DeveloperOptionsModel();

export default developerOptionsModel as DeveloperOptionsModel
;