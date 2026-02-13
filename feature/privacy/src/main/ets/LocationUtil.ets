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

/* instrument ignore file */
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/**
 * 位置信息回调
 */
export interface LocationStateChangeListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  // 位置信息回调
  onLocationStateChange(state: boolean): void;
}

const TAG: string = 'LocationUtil : ';

export class LocationUtil {
  public isStart: boolean = false;
  public currentState: boolean = false;
  public stateChangeListeners: LocationStateChangeListener[] = [];

  public locationStateChange = (isStateChanged: boolean) => {
    LogUtil.info(TAG + `listener find location service isChanged: ${isStateChanged}`);
    import('@ohos.geoLocationManager').then(geoLocationManager => {
      this.currentState = geoLocationManager.default.isLocationEnabled();
      LogUtil.info(TAG + `onLocationStateChange state : ${this.currentState}`);
      this.dispatchLocationStateChange(isStateChanged);
    });
  };

  private dispatchLocationStateChange(state: boolean): void {
    for (let listener of this.stateChangeListeners) {
      listener?.onLocationStateChange(state);
    }
  }

  start(): void {
    if (!this.isStart) {
      this.isStart = true;
      import('@ohos.geoLocationManager').then(geoLocationManager => {
        this.currentState = geoLocationManager.default.isLocationEnabled();
        LogUtil.info(TAG + `update location service state, state: ${this.currentState}`);
        geoLocationManager.default.on('locationEnabledChange', this.locationStateChange);
      });
    }
  }

  stop(): void {
    if (this.isStart) {
      LogUtil.info(TAG + 'stop');
      import('@ohos.geoLocationManager').then(geoLocationManager => {
        geoLocationManager.default.off('locationEnabledChange', this.locationStateChange);
        this.isStart = false;

        // 释放资源
        this.stateChangeListeners = [];
      });
    }
  }

  async enableLocation(): Promise<void> {
    try {
      let geoLocationManager = await import('@ohos.geoLocationManager');
      geoLocationManager.default.enableLocation(() => {
        LogUtil.info(TAG + 'enable location service successfully');
      });
    } catch (err) {
      LogUtil.error(TAG + `enable location service failed, err: ${err}`);
    }
  }

  async disableLocation(): Promise<void> {
    LogUtil.info(TAG + 'disable location service');
    try {
      let geoLocationManager = await import('@ohos.geoLocationManager');
      geoLocationManager.default.disableLocation();
    } catch (err) {
      LogUtil.error(TAG + `disable location service failed, err: ${err}`);
    }
  }

  async isLocationEnabled(): Promise<boolean> {
    let geoLocationManager = await import('@ohos.geoLocationManager');
    return geoLocationManager.default.isLocationEnabled();
  }

  registerStateChangeListener(listener: LocationStateChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerLangChangeListener invalid`);
      return;
    }

    for (const stateChangeListener of this.stateChangeListeners) {
      if (stateChangeListener.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerStateChangeListener listener already register`);
        return;
      }
    }

    this.stateChangeListeners.push(listener);
    LogUtil.info(`${TAG} push: ${listener.getListenerName()} size: ${this.stateChangeListeners.length}`);
  }

  unRegisterStateChangeListener(listener: LocationStateChangeListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterStateChangeListener invalid`);
      return;
    }
    for (let index = 0; index < this.stateChangeListeners.length; index++) {
      if (this.stateChangeListeners[index].getListenerName() === listener.getListenerName()) {
        this.stateChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  /**
   * 获取位置管理类单例
   */
  static getInstance(): LocationUtil {
    if (!Boolean(AppStorage.get<LocationUtil>('locationUtil')).valueOf()) {
      AppStorage.setOrCreate<LocationUtil>('locationUtil', new LocationUtil());
    }
    return AppStorage.get<LocationUtil>('locationUtil') as LocationUtil;
  }
}