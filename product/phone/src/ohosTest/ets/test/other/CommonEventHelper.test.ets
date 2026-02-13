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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { CommonEventHelper } from '@ohos/settings.common';
import { AsyncCallback, BusinessError, commonEventManager } from '@kit.BasicServicesKit';

export default function CommonEventHelperTest() {
  describe('CommonEventHelperTest', () => {
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {} as commonEventManager.CommonEventSubscribeInfo;
    let subscribeCallBack: AsyncCallback<commonEventManager.CommonEventData> =
      {} as AsyncCallback<commonEventManager.CommonEventData>;
    let commonEventHelper = new CommonEventHelper(subscribeInfo, subscribeCallBack);

    it('CommonEventHelperTest_01', 0, (done: Function) => {
      try {
        let result = commonEventHelper.registerCommonEvent();
        expect(result === null).assertFalse();

        (commonEventHelper as object)['isRegister'] = true;
        let result2 = commonEventHelper.registerCommonEvent();
        expect(result2 === null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('CommonEventHelperTest_02', 0, (done: Function) => {
      try {
        (commonEventHelper as object)['isRegister'] = false;
        let result = commonEventHelper.unRegisterCommonEvent();
        expect(result === null).assertFalse();
        (commonEventHelper as object)['isRegister'] = true;
        let result2 = commonEventHelper.unRegisterCommonEvent();
        expect(result2 === null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('CommonEventHelperTest_03', 0, (done: Function) => {
      try {
        let err: BusinessError = {
          code: -1,
          name: '',
          message: ''
        };
        (commonEventHelper as object)['unsubscribeCallBack'](err);
        let err2: BusinessError = {
          name: '',
          message: '',
          code: 0
        };
        (commonEventHelper as object)['unsubscribeCallBack'](err2);
      } catch (e) {
      } finally {
        done()
      }
    })

    it('CommonEventHelperTest_04', 0, (done: Function) => {
      try {
        let err: BusinessError = {
          code: -1,
          name: '',
          message: ''
        };
        (commonEventHelper as object)['createSubscriberCallBack'](err);

        let err2: BusinessError = {
          name: '',
          message: '',
          code: 0
        };
        (commonEventHelper as object)['createSubscriberCallBack'](err2);
      } catch (e) {
      } finally {
        done()
      }
    })

  })
}