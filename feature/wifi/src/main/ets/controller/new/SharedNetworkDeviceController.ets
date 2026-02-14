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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';

export class SharedNetworkDeviceController implements ComponentControl {
  public tag: string = 'SharedNetworkDeviceController: ';
  public compId?: string;
  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId || !compParam?.component) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} init, compId: ${compParam?.compId}, ${compParam?.component?.id}`);
    this.compId = compParam?.compId;
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
  }
}