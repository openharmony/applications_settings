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
export interface NotDisturbMenuEntryData {
  key: string;
  id: number;
  title: ResourceStr;
  subTitle?: ResourceStr;
  isSelected?: boolean;
  isEnabled?: boolean;
}

/**
 * 和界面刷新无关的字段
 */
class NotDisturbParentMenuEntry {
  public id: number = 0;
  public key: string = '';

  constructor(params: NotDisturbMenuEntryData) {
    this.id = params.id;
    this.key = params.key;
  }
}

/**
 * 用于界面刷新相关的字段
 */
@Observed
export class NotDisturbMenuEntry extends NotDisturbParentMenuEntry {
  public title: ResourceStr = '';
  public subTitle: ResourceStr = '';
  public isSelected: boolean = false;
  public isEnabled: boolean = true;

  constructor(params: NotDisturbMenuEntryData) {
    super(params);
    this.title = params.title;
    this.isSelected = params.isSelected ?? false;
    this.subTitle = params.subTitle ?? '';
    this.isEnabled = params.isEnabled ?? true;
  }
}