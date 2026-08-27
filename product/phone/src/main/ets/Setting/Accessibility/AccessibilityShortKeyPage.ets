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

import { PADDING_0, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  DEFAULT_TEXT_STYLE,
  FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT,
  TYPE_MODAL_SCREEN_HEIGHT_RATE,
  UX_DESIGN_SHEET_HEIGHT_PAD
} from './constant/Constants';
import { FunctionSelectPageController } from './controller/FunctionSelectPageController';
import { OperationSettingController } from './controller/OperationSettingController';
import { ShortKeyLockScreenController } from './controller/ShortKeyLockScreenController';
import { ShortKeySwitchController } from './controller/ShortKeySwitchController';
import { URL_FUNCTION_SELECT_LIST_PAGE } from './FunctionSelectListPage';
import { ShortKeyPageImageComponent } from './view/ShortKeyPageImageComponent';

/* instrument ignore file */
const TAG: string = 'operationSettingPage : ';

@Builder
function operationImageGroupBuilder(param: object): void {
  ShortKeyPageImageComponent();
}

function getContentGroupItems(shortKeySwitchController: ShortKeySwitchController,
  shortKeyLockScreenController: ShortKeyLockScreenController,
  functionSelectPageController: FunctionSelectPageController): SettingItemModel[] {
  return [
    {
      id: 'single_shortKey_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.accessibility_shortKey'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: true },
      },
      compControl: shortKeySwitchController,
    },
    {
      id: 'shortKey_lock_screen',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.shortKey_lock_screen'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: true },
      },
      compControl: shortKeyLockScreenController,
    },
    {
      id: 'function_select',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.function_select'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MODAL,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: URL_FUNCTION_SELECT_LIST_PAGE,
        sheetOptions: {
          height: FontScaleUtils.isExtraLargeFontMode() ? SheetSize.FIT_CONTENT :
            (DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
              DisplayUtils.getScreenHeight() * TYPE_MODAL_SCREEN_HEIGHT_RATE : UX_DESIGN_SHEET_HEIGHT_PAD),
          preferType: SheetType.CENTER,
          dragBar: false,
          maskColor: $r('sys.color.mask_fourth'),
          backgroundColor: $r('app.color.component_ultra_thick_panel'),
          showClose: false,
          onAppear: () => {
            LogUtil.info(`${TAG} function select model page onAppear.`);
            EventBus.getInstance().emit(FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT, true);
          },
          onWillDisappear: () => {
            LogUtil.info(`${TAG} function select model page Will onDisappear.`);
            EventBus.getInstance().emit(FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT, false);
          }
        },
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: DEFAULT_TEXT_STYLE
        },
      },
      compControl: functionSelectPageController,
    }
  ]
}

function operationSettingPage(): SettingPageModel {
  let operationSettingController: OperationSettingController = new OperationSettingController();
  let shortKeySwitchController: ShortKeySwitchController = new ShortKeySwitchController();
  let shortKeyLockScreenController: ShortKeyLockScreenController = new ShortKeyLockScreenController();
  let functionSelectPageController: FunctionSelectPageController = new FunctionSelectPageController();
  return {
    id: 'AccessibilityOperationSettings',
    url: NavEntryKey.ACCESSIBILITY_OPERATION_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.accessibility_shortKey'),
    hdsNavDestinationUx: false,
    compControl: {
      init: (compParam: CompCtrlParam) => {
        operationSettingController.init();
      },
      destroy: () => {
        operationSettingController.destroy();
      },
      onPageShow: (component: SettingBaseModel) => {
        operationSettingController.onPageShow();
        shortKeySwitchController.onPageShow();
        shortKeyLockScreenController.onPageShow();
        functionSelectPageController.onPageShow();
      },
      onPageHide: (component: SettingBaseModel) => {
        operationSettingController.onPageHide();
      }
    },
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    groups: [
      {
        id: 'operation_image_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(operationImageGroupBuilder),
      },
      {
        id: 'operation_content_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getContentGroupItems(shortKeySwitchController, shortKeyLockScreenController,
          functionSelectPageController),
        layout: {
          margin: {
            top: PADDING_24,
          },
        }
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_OPERATION_ENTRY, {
  configGenerator: operationSettingPage,
});