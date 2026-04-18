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

// 阳光下提升可读性
export const NATURAL_LIGHT_SYS_EVENT_NAME: string = 'natural_light_switch';
export const NATURAL_LIGHT_PREFERENCE_KEY: string = 'settings.display.naturalLightSwitch';
export const NATURAL_LIGHT_SWITCHES_TABLE: string = 'settings.display.natural_light_switch';
export const NATURAL_LIGHT_SWITCHES_ON: string = '1';
export const NATURAL_LIGHT_SWITCHES_OFF: string = '0';
export const NATURAL_LIGHT_SWITCHES_DEFAULT: string = NATURAL_LIGHT_SWITCHES_ON;
//系统共享库
export const SHARED_LIBRARY_BUNDLE_NAME = 'com.ohos.appgallery';
export const SHARED_LIBRARY_ABILITY_NAME = 'UpdateShareLibAbility';
export const SHARED_LIBRARY_METADATA_NAME = 'appgallery_support_function';
export const SHARED_LIBRARY_METADATA_MODULE_NAME = 'entry';
export const SHARED_LIBRARY_METADATA_VALUE = 16;
export const SHARED_LIBRARY_DIALOG_PARAMETER :  Record<string, Object> = {
  'ability.want.params.uiExtensionType': 'sys/commonUI',
  'sysDialogZOrder': 1,
  'packageName': 'com.ohos.settings'
};