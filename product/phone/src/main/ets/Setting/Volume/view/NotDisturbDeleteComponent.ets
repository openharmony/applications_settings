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
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StickBottomButton } from '@ohos/settings.uikit/src/main/ets/component/StickBottomButton';
import { NotDisturbDeleteController } from '../controller/NotDisturbDeleteController';

@Component
export struct NotDisturbDeleteComponent {
  public tag: string = 'NotDisturbDeleteComponent: ';
  item?: SettingGroupModel;
  compControl?: NotDisturbDeleteController;
  dialogControllerConfirm?: CustomDialogController;

  build() {
    StickBottomButton({
      params: {
        text: $r('app.string.timer_delete'),
        clickFunc:  () => {
          this.dialogControllerConfirm?.open();
        }
      }
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    let groupModel: SettingGroupModel = this.item as SettingGroupModel;
    this.compControl = groupModel.compControl as NotDisturbDeleteController;
    this.compControl?.init({ compId: groupModel.id, component: groupModel });
    this.dialogControllerConfirm = new CustomDialogController({
      autoCancel: false,
      builder: AlertDialog({
        primaryTitle: $r('app.string.timer_delete_confirm'),
        content: $r('app.string.timer_reset'),
        primaryButton: {
          value: $r('app.string.timer_cancel'),
          action: () => {
          },
        },
        secondaryButton: {
          value: $r('app.string.timer_delete'),
          role: ButtonRole.ERROR,
          action: () => {
            this.compControl?.onDialogClick();
          }
        },
      }),
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.dialogControllerConfirm?.close();
    this.dialogControllerConfirm = undefined;
    this.compControl?.destroy();
  }
}

