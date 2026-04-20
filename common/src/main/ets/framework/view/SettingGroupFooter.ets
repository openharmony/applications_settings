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

import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { SettingContentTextStyle, SettingGroupModel } from '../model/SettingGroupModel';
import { SettingGroupFooterEventHandler, SettingGroupVM } from './SettingGroupVM';

const TAG: string = 'SettingGroupFooter';

@Component
export struct SettingGroupFooter {
  group: SettingGroupModel = { type: 0, id: '' };
  compId: string = '';
  private style: SettingContentTextStyle = {};
  @State groupVM: SettingGroupVM = new SettingGroupVM();
  private eventHandler: SettingGroupFooterEventHandler = new SettingGroupFooterEventHandler(this.groupVM);

  aboutToAppear(): void {
    this.style = PageConfig.getInstance().getGroupFooterStyle(this.group.footer);
    LogHelper.info(TAG, `group footer ${this.compId} appear.`);
    this.eventHandler.init(this.group, this.compId);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `group footer ${this.compId} disappear.`);
    this.eventHandler.destroy();
  }

  build() {
    if (this.group.footer) {
      Column() {
        if (this.group.footer.builder) {
          this.group.footer.builder.builder(this.group.footer);
        } else {
          Text(this.group.footer.content)
            .width('100%')
            .fontSize(this.style.fontSize)
            .fontWeight(this.style.fontWeight)
            .fontColor(this.style.fontColor)
            .fontFamily(this.style.fontFamily)
            .textAlign(this.style.textAlign)
            .opacity(this.style.opacity)
        }
      }
      .width('100%')
      .padding(this.style.padding)
      .visibility(this.groupVM.visible ? Visibility.Visible : Visibility.None)
    }
  }
}