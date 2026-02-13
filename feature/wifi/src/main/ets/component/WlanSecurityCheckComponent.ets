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

import { taskpool } from '@kit.ArkTS';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { getSecurityStatement } from '../WifiSecurityCheckUtils';

export const PRIVACY_CENTER_BUNDLE_NAME: string = 'com.ohos.security.privacycenter';

export const PRIVACY_STATEMENT_HYPERLINK: string = 'wlan_privacy_statement_hyperlink';

export const PRIVACY_STATEMENT_SHORT_NOTICE: string = 'wlan_privacy_statement_short_notice_in_settings';

const TAG: string = 'WlanSecurityCheckComponent: ';
const SLICE_LENGTH: number = 3;
const SECURITY_FOOT_TEXT_DELAY: number = 300;

/**
 * wlan 安全检查
 *
 * @since 2025-05-10
 */
@Component
export struct WlanSecurityCheckComponent {
  @State start: ResourceStr = '';
  @State middle: ResourceStr = '';
  @State end: ResourceStr = '';

  @Builder
  contentBuilder(): void {
    Text() {
      Span(this.start).spanBodyStyle()
      Span(this.middle).spanClickStyle().onClick(() => {
        this.onEntryClick()
      })
      Span(this.end).spanBodyStyle()
    }.lineHeight('app.float.font_14')
    .textAlign(LanguageUtils.isLtrDirection() ? TextAlign.JUSTIFY : TextAlign.Start)
  }

  build() {
    Column() {
      this.contentBuilder()
    }.size({ width: '100%' })
  }

  private onEntryClick(): void {
    PageRouter.push(NavEntryKey.WLAN_PRIVACY_STATEMENT);
  }

  private async getStatement(): Promise<void> {
    try {
      let task = new taskpool.Task(getSecurityStatement, AbilityContextManager.getStageContext());
      let res = await taskpool.execute(task, taskpool.Priority.MEDIUM);
      let strList: string[] = res as string[];
      let statementShortNotice = strList[0];
      let statementHyperlink = strList[1];
      /* instrument ignore if*/
      if (StringUtil.isEmpty(statementShortNotice) || StringUtil.isEmpty(statementHyperlink) ||
        statementShortNotice?.length <= SLICE_LENGTH) {
        LogUtil.error(`${TAG} getStatement notice or hyperlink invalid`);
        return;
      }
      const noticeStrList = statementShortNotice.split('%s');
      /* instrument ignore if*/
      if (!noticeStrList[0] || !noticeStrList[1]) {
        LogUtil.error(`${TAG} getStatement notice content invalid`);
        return;
      }
      this.start = noticeStrList[0];
      this.middle = statementHyperlink;
      this.end = noticeStrList[1];
    } catch (err) {
      LogUtil.error(`${TAG} getStatement, msg: ${err?.message}, code: ${err.code}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    setTimeout(() => {
      this.getStatement();
    }, SECURITY_FOOT_TEXT_DELAY);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}

@Extend(Span)
function spanBodyStyle() {
  .font({
    size: $r('sys.float.Body_S'),
    weight: FontWeight.Regular,
  })
  .fontFamily('HarmonyHeiTi')
  .fontColor($r('sys.color.font_secondary'))
}

@Extend(Span)
function spanClickStyle() {
  .font({
    size: $r('sys.float.Body_S'),
    weight: FontWeight.Medium,
  })
  .fontColor($r('sys.color.font_emphasize'))
  .fontFamily('HarmonyHeiTi')
}
