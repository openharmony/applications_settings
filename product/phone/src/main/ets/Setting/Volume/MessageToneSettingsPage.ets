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

import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { MessageToneComponent } from './view/MessageToneComponent';

@Component
export struct MessagingToneSettings {
  tag: string = 'MessagingToneSettings';
  title: string = ResourceUtil.getStringSync($r('app.string.ring_tone_settings_message'));

  build() {
    NavDestination() {
      Column() {
        MessageToneComponent()
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.comp_background_gray'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }

  onPageShow(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_MESSAGE_RINGTONE);
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, true);
    LogUtil.info(`${this.tag} onPageShow`);
  }

  onPageHide(): void {
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_RINGTONE_PAGE_STATE_CHANGE, false);
    LogUtil.info(`${this.tag} onPageHide`);
  }
}

@Builder function messageToneSettingsBuilder(item: object) {
  MessagingToneSettings();
}

function messageTonePage(): SettingPageModel {
  return {
    id: 'message_tone_settings_page',
    url: NavEntryKey.MESSAGING_TONE_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: $r('app.string.ring_tone_settings_message'),
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.MESSAGING_TONE_ENTRY, {
  configGenerator: messageTonePage,
  pageBuilder: wrapBuilder(messageToneSettingsBuilder),
});
