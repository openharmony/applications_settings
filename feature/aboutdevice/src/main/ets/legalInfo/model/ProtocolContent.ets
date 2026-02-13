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

import Want from '@ohos.application.Want';

/**
 * 参数
 */
export class Param {
  public name: string;
  public value: string;

  constructor(name: string, value: string) {
    this.name = name;
    this.value = value;
  }
}

/**
 * Ability
 */
export class Ability {
  public key: string = '';
  public value: Want;

  constructor(key: string, value: Want) {
    this.key = key;
    this.value = value;
  }
}


/**
 * ProtocolContent
 */
export class ProtocolContent {
  public serviceName?: string;
  public packageName?: string;
  public moduleName?: string;
  public serviceType?: string;
  public version: string = '';
  public title: string = '';
  public content: string = '';
  public params: Param[] = [];
  public abilities: Ability[] = [];
}