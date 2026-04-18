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
import {
  ComponentControl,
  CompCtrlParam,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType, } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AppListInfo } from '../model/SettingAppItemModel';
import { DefaultMailUtil } from '../util/DefaultMailUtil';
/* instrument ignore file */
const TAG = 'EmailRadioController: ';

/*
 * 默认邮件单选框controller
 */
export class EmailRadioController implements ComponentControl {
  private checkedMailInfo?: AppListInfo;
  private checkedCompId: string = '';

  init(param: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.checkedCompId = param.compId;
  }

  onPageShow(component: SettingBaseModel): void {
  }

  onPageHide(component: SettingBaseModel): void {
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  public initValue(groupId: string, mailInfo: AppListInfo): void {
    LogUtil.info(`${TAG} constructor, ${mailInfo.bundleName}`);
    this.checkedMailInfo = mailInfo;
    this.checkedCompId = `${groupId}.${mailInfo.bundleName}`;
    this.setItemChecked(`${this.checkedCompId}`, true);
  }

  /*
   * 组件事件响应 (用户主动触发 视图已经修改 无需refreshUi)
   */
  public onChange(groupId: string, mailInfo: AppListInfo, isCheck: boolean): void {
    LogUtil.info(`${TAG} onChange. ${mailInfo.bundleName}`);
    if (isCheck) {
      // 将原先选中的取消掉
      if (this.checkedMailInfo?.bundleName !== mailInfo.bundleName) {
        this.setItemChecked(`${this.checkedCompId}`, false);
      }
      this.checkedCompId = `${groupId}.${mailInfo.bundleName}`;
      this.onRadioChecked(mailInfo as AppListInfo, true);
    }
  }

  private async onRadioChecked(mailInfo: AppListInfo, isCheck: boolean): Promise<void> {
    let bundleName: string = mailInfo.bundleName as string;
    LogUtil.info(`${TAG} onItemClick ${bundleName} ${isCheck}`);
    await DefaultMailUtil.setDefaultMail(bundleName);
    this.checkedMailInfo = mailInfo;
    EventBus.getInstance().emit('DEFAULT_MAIL_APP_SELECT', bundleName);
    // 上报设置的默认邮箱事件及对应包名
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.SET_DEFAULT_EMAIL, bundleName);
  }

  private setItemChecked(compId: string, checked: boolean): void {
    LogUtil.info(`${TAG} refreshUi. compId:${compId} checked:${checked}`);
    const result: SettingResultState = { type: ItemResultType.RESULT_TYPE_RADIO, result: { checked } };
    notifyCompStateChange(compId, new Map<SettingStateType, SettingResultState>([
      [SettingStateType.STATE_TYPE_ITEM_RESULT, result],
    ]));
  }
}