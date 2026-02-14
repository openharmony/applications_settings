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
import { Callback, BusinessError } from '@kit.BasicServicesKit';
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PowerSaveSuggestionModel } from './model/PowerSaveSuggestionModel';

const TAG: string = 'PowerSaveTaskManager';

export const TASK_START_EVENT: string = 'optimization_task_start';
export const TASK_FINISH_EVENT: string = 'optimization_task_finish';
export const AUTO_SCREEN_ON_KEY: string = 'app_ntf_config_screen_on';
export const SLEEP_NOTIFICATION_ENABLE: string = 'settings.push.sleep_notification_enable';
export const DATA_SCREEN_OFF_TIMEOUT: string = settings.display.SCREEN_OFF_TIMEOUT;
export const AOD_DISPLAY_TYPE: string = 'settings.sceneboard.aod_state';
export const REFRESH_RATE_KEY: string = 'settings.display.hw_screen_freq';
export const REFRESH_RATE_OPTION_DYNAMIC: number = -1;
export const REFRESH_RATE_OPTIONS_HIGH: number = 2;

export enum TaskKey {
  SHUT_DOWN_APP = 'turn_off_battery_intensive_apps',
  REFRESH_RATE = 'set_screen_refresh_rate_to_smart_mode',
  DISABLE_HOTSPOT = 'turn_off_hotspot',
  SCREEN_OFF_TIME_OUT = 'set_sleep_time_30',
  AOD_DISPLAY_TYPE = 'set_aod_display_mode_smart',
  NOTIFICATION_WHEN_SLEEP = 'disable_notification_when_hibernation',
  AUTO_SCREEN_ON_WITH_NOTIFICATION = 'disable_wakeup_notification'
}

export interface SuggestionContext {
  modelGenerator: () => Promise<PowerSaveSuggestionModel>,
  optimizationTask?: (context: Context) => Promise<boolean>,
  needShow: () => Promise<boolean>,
  registerStateChange?: (callback: Callback<boolean>) => void,
  unregisterStateChange?: (callback: Callback<boolean>) => void
}

const keyMap: Map<string, string> = new Map<string, string>([
  [TaskKey.SHUT_DOWN_APP, './model/concretemodel/BatteryIntensiveModel'],
  [TaskKey.REFRESH_RATE, './model/concretemodel/RefreshRateModel'],
  [TaskKey.DISABLE_HOTSPOT, './model/concretemodel/HotspotModel'],
  [TaskKey.SCREEN_OFF_TIME_OUT, './model/concretemodel/ScreenOffTimeoutModel'],
  [TaskKey.AOD_DISPLAY_TYPE, './model/concretemodel/SmartAodModel'],
  [TaskKey.NOTIFICATION_WHEN_SLEEP, './model/concretemodel/NotificationWhenSleepModel'],
  [TaskKey.AUTO_SCREEN_ON_WITH_NOTIFICATION, './model/concretemodel/AutoScreenOnModel']
])

export class PowerSaveTaskManager {
  private static instance: PowerSaveTaskManager;
  private supportedTaskKeys: string[] = [];
  private suggestionMap: Map<string, SuggestionContext> = new Map();

  private constructor() {
  }

  public static getInstance(): PowerSaveTaskManager {
    if (!PowerSaveTaskManager.instance) {
      PowerSaveTaskManager.instance = new PowerSaveTaskManager();
    }
    return PowerSaveTaskManager.instance;
  }

  public async initSupportedTask(keys: string[]): Promise<void> {
    this.supportedTaskKeys = keys;
    let length: number = keys.length;
    for (let i: number = 0; i < length; i++) {
      let key: string = keys[i];
      let path: string = keyMap.get(key) as string;
      if (!path) {
        LogUtil.info(`${TAG} initSupportedTask ${key} path is undefined`);
        continue;
      }
      if (this.suggestionMap?.has(key)) {
        LogUtil.info(`${TAG} initSupportedTask ${key} has already imported`);
        continue;
      }
      LogUtil.info(`${TAG} import config ${key} start`);
      import(path).then(() => {
        LogUtil.info(`${TAG} import config ${key} end`);
      }).catch((err: BusinessError) => {
        LogUtil.error(`${TAG} import error code ${err?.code}, message: ${err?.message}`);
      });
    }
  }

  public loadTask(name: string, context: SuggestionContext): void {
    LogUtil.info(`${TAG} loadTask key ${name}`);
    if (!context) {
      LogUtil.warn(`${TAG} loadTask fail, context is null or undefined`);
      return;
    }
    if (this.suggestionMap.has(name)) {
      LogUtil.warn(`${TAG} loadTask ${name} has already loaded`);
      return;
    }
    this.suggestionMap.set(name, context);
  }

  public getSuggestionContext(key: string): SuggestionContext | undefined {
    let context: SuggestionContext | undefined = this.suggestionMap.get(key);
    return context;
  }

  public async getAvailableSuggestionList(): Promise<string[]> {
    let iterator = this.suggestionMap.entries();
    let pointer = iterator.next();
    let result: string[] = [];
    while (!pointer.done) {
      const key: string = pointer.value[0];
      const value: SuggestionContext = pointer.value[1] as SuggestionContext;
      if (await value.needShow()) {
        result.push(key);
      }
      pointer = iterator.next();
    }
    return result;
  }

  public getSupportedTaskKeys(): string[] {
    return this.supportedTaskKeys;
  }
}