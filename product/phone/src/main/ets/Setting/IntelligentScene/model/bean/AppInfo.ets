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
export class AppInfo {
  public isSelected?: boolean;
  public name: string = '';
  public label?: string;
  public icon?: ResourceStr | PixelMap;
  public appIndex: number = 0;
  public uid?: number = 0;
  public prefix?: string;
  public pinyin?: string;
  public appInfo?: BasicAppEntry;
}

export class BasicAppEntry {
  public name: string = '';
  public codePath: string = '';
  public uid: number = 0;
  public bundleType: number = 0;
  public systemApp: boolean = false;
}

/**
 * 应用条件数据
 */
export interface AppCondition {
  enable: boolean;
  appConditionList: AppData[];
}

/**
 * 应用元服务数据
 */
export interface AppData {
  bundleName: string;
  index: number;
  uid?: number;
  isInstalled?: boolean;
  appType?: string;
}