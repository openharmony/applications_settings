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

import geolocation from '@ohos.geoLocationManager';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';

export class LocationService {
  mIsStart: boolean = false;
  mListener: any;

  startService() {
    if (this.mIsStart) {
      return;
    }
    LogUtil.info(ConfigData.TAG + 'start location service')
    this.mIsStart = true;
    this.getServiceState();
    geolocation.on('locationEnabledChange', (isChanged: boolean) => {
      LogUtil.info(ConfigData.TAG + `start location service isChanged: ${JSON.stringify(isChanged)}`)
      this.getServiceState();
    });
  }

  registerListener(listener: {
    'updateServiceState': Function,
  }) {
    LogUtil.info(ConfigData.TAG + `register locations listener : ${listener}`)
    this.mListener = listener;
  }

  getServiceState() {
    LogUtil.info(ConfigData.TAG + 'get location state')
    let state = geolocation.isLocationEnabled();
    LogUtil.info(ConfigData.TAG + `get location state, data: ${JSON.stringify(state)}`)
    this.mListener?.updateServiceState(state);
  }

  enableLocation() {
    LogUtil.info(ConfigData.TAG + 'enable location')
    try{
      geolocation.enableLocation()
        .then((res) => LogUtil.info(ConfigData.TAG + `enable location, result: ${JSON.stringify(res)}`))
        .catch(error=> LogUtil.info(ConfigData.TAG + `enable location, result: ${error}`))
    }catch(err){
       LogUtil.info(ConfigData.TAG + `enable location, result: ${err}`)
    }

  }

  disableLocation() {
    LogUtil.info(ConfigData.TAG + 'disable location')
    try{
      geolocation.disableLocation()
    }catch(err){
      LogUtil.info(ConfigData.TAG + `disenable location, result: ${err}`)
    }
  }
}

let locationService = new LocationService();

export default locationService as LocationService;
