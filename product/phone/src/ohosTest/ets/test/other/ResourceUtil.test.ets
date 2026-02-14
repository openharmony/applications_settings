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

import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';


export default function resourceUtilTest() {
  describe('resourceUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('getString_null', 0, async () => {
      let res = await ResourceUtil.getCapitalString('');
      expect(res).assertEqual('');
    });

    it('getWindowsStringSyncTest', 0, () => {
      let str: string = 'abc';
      let newStr = ResourceUtil.getWindowsStringSync(str);
      expect(newStr).assertEqual(str);
    })

    it('getSystemLanguageTest', 0, () => {
      let language: string = ResourceUtil.getSystemLanguage();
      expect(language).assertEqual('zh-Hans');
    })

    it('getCapitalStringSyncTest', 0, () => {
      let result1 = ResourceUtil.getCapitalStringSync('');
      expect(result1).assertEqual('');

      let result2 = ResourceUtil.getCapitalStringSync('ABC');
      expect(result2).assertEqual('ABC');

    })
    it('getStringTest', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit()
      let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getContext)
      when(mockFunc)(ArgumentMatchers.any).afterReturnNothing()
      let res: Resource = $r('app.string.TestAbility_desc')
      let str = ResourceUtil.getString(res)
      expect(await str === '').assertTrue()
      mocker.clear(ResourceUtil)
      done()
    })
    it('getNumberFormatStringTest', 0, async (done: Function) => {
      let strRes: Resource = $r('app.string.TestAbility_desc')
      mockGetStringValue(strRes,
        async () => {
          let str = ResourceUtil.getNumberFormatString(strRes,'es')
          expect(await str).assertEqual('')
        },
        async () => {
          let resStr = ResourceUtil.getNumberFormatString(strRes,'es')
          expect(await resStr).assertEqual('the test ability')
          done()
        },
      )
    })
    it('getNumberFormatStringSyncTest', 0, () => {
      let mocker: MockKit = new MockKit()
      let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringSync)
      when(mockFunc)(ArgumentMatchers.any).afterReturnNothing()
      let strRes: Resource = $r('app.string.TestAbility_desc')
      let str = ResourceUtil.getNumberFormatStringSync(strRes,'es')
      expect(str).assertEqual('')
      when(mockFunc)(ArgumentMatchers.any).afterReturn('the test ability')
      str = ResourceUtil.getNumberFormatStringSync(strRes,'a')
      expect(str).assertEqual('the test ability')
      mocker.clear(ResourceUtil)
    })
    it('getNumberFormatStringByNameTest', 0, () => {
      let mocker: MockKit = new MockKit()
      let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getStringByName)
      when(mockFunc)(ArgumentMatchers.any).afterReturnNothing()
      let strRes = 'the test ability'
      let str = ResourceUtil.getNumberFormatStringByName(strRes,'a')
      expect(str).assertEqual('')
      when(mockFunc)(ArgumentMatchers.any).afterReturn(strRes)
      str = ResourceUtil.getNumberFormatStringByName(strRes,'a')
      expect(str).assertEqual('the test ability')
      mocker.clear(ResourceUtil)
    })
    it('getAnyFormatStringTest', 0, async (done: Function) => {
      let strRes: Resource = $r('app.string.TestAbility_desc')
      mockGetStringValue(strRes,
        async () => {
          let str = ResourceUtil.getAnyFormatString(strRes,'ab')
          expect(await str).assertEqual('')
        },
        async () => {
          let resStr = ResourceUtil.getAnyFormatString(strRes,'es')
          expect(await resStr).assertEqual('the test ability')
          done()
        },
      )
    })
    it('getAnyFormatStringTest_001', 0, async (done: Function) => {
      let strRes: Resource = $r('app.string.TestAbility_desc')
      mockGetStringValue(strRes,
        async () => {
          let str = ResourceUtil.getAnyStrFormatString(strRes,'ab')
          expect(await str).assertEqual('')
        },
        async () => {
          let resStr = ResourceUtil.getAnyStrFormatString(strRes,'es')
          expect(await resStr).assertEqual('the test ability')
          done()
        },
      )
    })
    it('getAnyFormatStringTest_002', 0, async (done: Function) => {
      let strRes: Resource = $r('app.string.TestAbility_desc')
      mockGetStringValue(strRes,
        async () => {
          let str = ResourceUtil.getAnyNumFormatString(strRes,12)
          expect(await str).assertEqual('')
        },
        async () => {
          let resStr = ResourceUtil.getAnyNumFormatString(strRes,123)
          expect(await resStr).assertEqual('the test ability')
          done()
        },
      )
    })
    it('getPixelMapTest', 0, () => {
      mockGetContextValue(
        async () => {
          expect(ResourceUtil.getPixelMap('icon')).assertUndefined()
        },
        async () => {
          expect(ResourceUtil.getPixelMap('icon') !== undefined).assertTrue()
        },
      )
    })
    it('getColorSyncTest', 0, () => {
      expect(ResourceUtil.getColorSync(undefined)).assertUndefined()
      let colorRes = $r('app.color.start_window_background')
      mockGetContextValue(
        async () => {
          expect(ResourceUtil.getColorSync(colorRes)).assertUndefined()
        },
        async () => {
          expect(ResourceUtil.getColorSync(colorRes) !== undefined).assertFalse()
        },
      )
    })
    it('getWindowsStringSyncTest2', 0, () => {
      expect(ResourceUtil.getWindowsStringSync(undefined)).assertEqual('')
      expect(ResourceUtil.getWindowsStringSync('12345')).assertEqual('12345')
      let strRes: Resource = $r('app.string.TestAbility_desc')
      mockGetContextValue(
        async () => {
          expect(ResourceUtil.getWindowsStringSync(strRes)).assertUndefined()
        },
        async () => {
          expect(ResourceUtil.getWindowsStringSync(strRes) !== undefined).assertTrue()
        },
      )
    })
    it('getCapitalStringSyncTest2', 0, () => {
      expect(ResourceUtil.getCapitalStringSync('')).assertEqual('')
      expect(ResourceUtil.getCapitalStringSync('abc12')).assertEqual('abc12')
      let strRes: Resource = $r('app.string.TestAbility_desc')
      expect(ResourceUtil.getCapitalStringSync(strRes) !== null).assertTrue()
    })
  })
}
// 对getString统一mock处理
function mockGetStringValue(resource: Resource,nullCallback?: () => void, valueCallback?: () => void) {
  let mocker: MockKit = new MockKit()
  let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getString)
  when(mockFunc)(ArgumentMatchers.any).afterReturnNothing
  nullCallback ? nullCallback() : undefined
  let context: Context = AppStorage.get<Context>('pageContext') as Context
  let manager = context.resourceManager
  let value = manager.getStringValue(resource) ?? ''
  when(mockFunc)(ArgumentMatchers.any).afterReturn(value)
  valueCallback ? valueCallback() : undefined
  mocker.clear(ResourceUtil)
}
// 对getString统一mock处理
function mockGetContextValue(nullCallback?: () => void, valueCallback?: () => void) {
  let mocker: MockKit = new MockKit()
  let mockFunc: Function = mocker.mockFunc(ResourceUtil, ResourceUtil.getContext)
  when(mockFunc)(ArgumentMatchers.any).afterReturnNothing
  nullCallback ? nullCallback() : undefined
  let context: Context = AppStorage.get<Context>('pageContext') as Context
  when(mockFunc)(ArgumentMatchers.any).afterReturn(context)
  valueCallback ? valueCallback() : undefined
  mocker.clear(ResourceUtil)
}

