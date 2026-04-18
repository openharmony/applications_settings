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
import commonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import componentConfig from './utils/ComponentConfig';

export class KeyboardSettingsManager {
  private static keyboardManager: KeyboardSettingsManager | undefined = undefined;
  private tag: string = 'KeyboardSettingsManager';
  private keyboardName: string = SystemParamUtil.getParam(componentConfig.spKeyboardName, '');
  private model: string = '';
  private serialId: string = '';
  private hardwareVersion: string = '';
  private softwareVersion: string = '';
  private macId: string = '';

  public static getInstance(): KeyboardSettingsManager {
    if (KeyboardSettingsManager.keyboardManager) {
      return KeyboardSettingsManager.keyboardManager;
    }
    KeyboardSettingsManager.keyboardManager = new KeyboardSettingsManager();
    return KeyboardSettingsManager.keyboardManager;
  }

  public setKeyboardName(keyboardName: string): void {
    if (keyboardName === undefined || keyboardName === this.macId || keyboardName === 'undefined') {
      this.keyboardName = SystemParamUtil.getParam(componentConfig.spKeyboardName, '');
    } else {
      this.keyboardName = keyboardName;
    }
  }

  public setModel(model: string): void {
    this.model = model;
  }

  public setSerialId(serialId: string): void {
    this.serialId = serialId;
  }

  public setHardwareVersion(hardwareVersion: string): void {
    this.hardwareVersion = hardwareVersion;
  }

  public setSoftwareVersion(softwareVersion: string): void {
    this.softwareVersion = softwareVersion;
  }

  public setMacId(macId: string): void {
    this.macId = macId;
  }

  public getKeyboardName(): string {
    return this.keyboardName;
  }

  public getModel(): string {
    return this.model;
  }

  public getSerialId(): string {
    return this.serialId;
  }

  public getHardwareVersion(): string {
    return this.hardwareVersion;
  }

  public getSoftwareVersion(): string {
    return this.softwareVersion;
  }

  public getMacId(): string {
    return this.macId;
  }

  public sendShowShortcutPanel(): void {
    LogUtil.info(`${this.tag} Go to shortcut key panel`);
    // 发布公共事件
    try {
      commonEventManager.publish(componentConfig.shortcutHelperEvent, (err) => {
        if (err) {
          LogUtil.error(`${this.tag} publish shortcut helper panel failed, error: ${err?.message}`);
        } else {
          LogUtil.info(`${this.tag} publish shortcut helper panel success`);
        }
      });
    } catch (error) {
      LogUtil.error(`${this.tag} publish shortcut helper panel failed, error: ${error?.message}`);
    }
  }
}