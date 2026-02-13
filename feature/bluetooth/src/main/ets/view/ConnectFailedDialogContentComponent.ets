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
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { BluetoothItemModel } from '../model/BluetoothItemModel';

const MESSAGE_REPLACE_INDEX_ONE: string = '1';
const MESSAGE_REPLACE_INDEX_TWO: string = '2';
const MESSAGE_REPLACE_INDEX_TEN: string = '10';

@Component
export struct ConnectFailedDialogContentComponent {
  tag: string = 'ConnectFailedDialogContentComponent: ';
  item?: SettingItemModel;
  content: ResourceStr = '';

  build() {
    Column() {
      Text(this.content)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
    }
    .id('ConnectFailedDialogContentComponent_column')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.content = this.initContent();
  }

  private initContent(): string {
    let bluetoothItemModel: BluetoothItemModel = this.item as BluetoothItemModel;
    LogUtil.info(`${this.tag} initContent`);
    if (!bluetoothItemModel) {
      LogUtil.info(`${this.tag} get connect fail content fail: bluetoothItemModel is invalid`);
      return '';
    }

    let replaceDeviceName: string = bluetoothItemModel.title?.content as string;
    let errorMessage: string = BluetoothUtils.getConnectFailedMessage(bluetoothItemModel.connectErrCode as number);
    LogUtil.info(`${this.tag} initContent, errorMessage: ${errorMessage}`);
    if (errorMessage === '') {
      errorMessage = ResourceUtil.getAnyStrFormatStringSync($r('app.string.bt_connect_failed_message'),
        replaceDeviceName, MESSAGE_REPLACE_INDEX_ONE, MESSAGE_REPLACE_INDEX_TEN, MESSAGE_REPLACE_INDEX_TWO);
    }
    LogUtil.info(`${this.tag} initContent, errorMessage return: ${errorMessage}`);

    return errorMessage;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}