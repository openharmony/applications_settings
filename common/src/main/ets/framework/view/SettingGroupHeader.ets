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

import { EventBus } from '../common/EventBus';
import { LogHelper } from '../common/LogHelper';
import { PageConfig } from '../common/PageConfig';
import { SettingContentTextStyle, SettingGroupModel } from '../model/SettingGroupModel';
import {
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingStateType
} from '../model/SettingStateModel';
import { SettingGroupEventHandler, SettingGroupVM } from './SettingGroupVM';

const TAG: string = 'SettingGroupHeader';

@Component
export struct SettingGroupHeader {
  group: SettingGroupModel = { type: 0, id: '' };
  compId: string = '';
  fixedPreviousGroup: boolean = false;
  private style: SettingContentTextStyle = {};
  @State headerTitle: ResourceStr = '';
  @State groupVM: SettingGroupVM = new SettingGroupVM();
  private eventHandler: SettingGroupEventHandler = new SettingGroupEventHandler(this.groupVM);
  private eventCb = (data: object) => {
    if (!(data instanceof Map)) {
      LogHelper.error(TAG, 'invaild eventbus data type.');
    }
    this.procEvent(data as Map<SettingStateType, SettingBaseState>);
  };

  private getHeigth(cfgHeigth: number): number {
    return this.fixedPreviousGroup ? (cfgHeigth - 16) : cfgHeigth;
  }

  private procEvent(data: Map<SettingStateType, SettingBaseState>): void {
    data.forEach((value: SettingBaseState, key: SettingStateType) => {
      if (!value) {
        return;
      }

      switch (key) {
        case SettingStateType.STATE_TYPE_GROUP_HEADER_TITLE:
          this.procTitleEvent(value);
          break;
        case SettingStateType.STATE_TYPE_GROUP_HEADER_VISIBLE:
          this.procVisibleChange(value as SettingCompState);
          break;
        default:
          LogHelper.error(TAG, `invaild event data key: ${key}`);
          break;
      }
    })
  }

  private procTitleEvent(value: SettingBaseState): void {
    let titleContent = value as SettingContentState;
    if (!titleContent?.content) {
      LogHelper.error(TAG, 'invaild title state event');
      return;
    }

    LogHelper.info(TAG, 'enabled state change');
    this.headerTitle = titleContent.content;
  }

  private procVisibleChange(value: SettingCompState): void {
    if (this.groupVM) {
      LogHelper.info(TAG, `${this.compId} visible change from ${this.groupVM.visible} to ${value.state}`);
      this.groupVM.visible = value.state;
    }
  }

  aboutToAppear(): void {
    this.eventHandler.init(this.group, this.compId);
    this.style = PageConfig.getInstance().getGroupHeaderStyle(this.group.header);
    this.headerTitle = this.group.header?.content ?? '';
    EventBus.getInstance().on(this.compId, this.eventCb);
    LogHelper.info(TAG, `group header ${this.compId} appear, visible: ${this.groupVM.visible}.`);
  }

  aboutToDisappear(): void {
    LogHelper.info(TAG, `group header ${this.compId} disappear.`);
    EventBus.getInstance().detach(this.compId, this.eventCb);
    this.eventHandler.destroy();
  }

  build() {
    if (this.group.header) {
      Column() {
        if (this.group.header.builder) {
          this.group.header.builder.builder(this.group.header);
        } else {
          Text(this.headerTitle)
            .width('100%')
            .fontSize(this.style.fontSize)
            .fontWeight(this.style.fontWeight)
            .fontColor(this.style.fontColor)
            .fontFamily(this.style.fontFamily)
            .textAlign(this.style.textAlign)
            .opacity(this.style.opacity)
            .accessibilityDescription($r('app.string.title'))
        }
      }
      .width('100%')
      .constraintSize({ minHeight: this.getHeigth(this.style.height as number) })
      .padding(this.style.padding)
      .justifyContent(FlexAlign.End)
      .visibility(this.groupVM.visible ? Visibility.Visible : Visibility.None)
    }
  }
}