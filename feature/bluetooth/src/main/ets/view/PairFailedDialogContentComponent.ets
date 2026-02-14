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
import { BluetoothItemModel } from '../model/BluetoothItemModel';

@Component
export struct PairFailedDialogContentComponent {
  tag: string = 'PairFailedDialogContentComponent: ';
  item?: SettingItemModel;
  content: ResourceStr = '';

  build() {
    Scroll() {
      Column() {
        Text(this.content)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
      }
      .id('PairFailedDialogContentComponent_column')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .scrollBar(BarState.Auto)
    .align(Alignment.TopStart)
    .edgeEffect(EdgeEffect.Spring)
    .constraintSize({
      maxHeight: '65%'
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8')
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    let bluetoothItemModel: BluetoothItemModel = this.item as BluetoothItemModel
    if (!bluetoothItemModel) {
      LogUtil.info(`${this.tag} get pair fail content fail: bluetoothItemModel is invalid`);
      return;
    }

    this.content = BluetoothUtils.getPairFailedMessage(bluetoothItemModel.title?.content as string,
      bluetoothItemModel.pairErrCode as number);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
  }
}