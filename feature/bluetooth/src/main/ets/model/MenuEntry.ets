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

export interface MenuEntryData {
  key: string;
  title: string;
  state?: boolean;
  icon?: ResourceStr | PixelMap;
  editIcon?: ResourceStr | PixelMap;
  subTitle?: ResourceStr;
  rssi: number;
  isConnect?: boolean;
  index?: number;
}

/**
 * 和界面刷新无关的字段
 */
class ParentMenuEntry {
  public key: string = '';
  public editIcon?: ResourceStr | PixelMap;
  public rssi: number = 0;
  public index?: number = 0;
  public icon?: ResourceStr | PixelMap;

  constructor(params: MenuEntryData) {
    this.key = params.key;
    this.icon = params.icon;
    this.editIcon = params.editIcon;
    this.rssi = params.rssi;
    this.index = params.index ?? 0;
  }
}

/**
 * 用于界面刷新相关的字段
 */
@Observed
export class MenuEntry extends ParentMenuEntry {
  public title: ResourceStr = '';
  public state?: boolean;
  public subTitle: ResourceStr = '';
  public isConnect?: boolean = false;

  constructor(params: MenuEntryData) {
    super(params);
    this.title = params.title;
    this.isConnect = params.isConnect ?? false;
    this.subTitle = params.subTitle ?? '';
  }
}