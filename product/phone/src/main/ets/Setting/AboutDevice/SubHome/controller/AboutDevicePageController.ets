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
import { curves } from '@kit.ArkUI';
import { ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl,
  SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { IAboutDevicePageCtrl } from '@ohos/settings.aboutdevice/src/main/ets/controller/IAboutDevicePageCtrl';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE,
  EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW
} from '@ohos/settings.aboutdevice/src/main/ets/const/AboutDeviceConst';
import { AboutDevicePageModel, LogoImageMenuContainerStyle } from '../model/AboutDevicePageModel';

const SPRING_CURVE = curves.interpolatingSpring(0, 1, 439, 48);
const TIME_MS_1000 = 1000;
const TIME_MS_383 = 383;
const TIME_MS_100 = 100;

/**
 * 关于页面Controller
 *
 * @since 2024-06-22
 */
export class AboutDevicePageController implements ComponentControl, IAboutDevicePageCtrl {
  public tag: string = 'AboutDevicePageController : ';
  private pageModel?: AboutDevicePageModel;
  private isInAboutDevicePage: boolean = true;

  init(compParam: CompCtrlParam): void {
    if (!this.pageModel) {
      return;
    }
    this.pageModel?.init();
    let pageInfo: SettingPageModel = this.pageModel.aboutDevicePage;
    if (!pageInfo.groups) {
      LogUtil.showInfo(this.tag, 'Init failed, page group is empty');
      return;
    }

    let groupLen: number = pageInfo.groups.length;
    for (let groupIndex: number = 0; groupIndex < groupLen; groupIndex++) {
      const group: SettingGroupModel = pageInfo.groups[groupIndex];
      if (!group.items) {
        continue;
      }
      for (let itemIndex: number = 0; itemIndex < group.items.length; itemIndex++) {
        const item: SettingItemModel = group.items[itemIndex];
        if (PreferencesUtil.hasSync(item.id)) {
          item.enabled = !PreferencesUtil.getSync(item.id, true) as boolean;
          LogUtil.showInfo(this.tag, `disable item:${item.id}, enabled: ${item.enabled}`);
        }
      }
    }
  }

  onPageShow(component: SettingBaseModel): void {
    EventBus.getInstance().emit(EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW);
  }

  onPageHide(component: SettingBaseModel): void {
    EventBus.getInstance().emit(EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE);
  }

  destroy(): void {
  }

  public setPageModel(pageModel: AboutDevicePageModel): void {
    this.pageModel = pageModel;
  }

  /**
   * 当前页其他Controller的数据变化回调
   *
   * @param fromKey 消息发送的Controller的Key
   * @param data 消息内容
   */
  publishDataChange(fromKey: string, data: Object): void {
    if (data === null || data === undefined || !this.pageModel) {
      return;
    }
    if (fromKey !== 'about_device_ouc_card') {
      LogUtil.error(`${this.tag} illegal fromKey:${fromKey}`);
      return;
    }
  }
}