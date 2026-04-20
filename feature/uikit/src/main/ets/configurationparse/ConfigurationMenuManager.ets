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

import resourceManager from '@ohos.resourceManager';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { hasOwnPropertyCall } from '@ohos/settings.common/src/main/ets/utils/ObjectPrototypeUtil';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { CardMenuSection, EntryMenu, SelectEntryMenu, SubHeaderSection, SwitchMenu } from '../menus/Menu';
import { ConfigurationConstant, ResourceType } from './ConfigurationConstant';
import ConfigurationRadioController from './controller/ConfigurationRadioController';
import ConfigurationSelectController from './controller/ConfigurationSelectController';
import { ConfigurationSwitchController } from './controller/ConfigurationSwitchController';

const TAG: string = 'ConfigurationMenuManager : ';

/**
 * 配置文件json数据管理类
 *
 * @since 2023-08-21
 */
export class ConfigurationMenuManager {
  private json?: string;
  private bundleName?: string;
  private title?: string;
  private icon?: string;
  private menus: SettingsBaseMenu[] = [];

  /**
   * ConfigurationMenuManager
   *
   * @return ConfigurationMenuManager单例对象
   */
  public static getInstance(): ConfigurationMenuManager {
    if (!AppStorage.get<ConfigurationMenuManager>('ConfigurationJsonManager')) {
      AppStorage.setOrCreate<ConfigurationMenuManager>('ConfigurationJsonManager', new ConfigurationMenuManager());
    }
    return AppStorage.get<ConfigurationMenuManager>('ConfigurationJsonManager') as ConfigurationMenuManager;
  }

  /**
   * 加载界面标题和图标资源
   */
  public loadPageResource() {
    this.title = this.loadResourceByName(this.title as string, ResourceType.STRING);
    this.icon = this.loadResourceByName(this.icon as string, ResourceType.MEDIA);
  }

  /**
   * 获取界面标题
   */
  public getTitle(): string {
    return this.title as string;
  }

  /**
   * 获取界面图标
   */
  public getIcon(): string {
    return this.icon as string;
  }

  /**
   * 获取菜单数组
   */
  public getMenus(): Array<SettingsBaseMenu> {
    return this.menus as Array<SettingsBaseMenu>;
  }

  /**
   * 数据重置
   */
  public reset() {
    LogUtil.info(`${TAG} reset`);
    this.json = undefined;
    this.bundleName = undefined;
    this.title = undefined;
    this.icon = undefined;
    this.menus = [];
  }

  /**
   * 解析json数据
   */
  public parseJson(value: string): Boolean {
    if (!value) {
      LogUtil.info(`${TAG} value is null.`);
      return false;
    }
    LogUtil.info(`${TAG} parseJson`);
    this.json = value;
    let json: Record<string, Object> = JSON.parse(this.json);
    for (let key of Object.keys(json)) {
      if (key === ConfigurationConstant.JSON_BUNDLE_NAME) {
        this.bundleName = json[key] as string;
      } else if (key === ConfigurationConstant.JSON_TITLE) {
        this.title = json[key] as string;
      } else if (key === ConfigurationConstant.JSON_ICON) {
        this.icon = json[key] as string;
      } else if (key === ConfigurationConstant.JSON_GROUPS) {
        let groups = json[key] as Record<string, Object>;
        LogUtil.info(`${TAG} parseJson, groups number is ${groups['length']}`);
        let indexGroup: number = ConfigurationConstant.MENU_INDEX;
        for (let key of Object.keys(groups)) {
          let group = groups[key];
          let menuGroup: SettingsBaseMenu = this.parseGroup(group, indexGroup);
          if (menuGroup) {
            this.menus.push(menuGroup);
          }
          indexGroup += ConfigurationConstant.MENU_INDEX;
        }
      } else {
        LogUtil.debug(`${TAG} pase json: the ${key} is not suported`);
      }
    }
    return true;
  }

  private parseGroup(group: object, indexGroup: number): SettingsBaseMenu {
    let indexComponent: number = ConfigurationConstant.MENU_INDEX;
    let title: string = '';
    let components: Record<string, Object>;
    let menus: SettingsBaseMenu[] = [];
    for (let key of Object.keys(group)) {
      if (key === ConfigurationConstant.JSON_GROUP_TITLE) {
        title = group[key];
      } else if (key === ConfigurationConstant.JSON_GROUP_COMPONENTS) {
        components = group[key];
        for (let component of Object.keys(components)) {
          menus.push(this.parseComponent(components[component], indexComponent) as SettingsBaseMenu)
          indexComponent += ConfigurationConstant.MENU_INDEX;
        }
      } else {
        LogUtil.debug(`${TAG} parseGroup, other property: ${key}.`);
      }
    }
    return this.generateGroupMenu(indexGroup, title, menus) as SwitchMenu;
  }

  private parseComponent(component: object, indexComponent: number): SettingsBaseMenu | undefined {
    let menu: SettingsBaseMenu | undefined = undefined;
    let hasSettingProperty: boolean = hasOwnPropertyCall(component, ConfigurationConstant.SETTING_PROPERTY);
    let hasType: boolean = hasOwnPropertyCall(component, ConfigurationConstant.JSON_COMPONENT_TYPE);
    let hasTitle: boolean = hasOwnPropertyCall(component, ConfigurationConstant.JSON_COMPONENT_TITLE);
    if (!hasSettingProperty || !hasType || !hasTitle) {
      LogUtil.error(`${TAG} parseComponent, settingProperty, type or title is configurated incorrectly.`);
      return undefined;
    }
    let json: Record<string, Object> = JSON.parse(JSON.stringify(component));
    LogUtil.info(`${TAG} parseComponent, the type is ${json.type}`);
    let titleRes: string = this.loadResourceByName(json['title'] as string, ResourceType.STRING);
    if (!titleRes) {
      LogUtil.error(`${TAG} parseComponent, titleRes is null`);
      return undefined;
    }
    switch (json.type) {
      case ConfigurationConstant.SWITCH_TYPE:
        menu = this.generateSwitchMenu(json, component, indexComponent, titleRes);
        break;
      case ConfigurationConstant.SELECT_TYPE:
        menu = this.generateSelectMenu(json, component, indexComponent, titleRes);
        break;
      case ConfigurationConstant.RADIO_TYPE:
        menu = this.generateRadioMenu(json, component, indexComponent, titleRes);
        break;
      default:
        LogUtil.debug(`${TAG} the component type ${json.type} is not supported`);
        break;
    }
    return menu as SettingsBaseMenu;
  }

  private parseSelectList(selectList: object): Array<SelectOption> {
    let selectOptionList: SelectOption[] = [];
    for (let key of Object.keys(selectList)) {
      let selectValue = this.loadResourceByName(selectList[key], ResourceType.STRING);
      selectOptionList.push({ value: selectValue });
    }
    return selectOptionList;
  }

  private generateGroupMenu(indexGroup: number, title: string, menus: Array<SettingsBaseMenu>): SwitchMenu | undefined {
    if (!menus || menus.length === 0) {
      LogUtil.error(`${TAG} generateGroupMenu, menus is null or the length of menus is zero.`);
      return undefined;
    }
    let groupMenu: SettingsBaseMenu;
    if (title) {
      let titleRes = this.loadResourceByName(title, ResourceType.STRING);
      if (!titleRes) {
        LogUtil.error(`${TAG} generateGroupMenu, titleRes is null`);
        return undefined;
      }
      groupMenu = new SubHeaderSection(
        {
          key: titleRes + new Date().getTime(),
          index: indexGroup,
          title: titleRes,
        },
        menus);
    } else {
      groupMenu = new CardMenuSection(
        {
          key: title + new Date().getTime(),
          index: indexGroup
        },
        menus);
    }
    return groupMenu;
  }

  // instrument ignore next
  private generateSwitchMenu(json: Record<string, Object>, component: object, index: number, titleRes: string):
  SwitchMenu | undefined {
    if (!json || !component) {
      LogUtil.error(`${TAG} generateSwitchMenu, the param is null.`);
      return undefined;
    }
    return new SwitchMenu({
      key: json['title'] as string + new Date().getTime(),
      index,
      title: titleRes,
      controller: {
        createControllerConstructorInter: ConfigurationSwitchController.CreateConfigurationSwitchController,
      },
      extra: {
        settingProperty: json['settingProperty'] as string,
        isOn: hasOwnPropertyCall(component, ConfigurationConstant.SWITCH_IS_ON) ? json['isOn'] as boolean : false
      }
    });
  }

  // instrument ignore next
  private generateSelectMenu(json: Record<string, Object>, component: object, index: number,
                             titleRes: string): SelectEntryMenu | undefined {
    if (!json || !component || !hasOwnPropertyCall(component, ConfigurationConstant.SELECT_LIST)) {
      LogUtil.error(`${TAG} generateSelectMenu, the param is null.`);
      return undefined;
    }
    let selected: number = hasOwnPropertyCall(component, ConfigurationConstant.SELECTED) ? json['selected'] as number
      : 0;
    let selectOptionList: SelectOption[] = this.parseSelectList(json.selectList);
    let value = selectOptionList[selected].value;
    LogUtil.info(`${TAG} selected : ${selected}, value : ${value}`);
    return new SelectEntryMenu({
      key: json['title'] as string + new Date().getTime(),
      index: index,
      title: titleRes,
      selectList: selectOptionList,
      selected: selected,
      value: value,
      controller: {
        createControllerConstructorInter: ConfigurationSelectController.CreateConfigurationSelectController,
      },
      extra: {
        settingProperty: json['settingProperty'] as string,
      }
    });
  }

  private generateRadioMenu(json: Record<string, Object>, component: object, index: number, titleRes: string):
  EntryMenu | undefined {
    if (!json || !component || !hasOwnPropertyCall(component, ConfigurationConstant.RADIO_LIST)) {
      LogUtil.error(`${TAG} generateRadioMenu, the param is null.`);
      return undefined;
    }
    let selected: number = hasOwnPropertyCall(component, ConfigurationConstant.SELECTED) ? json['selected'] as number
      : 0;
    let radioOptionList: SelectOption[] = this.parseSelectList(json.radioList);
    let value = radioOptionList[selected].value.toString();
    return new EntryMenu({
      key: json['title'] as string + new Date().getTime(),
      index: index,
      title: titleRes,
      controller: {
        createControllerConstructorInter: ConfigurationRadioController.CreateConfigurationRadioController,
      },
      stateIcon: $r('app.media.ic_settings_arrow'),
      state: value,
      extra: {
        radioList: radioOptionList,
        settingProperty: json['settingProperty'] as string,
      }
    });
  }

  private loadResourceByName(resourceName: string, resourceTpe: ResourceType): string {
    if (!resourceName || !this.bundleName) {
      LogUtil.error(`${TAG} resourceName or bundleName is null.`);
      return '';
    }
    let resourceManager = ResourceManagerUtil.getBundleResourceManager(this.bundleName);
    if (!resourceManager) {
      LogUtil.error(`${TAG} getBundleResourceManager falied.`);
      return '';
    }
    let value = resourceName;
    try {
      if (resourceTpe === ResourceType.STRING) {
        value = resourceManager.getStringByNameSync(resourceName);
      } else if (resourceTpe === ResourceType.MEDIA) {
        value = resourceManager.getMediaBase64ByNameSync(resourceName);
      } else {
        LogUtil.debug(`${TAG} other resource type.`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} loadResource error`);
      return '';
    }
    return value;
  }
}