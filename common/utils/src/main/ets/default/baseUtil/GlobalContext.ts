/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

export class GlobalContext {
  static readonly GLOBAL_KEY_SETTINGS_ABILITY_CONTEXT = 'settingsAbilityContext';
  static readonly GLOBAL_KEY_ABILITY_WANT = 'abilityWant';
  static readonly GLOBAL_KEY_AUDIO_MANAGER = 'audioManager';
  static readonly GLOBAL_KEY_AUDIO_VOLUME_GROUP_MANAGER = 'audioVolumeGroupManager';

  private static instance: GlobalContext;
  private context = new Map<string, Object>();

  private constructor() {
  }

  public static getContext(): GlobalContext {
    if (!GlobalContext.instance) {
      GlobalContext.instance = new GlobalContext();
    }
    return GlobalContext.instance;
  }

  getObject(value: string): Object | undefined {
    return this.context.get(value);
  }

  setObject(key: string, objectClass: Object): void {
    this.context.set(key, objectClass);
  }
}