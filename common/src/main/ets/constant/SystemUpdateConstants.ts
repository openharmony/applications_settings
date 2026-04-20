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
 * 系统升级常量类
 */
export class SystemUpdateConstants {
  /**
   * OUC包名
   */
  public static OUC_BUNDLE_NAME: string = 'com.ohos.ouc';

  /**
   * OUC后台服务Ability名
   */
  public static OUC_SERVICE_ABILITY_NAME: string = 'ServiceExtAbility';

  /**
   * OUC协同更新Ability名
   */
  public static OUC_ALL_SCENE_ABILITY_NAME: string = 'com.ohos.ouc.AsAbility';

  /**
   * 协同升级菜单项目信息Settings表字段
   */
  public static ALL_SCENE_MENU_ITEM_INFO: string = 'all_scene_settings_menu_item_info';

  /**
   * 软件更新角标数据库标志位
   */
  public static HW_NEW_SYSTEM_UPDATE: string = 'hw_new_system_update';
}