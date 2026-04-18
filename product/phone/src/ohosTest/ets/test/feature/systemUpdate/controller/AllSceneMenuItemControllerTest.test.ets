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
import { describe, expect, it } from '@ohos/hypium';
import {
  AllSceneMenuItemController
} from '@ohos/settings.systemUpdate/src/main/ets/controller/AllSceneMenuItemController';
import { SettingItemModel, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AllSceneMenuItemView } from '@ohos/settings.systemUpdate/src/main/ets/view/AllSceneMenuItemView';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';

const allSceneMenuItem: SettingItemModel = {
  id: 'all_scene_ota_name',
  type: ItemType.ITEM_TYPE_CUSTOM,
  builder: wrapBuilder(allSceneMenuItemBuilder),
};
@Builder function allSceneMenuItemBuilder(item: object) {
  AllSceneMenuItemView({ item: item as SettingBaseModel});
}
class SettingBaseModelPar implements  SettingBaseModel {
  public id: string = '';
}

export default function AllSceneMenuItemControllerTest() {
  describe('AllSceneMenuItemControllerTest', () => {
    let allSceneMenu = AllSceneMenuItemController.getInstance();
    it('test_getInstance', 0, (): void => {
      let resA = AllSceneMenuItemController.getInstance();
      expect(resA === null).assertFalse();
      let resB = AllSceneMenuItemController.getInstance();
      expect(resB === null).assertFalse();
    })

    it('test_init', 0, (): void => {
      let SettingBaseModel: SettingBaseModelPar = new SettingBaseModelPar();
      let compParam: CompCtrlParam = {
        compId: '1',
        component: SettingBaseModel
      }
      let resA = allSceneMenu.init(compParam);
      expect(resA === null).assertFalse();
    })

    it('test_buildMenuContent', 0, (): void => {
      let resA: Object = (allSceneMenu as object)['buildMenuContent']();
      expect(resA === null).assertFalse();
    })

  });
}
