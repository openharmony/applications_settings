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
// import search from '@hms.ai.search';
import { Want } from '@kit.AbilityKit';

export interface ItemInfo {
  locale: string,
  itemName: string,
  itemTitle: string,
  itemDescription: string,
  entryKey: string,
  pageTitle: string,
  params: string,
  enable: boolean,
  icon: string,
  alias: string,
  childItems: string,
  path: string,
  bundleName: string,
  checkType: string,
  checkKey: string,
  checkValue: string
}

export interface SearchHistory {
  query: string,
  timestamp: number,
}


export interface ResultItemInfo {
  locale: string,
  title: string,
  entryKey: string,
  parentKey: string,
  path: string,
  icon: string,
  uriParams: string,
  itemName: string,
  bundleName: string,
  appName: string,
  appStatus: number,
  installSource: string,
  appIndex?: number,
  typeId?: number,
  shortcutId?: string,
  callbackType?: number,
  wantCallback?: string
}

export interface RenderItemChildrenInfo {
  title: string[],
  entryKey: string,
  path: string,
  parentKey: string,
  params: string,
  itemName: string,
  isApp?: boolean,
  isService?: boolean,
  appName?: string,
  appIndex?: number,
  isOuterApp?: boolean,
  bundleName?: string,
  abilityName?: string,
  want?: Want,
  installSource?: string
}

export interface RenderItemInfo {
  entryKey: string,
  children: RenderItemChildrenInfo[],
  isOuterApp: boolean,
  appName?: string,
}

/**
 * 隐藏菜单
 */
export interface HideMenu {
  key: string;
  desc: string;
  itemName: string[];
}
