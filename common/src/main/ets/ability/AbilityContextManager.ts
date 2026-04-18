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

import type common from '@ohos.app.ability.common';
import type { Context } from '@ohos.abilityAccessCtrl';
import { LogUtil } from '../utils/LogUtil';

const TAG = 'AbilityContextManager : ';

/**
 * Ability Context管理类
 *
 * @since 2022-07-20
 */
export class AbilityContextManager {
  private contexts: Array<Context> = new Array();
  private stageContext: Context = undefined;
  private mainAbilityContext: Context = undefined;
  private extServiceContext: Context = undefined;
  private backgroundIntentContext: Context = undefined;
  private extensionIntentContext: Context = undefined;
  private subThreadContext: Context = undefined;
  private instantShareServiceAbilityContext: common.ServiceExtensionContext = undefined;

  static getInstance(): AbilityContextManager {
    if (globalThis.abilityContextManager == null) {
      globalThis.abilityContextManager = new AbilityContextManager();
    }
    return globalThis.abilityContextManager as AbilityContextManager;
  }

  private addAbilityContext(context: Context): void {
    this.contexts.push(context);
    AppStorage.setOrCreate('pageContext', this.getAbilityContext());
  }

  private removeAbilityContext(context: Context): void {
    for (let index = 0; index < this.contexts.length; index++) {
      let current = this.contexts[index];
      if (current === context) {
        this.contexts.splice(index, 1);
        break;
      }
    }
    AppStorage.setOrCreate('pageContext', this.getAbilityContext());
  }

  private getAbilityContext(): Context {
    if (this.contexts.length <= 0) {
      LogUtil.showWarn(TAG, 'context is empty');
      return null;
    }
    return this.contexts[this.contexts.length - 1];
  }

  /**
   * 添加Ability的Context
   *
   * @param context Ability的Context
   */
  static addContext(context: Context): void {
    AbilityContextManager.getInstance().addAbilityContext(context);
  }

  /**
   * 删除Ability的Context
   *
   * @param context Ability的Context
   */
  static removeContext(context: Context): void {
    AbilityContextManager.getInstance().removeAbilityContext(context);
  }

  /**
   * 获取Ability的Context
   */
  static getContext(): Context {
    return AbilityContextManager.getInstance().getAbilityContext();
  }

  static setStageContext(context: Context): void {
    AbilityContextManager.getInstance().stageContext = context;
  }

  static getStageContext(): Context {
    return AbilityContextManager.getInstance().stageContext;
  }

  static setMainAbilityContext(context: Context): void {
    AbilityContextManager.getInstance().mainAbilityContext = context;
  }

  static getMainAbilityContext(): Context {
    return AbilityContextManager.getInstance().mainAbilityContext;
  }

  static setExtContext(context: Context): void {
    AbilityContextManager.getInstance().extServiceContext = context;
  }

  static getExtContext(): Context {
    return AbilityContextManager.getInstance().extServiceContext;
  }

  /**
   * 设置意图Extension卡片context
   */
  static setExtensionIntentContext(context: Context): void {
    AbilityContextManager.getInstance().extensionIntentContext = context;
  }

  /**
   * 获取意图Extension卡片context
   */
  static getExtensionIntentContext(): Context {
    return AbilityContextManager.getInstance().extensionIntentContext;
  }

  static setBackgroundIntentContext(context: Context): void {
    AbilityContextManager.getInstance().backgroundIntentContext = context;
  }

  static getBackgroundIntentContext(): Context {
    return AbilityContextManager.getInstance().backgroundIntentContext;
  }

  static setSubThreadContext(context: Context): void {
    AbilityContextManager.getInstance().subThreadContext = context;
  }

  static getSubThreadContext(): Context {
    return AbilityContextManager.getInstance().subThreadContext;
  }

  static setInstantShareServiceAbilityContext(context: common.ServiceExtensionContext): void {
    AbilityContextManager.getInstance().instantShareServiceAbilityContext = context;
  }

  static getInstantShareServiceAbilityContext(): common.ServiceExtensionContext {
    return AbilityContextManager.getInstance().instantShareServiceAbilityContext;
  }

  static tryKillBackgroundAbility(): void {
    let context: Context = AbilityContextManager.getInstance().backgroundIntentContext;
    if (context) {
      (context as common.UIAbilityContext)?.terminateSelf();
    }
  }
}
