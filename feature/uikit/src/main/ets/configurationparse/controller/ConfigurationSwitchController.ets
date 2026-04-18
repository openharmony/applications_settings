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

import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ConfigurationBaseController } from './ConfigurationBaseController';
import { ConfigurationConstant } from '../ConfigurationConstant';
/* instrument ignore file */
const TAG: string = 'ConfigurationSwitchController : ';

/**
 * 配置文件解析--开关控制器
 *
 * @since 2023-08-21
 */
export class ConfigurationSwitchController extends ConfigurationBaseController {
  static CreateConfigurationSwitchController(menu: SettingsBaseMenu): Controller {
    return new ConfigurationSwitchController(menu);
  }

  private isChecked: boolean = false;

  public updateStatus(): void {
    LogUtil.info(`${TAG} updateStatus`);
    let isChecked = this.getCheckedState();
    this.setCheckedState(isChecked);
  }

  private getCheckedState(): boolean {
    if (!this.settingProperty) {
      LogUtil.error(`${TAG} settingProperty is null.`);
      return false;
    }
    return SettingsDataUtils.getSettingsData(this.settingProperty, ConfigurationConstant.SWITCH_OFF) ==
    ConfigurationConstant.SWITCH_ON;
  }

  /**
   * 点击开关状态切换
   */
  public onToggleChange(isOn: boolean) {
    LogUtil.info(`${TAG} onToggleChange ${isOn}`);

    // isOn 可能是 0/1 , 必须转换成boolean值 true/false, 否则开关控件不兼容，有异常
    let booleanValue = Boolean(isOn).valueOf();
    this.isChecked = booleanValue;
    this.handleCheckedChange(booleanValue);
  }

  /**
   * 获取开关的保存状态
   *
   * @returns true表示开关打开，false表示开关关闭
   */
  public getChecked(): boolean {
    LogUtil.info(`${TAG} getChecked ${this.isChecked}`);
    return this.isChecked;
  }

  /**
   * 设置开关的状态
   */
  public setCheckedState(isChecked: boolean): void {
    LogUtil.info(`${TAG} setChecked ${isChecked}`);
    if (this.isChecked === isChecked) {
      return;
    }
    this.isChecked = isChecked;
    LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked}`);
    this.refreshUi();
  }

  /**
   * 开关变化更新数据库属性对应值
   */
  protected handleCheckedChange(isChecked: boolean) {
    if (!this.settingProperty) {
      LogUtil.error(`${TAG} settingProperty is null.`);
      return;
    }
    SettingsDataUtils.setSettingsData(this.settingProperty,
      isChecked ? ConfigurationConstant.SWITCH_ON : ConfigurationConstant.SWITCH_OFF);
  }

  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    this.updateStatus();
  }
}
