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

/**
 * 配置文件解析常量类
 *
 * @since 2023-08-17
 */
export class ConfigurationConstant {
  /*
   * 表示json中配置的应用bundle name字段.
   */
  public static readonly JSON_BUNDLE_NAME = 'bundleName';

  /*
   * 表示json中配置的界面标题字段.
   */
  public static readonly JSON_TITLE = 'title';

  /*
   * 表示json中配置的界面图标字段.
   */
  public static readonly JSON_ICON = 'icon';

  /*
   * 表示json中配置的控件组字段.
   */
  public static readonly JSON_GROUPS = 'groups';

  /*
   * 表示json中配置的控件组标题字段.
   */
  public static readonly JSON_GROUP_TITLE = 'title';

  /*
   * 表示控件组中控件字段.
   */
  public static readonly JSON_GROUP_COMPONENTS = 'components';

  /*
   * 表示控件类型字段.
   */
  public static readonly JSON_COMPONENT_TYPE = 'type';

  /*
   * 表示控件名称字段.
   */
  public static readonly JSON_COMPONENT_TITLE = 'title';

  /*
   * 表示开关控件类型字段.
   */
  public static readonly SWITCH_TYPE = 'switch';

  /*
   * 表示开关控件状态字段.
   */
  public static readonly SWITCH_IS_ON = 'isOn';

  /*
   * 表示选择控件类型字段.
   */
  public static readonly SELECT_TYPE = 'select';

  /*
   * 表示选择控件选项字段.
   */
  public static readonly SELECT_LIST = 'selectList';

  /*
   * 表示选择控件选项初始值字段.
   */
  public static readonly SELECTED = 'selected';

  /*
   * 表示单选控件类型字段.
   */
  public static readonly RADIO_TYPE = 'radio';

  /*
   * 表示单择控件选项字段.
   */
  public static readonly RADIO_LIST = 'radioList';

  /*
 * 表示单个单选菜单字段.
 */
  public static readonly SINGLE_RADIO_VALUE = 'value';

  /*
   * 表示控件对应的setting数据库中的属性名称字段.
   */
  public static readonly SETTING_PROPERTY = 'settingProperty';

  /*
   * switch控件开关打开.
   */
  public static readonly SWITCH_ON = '1';

  /*
   * switch控件开关关闭.
   */
  public static readonly SWITCH_OFF = '0';

  /*
   * 控件index.
   */
  public static readonly MENU_INDEX: number = 10;

  /*
   * dialog中取消按钮index.
   */
  public static readonly BUTTON_CANCEL_MENU_INDEX: number = 100;

  /*
   * dialog中列表数据菜单初始index
   */
  public static readonly DIVIDER_MENU_INDEX: number = 1;
}

/*
 * 资源文件类型.
 */
export enum ResourceType {
  /*
   * string类型
   */
  STRING = 0,

  /*
   * media类型
   */
  MEDIA = 1,
}
