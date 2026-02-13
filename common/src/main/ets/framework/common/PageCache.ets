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

import HashMap from '@ohos.util.HashMap';
import { Optional } from './Optional';
import { DataVerify } from './DataVerify';
import { SettingBaseModel } from '../model/SettingBaseModel';
import { LogHelper } from './LogHelper';

const TAG: string = 'PageCache';

export class PageCache {
  private static cacheMap: HashMap<string, SettingBaseModel> = new HashMap();

  public static set(compId: string, data: SettingBaseModel): Optional<SettingBaseModel> {
    if (!DataVerify.checkStr(compId) || !data || !data.cached) {
      LogHelper.error(TAG, `set invaild cache config, id: ${compId}`);
      return Optional.empty();
    }

    let comp = PageCache.cacheMap.get(compId);
    if (!comp) {
      PageCache.cacheMap.set(compId, data);
      return Optional.of(data);
    } else {
      return Optional.of(comp);
    }
  }

  public static get(compId: string): Optional<SettingBaseModel> {
    return Optional.ofNullable(PageCache.cacheMap.get(compId));
  }
}