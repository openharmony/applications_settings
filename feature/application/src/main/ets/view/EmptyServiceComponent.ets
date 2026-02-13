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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ApplicationController } from '../controller/ApplicationController';

const TAG: string = 'EmptyServiceComponent : ';

@Component
export struct EmptyServiceComponent {
  @State isEmpty: boolean = false;
  private controller: ApplicationController = new ApplicationController();

  build() {
    Column() {
      Column() {
        Image($r('app.media.empty_service'))
          .width('120vp')
          .height('120vp')
          .draggable(false)
        Text($r('app.string.empty_service'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize('14fp')
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .visibility(this.isEmpty ? Visibility.Visible : Visibility.None)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.controller.init();
    EventBus.getInstance().on('EVENT_ID_SERVICE_EMPTY', this.serviceEmptyEventCb);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller.destroy();
    EventBus.getInstance().detach('EVENT_ID_SERVICE_EMPTY', this.serviceEmptyEventCb);
  }

  private serviceEmptyEventCb = (isEmpty: boolean) => {
    LogUtil.info(`${TAG} serviceEmpty : ${isEmpty}`);
    this.isEmpty = isEmpty;
  };
}