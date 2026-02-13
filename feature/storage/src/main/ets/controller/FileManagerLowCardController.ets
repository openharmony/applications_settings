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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MAX_PROPORTION, } from '../constant/StorageConstant';
import { ControllerInfo } from '../model/CardInfo';
import { CommonCardController } from './CommonCardController';

//文管低内存
@Sendable
export class FileManagerLowCardController extends CommonCardController {
  constructor(controllerInfo: ControllerInfo, proportion: number) {
    super(controllerInfo, proportion);
    this.tag = 'FileManagerLowCardController';
  }

  isNeedShow(context: Context): boolean {
    LogUtil.info(`${this.tag} FileManagerLowCardController isNeedShow`);
    return this.proportion > MAX_PROPORTION;
  }
}