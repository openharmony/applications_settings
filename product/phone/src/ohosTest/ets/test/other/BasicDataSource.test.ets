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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { BasicDataSource } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/model/BasicDataSource';

export default function basicDataSourceTest() {
  describe('basicDataSourceTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('BasicDataSourceTest_totalCount', 0, () => {
      let basicDataSource = new BasicDataSource();
      let num = 0;
      let totalnum = basicDataSource.totalCount();
      expect(num).assertEqual(totalnum);
    })

    it('BasicDataSourceTest_getData', 0, () => {
      let basicDataSource = new BasicDataSource();
      let num = 0;
      let getdate = basicDataSource.getData(num);
      expect(getdate).assertEqual(null);
    })


  })
}

