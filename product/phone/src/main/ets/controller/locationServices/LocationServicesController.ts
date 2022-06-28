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
import LocationServicesModel from '../../model/locationServicesImpl/LocationServicesModel'
import ISettingsController from '../../../../../../common/component/src/main/ets/default/controller/ISettingsController'
import {LogAll} from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import SwitchController from '../../../../../../common/component/src/main/ets/default/controller/SwitchController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

@LogAll
export default class LocationServicesController extends SwitchController {

  /**
   * Initialize data.
   */
  initData(): ISettingsController {
    super.initData();
    this.isLocationEnabled((err, value) => {
      if (err) {
        LogUtil.info(ConfigData.TAG + 'initData -> isLocationEnabled err:' + JSON.stringify(err));
        this.isOn = false;
      } else {
        this.isOn = value;
      }
    })
    return this;
  }

  /**
   * obtain current location switch status
   */
  isLocationEnabled(callback) {
    LocationServicesModel.isLocationEnabled(callback);
  }

  /**
   * subscribe location switch changed
   */
  subscribe(): ISettingsController {
    LocationServicesModel.onLocationServiceState((value) => {
      this.isOn = value;
    })
    return this;
  }

  /**
   * unsubscribe location switch changed
   */
  unsubscribe(): ISettingsController {
    LocationServicesModel.offLocationServiceState((value) => {
      this.isOn = value;
    })
    return this;
  }

  afterCurrentValueChanged() {
    if (this.isOn) {
      LocationServicesModel.enableLocation((err, data) => {
        LogUtil.info(ConfigData.TAG + 'afterCurrentValueChanged -> enableLocation err:' + JSON.stringify(err) + ',data:' + JSON.stringify(data));
        this.location(err, true);
      })
    } else {
      LocationServicesModel.disableLocation((err, data) => {
        LogUtil.info(ConfigData.TAG + 'afterCurrentValueChanged -> disableLocation err:' + JSON.stringify(err) + ',data:' + JSON.stringify(data));
        this.location(err, false);
      })
    }
  }

  /**
   * location switch
   */
  location(err, data) {
    if (err) {
      this.isLocationEnabled((err, value) => {
        if (err) {
          LogUtil.info(ConfigData.TAG + 'afterCurrentValueChanged -> isLocationEnabled err:' + JSON.stringify(err));
          if (this.isOn) {
            this.isOn = false;
          }
        } else {
          this.isOn = value;
        }
      })
    } else {
      this.isOn = data;
    }
  }
}