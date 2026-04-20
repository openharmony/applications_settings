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
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';

export default function LanguageUtilsTest() {
  describe('LanguageUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    getLanguage();
    getRegion();
    isChinaArea();
  })
}

function getLanguage() {
  it('LanguageUtilsTest_getLanguage', 0, () => {
    let res = LanguageUtils.getLanguage();
    expect(res).not().assertNull();
  });
}

function getRegion() {
  it('LanguageUtilsTest_getRegion', 0, () => {
    let res = LanguageUtils.getRegion();
    expect(res).not().assertNull();
  });
}

function isChinaArea() {
  it('LanguageUtilsTest_isChinaArea', 0, () => {
    let res = LanguageUtils.isChinaArea();
    expect(res).not().assertNull();
  });
}