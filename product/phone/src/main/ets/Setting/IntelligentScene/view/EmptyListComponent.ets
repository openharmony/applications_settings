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

/* instrument ignore file */
const TAG: string = 'EmptyListComponent : ';

@Component
export struct EmptyListComponent {
  @State isEmpty: boolean = false;
  @State selectedIndex: number = 0;
  @Link loadDataComplete: boolean;
  private appListEmptyCallBack = (isEmpty: boolean, index: number) => {
    this.isEmpty = isEmpty;
    // 0 表示应用、1表示元服务
    this.selectedIndex = index;
  };

  build() {
    Column() {
      Image(this.selectedIndex === 0 ? $r('app.media.search_no_result') : $r('app.media.empty_service'))
        .width('120vp')
        .height('120vp')
        .draggable(false)
      Text(this.selectedIndex === 0 ? $r('app.string.no_application') : $r('app.string.empty_service'))
        .fontColor($r('sys.color.font_secondary'))
        .fontSize('14fp')
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .maxFontScale(2)
    }
    .justifyContent(FlexAlign.Center)
    .padding({
      bottom : 84,
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
    .width('100%')
    .height('100%')
    .visibility((this.isEmpty && this.loadDataComplete) ? Visibility.Visible : Visibility.None)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_EMPTY', this.appListEmptyCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_EMPTY', this.appListEmptyCallBack);
  }
}