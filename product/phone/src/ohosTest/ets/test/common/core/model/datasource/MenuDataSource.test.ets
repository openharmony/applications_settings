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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { MenuDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/MenuDataSource';
import { SettingsBaseMenu } from '@ohos/settings.common';
import { Constant } from '../../../../constant/Constant';

const MENU_KEY: string = 'test_menu';

export default function MenuDataSourceTest() {
  let menuDataSource = new MenuDataSource([]);

  describe('MenuDataSourceTest', () => {

    /*
    * @tc.number: MenuDataSourceTest_001
    * @tc.name: 用于显示菜单列表的懒加载数据源
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */

    it('test_getData_return', 0, (): void => {
      let resA = menuDataSource.getData(0);
      expect(resA === null).assertTrue();
      let mDataSourceObj:SettingsBaseMenu  = new SettingsBaseMenu({
        key: MENU_KEY,
      });
      for(let i=0; i<2; i++){
        menuDataSource.mDataSource.push(mDataSourceObj);
      }
      let resB = menuDataSource.getData(0);
      expect(resB !== null).assertTrue();

    })

  });
}