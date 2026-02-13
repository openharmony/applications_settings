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

import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemType, ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import {
  CellIdController,
  MobileNetworkTypeController,
  OperatorNameController,
  SignalStrengthController,
  SmsCenterNumberController,
  MccMncController
} from '../conroller/NetworkController';

const isEflForbidden: boolean = SystemParamUtil.isEflForbidden();

export class NetworkInfoModel {
  public isEFB: boolean = isEflForbidden;
  public simCardOneGroup: SettingGroupModel[] = [
    {
      id: 'newtork_information_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'network_information_name_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.network_information') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new OperatorNameController(),
        },
        {
          id: 'signal_strength_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.signal_strength') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new SignalStrengthController(),
        },
        {
          id: 'mobile_network_type_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.mobile_network_type') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new MobileNetworkTypeController(),
          needHide: () => isEflForbidden,
        },
        {
          id: 'mcc_mnc_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.mcc_mnc') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new MccMncController(),
        },
        {
          id: 'cell_id_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.cell_id') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new CellIdController(),
          needHide: () => isEflForbidden,
        },
        {
          id: 'sms_center_number_simOne',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.sms_center_number') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new SmsCenterNumberController(),
        },
      ]
    },
  ];

  public simCardTwoGroup: SettingGroupModel[] = [
    {
      id: 'newtork_information_group',
      type: GroupType.GROUP_TYPE_STANDARD,
      items: [
        {
          id: 'network_information_name_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.network_information') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new OperatorNameController(),
        },
        {
          id: 'signal_strength_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.signal_strength') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new SignalStrengthController(),
        },
        {
          id: 'mobile_network_type_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.mobile_network_type') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new MobileNetworkTypeController(),
          needHide: () => isEflForbidden,
        },
        {
          id: 'mcc_mnc_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.mcc_mnc') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new MccMncController(),
        },
        {
          id: 'cell_id_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.cell_id') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new CellIdController(),
          needHide: () => isEflForbidden,
        },
        {
          id: 'sms_center_number_simTwo',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.sms_center_number') },
          result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
          compControl: new SmsCenterNumberController(),
        },
      ]
    },
  ];
}

