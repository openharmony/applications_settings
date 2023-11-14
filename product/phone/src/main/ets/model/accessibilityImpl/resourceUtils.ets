/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

export class ResourceUtils {
  /**
   *  同步返回字符串string值
   *
   * */
  static getStringSync(resource: ResourceStr | undefined): string {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let context = getContext() as common.UIAbilityContext;
    if (!context.resourceManager) {
      return '';
    }
    return context.resourceManager.getStringSync(resource);
  }

  /**
   *  同步返回大写字符串string值
   *
   * */
  static getCapitalStringSync(resource: ResourceStr): string {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource.toUpperCase();
    }
    let result = ResourceUtils.getStringSync(resource);
    return result?.toUpperCase();
  }

  /**
   *  同步返回单复数大写字符串string值
   *
   * */
  static getPluralStringValueSync(resource: Resource, num: number): string {
    if (!resource) {
      return '';
    }
    try {
      let context = getContext() as common.UIAbilityContext;
      return context.resourceManager.getPluralStringValueSync(resource, num).toUpperCase();
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      LogUtil.error(`getPluralStringValueSync failed,error code: ${code}, message:${message}.`);
      return '';
    }
  }
}