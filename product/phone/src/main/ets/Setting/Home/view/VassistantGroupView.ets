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
import emitter from '@ohos.events.emitter';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { EVENT_ID_HOME_APP_STATE_CHANGED } from '@ohos/settings.common/src/main/ets/event/types';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PADDING_4, PADDING_48, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HomePageMenuManager } from '../controller/HomePageMenuManager';

const TAG = 'VassistantGroupView';

@Component
export struct VassistantGroupView {
  itemInd?: number;
  @State isGroupVisible: boolean = true;
  @State isDividerVisible: boolean = true;

  build() {
    if (this.isGroupVisible) {
      Column() {
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .padding({ start: PADDING_4, end: PADDING_4, top: PADDING_4, bottom: PADDING_4 })
      .width('100%')
    }
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    let isAssistantNotSupport: boolean = HomePageMenuManager.getInstance().isAssistantNotSupport();
    this.isGroupVisible = !isAssistantNotSupport;
    this.isDividerVisible = !isAssistantNotSupport;

    emitter.on({
      eventId: EVENT_ID_HOME_APP_STATE_CHANGED,
    }, async (eventData: emitter.EventData) => {
      let isAssistantEnable: boolean =
        await AppManager.getInstance().getIsApplicationEnabled('com.ohos.vassistant', eventData?.data?.appIndex ?? 0);
      this.isGroupVisible = isAssistantEnable;
      this.isDividerVisible = isAssistantEnable;
    });
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    emitter.off(EVENT_ID_HOME_APP_STATE_CHANGED);
  }
}