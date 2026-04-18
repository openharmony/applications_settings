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
import { ComponentControl} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { VolumeStateInfo } from '../model/VolumeType';
import { VolumeUtils } from '../utils/VolumeUtils';

const TAG = 'VolumeController :';

export class VolumeController implements ComponentControl {
  public stateInfo: VolumeStateInfo = new VolumeStateInfo();

  /*
   * 框架组件控制器初始化接口，在组件aboutToAppear中被调用
   */
  init(): void {
    LogUtil.info(`${TAG} init`);
  }

  /*
   * 框架组件控制器销毁接口，在组件aboutToDisappear中被调用
   */
  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }
}

export class ToggleMenuController {
  private tag: string = 'ToggleMenuController';
  public isChecked: boolean = true;

  protected setChecked(isChecked: boolean): void {
    LogUtil.showInfo(this.tag, `setChecked ${isChecked}`);
    if (this.isChecked !== isChecked) {
      this.isChecked = isChecked;
      LogUtil.showInfo(this.tag, `setChecked, refresh: ${this.isChecked}`);
      this.refreshUi();
    }
  }

  protected refreshUi(): void {
  }
}