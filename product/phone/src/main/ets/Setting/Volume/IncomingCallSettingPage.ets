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

import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SelectContactsComponent } from './view/SelectContactsComponent';
import { ContactsPolicyComponent } from './view/ContactsPolicyComponent';
import { RepeatCallController } from './controller/RepeatCallController';
import { IncomingCallUtils } from './utils/IncomingCallUtils';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

@Builder
function contactPolicyGroupBuilder(item: object) {
  ContactsPolicyComponent();
}

@Builder
function selectContactBuilder(item: object) {
  SelectContactsComponent();
}

const REPEAT_TIME: string = '15';

// 免打扰来电界面
function incomingCallPage(): SettingPageModel {
  return {
    id: 'IncomingCall',
    url: NavEntryKey.INCOMING_CALL_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.not_disturb_call'),
    layout: {
      padding: { top: PADDING_0 }
    },
    groups: [
      {
        id: 'allow_contacts_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        header: {
          id: 'allow_contacts_header',
          content: $r('app.string.allow_contacts'),
        },
        builder: wrapBuilder(contactPolicyGroupBuilder),
      },
      {
        id: 'select_contacts_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        visible: false,
        builder: wrapBuilder(selectContactBuilder),
      },
      {
        id: 'repeat_ringing_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        footer: {
          id: 'repeat_ringing_footer',
          content: ResourceUtil.getNumberFormatStringSync($r('app.string.repeat_call_will_ring_normally'), REPEAT_TIME),
          visible: IncomingCallUtils.getInstance().isShowRepeatCall(),
        },
        visible: IncomingCallUtils.getInstance().isShowRepeatCall(),
        compControl: new RepeatCallController(),
      }
    ]
  }
}

PageLoader.load(NavEntryKey.INCOMING_CALL_ENTRY, {
  configGenerator: incomingCallPage,
});
