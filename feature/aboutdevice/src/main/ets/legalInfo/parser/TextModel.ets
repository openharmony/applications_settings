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

import Want from '@ohos.app.ability.Want';

/**
 * 文本基类
 */
export class BaseText {
  /**
   * 文本字串
   */
  private mText: string = '';

  /**
   * 构造函数
   * @param text 文本字串
   */
  constructor(text: string) {
    this.mText = text;
  }

  /**
   * 获取文本字串
   */
  getText(): string {
    return this.mText;
  }

  /**
   * 设置文本字串
   * @param text 文本字串
   */
  setText(text: string): void {
    this.mText = text;
  }
}

/**
 * 普通文本
 */
export class NormalText extends BaseText {
  constructor(text: string) {
    super(text);
  }
}

/**
 * 加粗文本
 */
export class BoldText extends BaseText {
  /**
   * 构造函数
   * @param text 文本字串
   */
  constructor(text: string) {
    super(text);
  }
}

/**
 * 跳转链接
 */
export class LinkText extends BaseText {
  /**
   * 跳转want对象
   */
  private mWant?: Want;

  /**
   * 构造函数
   * @param text 文本字串
   */
  constructor(text: string) {
    super(text);
  }

  /**
   * 获取跳转want对象
   */
  getWant(): Want | undefined {
    return this.mWant;
  }

  /**
   * 设置跳转want对象
   */
  setWant(want: Want | undefined): void {
    this.mWant = want;
  }
}
