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
import {
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SuggestionCardManager } from '../manager/SuggestionCardManager';
/* instrument ignore file */
const TAG = 'HomePageSuggestionController';

export class HomePageSuggestionController implements ComponentControl {
  private firstShow: boolean = false;

  init(param?: object | undefined): void {
    LogUtil.info(`${TAG} init.`);
    this.firstShow = true;
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow.`);
    // 首次进入不需要刷新，以免左右分栏数据不一致
    if (this.firstShow) {
      this.firstShow = false;
      return;
    }
    SuggestionCardManager.getInstance().refreshData(getContext());
  }

  destroy(): void {
    LogUtil.info(`${TAG} MoreCardPageControl destory`);
  }
}
