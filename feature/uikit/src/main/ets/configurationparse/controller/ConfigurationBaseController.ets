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

import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import dataShare from '@ohos.data.dataShare';
import { ConfigurationConstant } from '../ConfigurationConstant';
/* instrument ignore file */
const TAG: string = 'ConfigurationBaseController : ';

/**
 * 配置文件中menu基础控制器，主要用于获取setting数据字段和监听数据变化
 *
 * @since 2023-08-21
 */
export class ConfigurationBaseController extends MenuController {
  protected settingProperty?: string;
  protected dataHelper?: dataShare.DataShareHelper;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.getSettingProperty();
  }

  aboutToAppear() {
    super.aboutToAppear();
    if (!this.getSettingsDataByProperty(this.settingProperty as string)) {
      this.setVisible(false);
    }
  }

  private getSettingProperty() {
    if (!this.menu.extra) {
      LogUtil.error(`${TAG} extra is null.`);
      return;
    }
    for (let key of Object.keys(this.menu.extra)) {
      if (key === ConfigurationConstant.SETTING_PROPERTY) {
        this.settingProperty = (this.menu.extra as Record<string, string>)[key];
        break;
      }
    }
  }

  /**
   * 根据数据库中属性字段获取对应值
   *
   * @param property 设置数据库中属性
   */
  protected getSettingsDataByProperty(property: string): string | null {
    if (!property) {
      LogUtil.error(`${TAG} property is null.`);
      return null;
    }
    return SettingsDataUtils.getSettingsData(property, null);
  }

  /**
   * 注册监听
   */
  protected registerDataChange(): void {
    this.registerDataChangeByProperty(this.settingProperty as string);
  }

  private registerDataChangeByProperty(property: string) {
    if (!property) {
      LogUtil.error(`${TAG} settingProperty is null.`);
      return;
    }
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, property, this.onDataChange)
    } else {
      (SettingsDataUtils.createDataHelper(property) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, property, this.onDataChange);
          }
        })
    }
    LogUtil.info(`${TAG} listen on.`);
  }

  /**
   * 取消监听
   */
  protected unRegisterDataChange(): void {
    this.unRegisterDataChangeByProperty(this.settingProperty as string);
  }

  private unRegisterDataChangeByProperty(property: string) {
    if (!property) {
      LogUtil.error(`${TAG} settingProperty is null.`);
      return;
    }
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, property)
    LogUtil.info(`${TAG} listen off`);
  }

  /*
  * 数据库监听回调
  */
  public onDataChange = () => {
    if (!this.isVisibleStatus() && this.getSettingsDataByProperty(this.settingProperty as string)) {
      this.setVisible(true);
    }
  }
}
