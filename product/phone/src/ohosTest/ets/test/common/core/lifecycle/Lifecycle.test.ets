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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  PageLifecycleOwner,
  DialogLifecycleOwner,
  DialogSelfLifecycleObserver,
  DialogLifecycleObserver,
  LifecycleObserver,
  LifecycleObserverInterface,
  PageLifecycleObserver,
} from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { Constant } from '../../../constant/Constant';

const MENU_KEY: string = 'test_menu';

export default function LifecycleTest() {
  describe('LifecycleTest', () => {
    let pageLifecycleOwner = new PageLifecycleOwner();

    let dialogLifecycleOwner = new DialogLifecycleOwner();

    let lifecycleObserver = LifecycleObserver;

    let pageLifecycleObserver = PageLifecycleObserver;

    let dialogLifecycleObserver = DialogLifecycleObserver;

    let dialogSelfLifecycleObserver = DialogSelfLifecycleObserver;

    /*
    * @tc.number: LifecycleTest_001
    * @tc.name: 页的弹框取消回调
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('LifecycleTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} LifecycleTest_001 start`);
      let pageLifecycleOwner = new PageLifecycleOwner();
      let onDialogCancel = pageLifecycleOwner.onDialogCancel();
      expect(onDialogCancel !== null).assertTrue();
      let onDialogOpen = pageLifecycleOwner.onDialogOpen();
      expect(onDialogOpen !== null).assertTrue();
      let onDialogClose = pageLifecycleOwner.onDialogClose();
      expect(onDialogClose !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} LifecycleTest_001 end`);
    });

    /*
    * @tc.number: LifecycleTest_002
    * @tc.name: removeObserver
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('LifecycleTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} LifecycleTest_002 start`);
      let dialogLifecycleOwner = new DialogLifecycleOwner();
      let removeObserver = dialogLifecycleOwner.removeObserver(MENU_KEY);
      expect(removeObserver !== null).assertTrue();
      let onSelfOpen = dialogLifecycleOwner.onSelfOpen();
      expect(onSelfOpen !== null).assertTrue();
      let onSelfClose = dialogLifecycleOwner.onSelfClose();
      expect(onSelfClose !== null).assertTrue();
      let onSelfCancel = dialogLifecycleOwner.onSelfCancel();
      expect(onSelfCancel !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} LifecycleTest_002 end`);
    });

    /*
    * @tc.number: LifecycleTest_003
    * @tc.name: removeObserver
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('LifecycleTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} LifecycleTest_003 start`);
      let isDialogSelfLifecycleObserver = DialogSelfLifecycleObserver.isDialogSelfLifecycleObserver('');
      expect(isDialogSelfLifecycleObserver !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} LifecycleTest_003 end`);
    });

    it('LifecycleTest_addObserver', 0, () => {
      let observer: LifecycleObserverInterface = {
        getObserverKey: (): string => {
          return 'test'
        }
      } as LifecycleObserverInterface;
      pageLifecycleOwner.addObserver(observer);
    });

    it('LifecycleTest_removeObserver', 0, () => {
      pageLifecycleOwner.removeObserver(MENU_KEY)
    });

    it('LifecycleTest_onPageShow', 0, () => {
      pageLifecycleOwner.onPageShow()
    });

    it('LifecycleTest_onPageHide', 0, () => {
      pageLifecycleOwner.onPageHide()
    });

    it('LifecycleTest_onDialogCancel', 0, () => {
      pageLifecycleOwner.onDialogCancel(MENU_KEY)
    });

    it('LifecycleTest_onDialogOpen', 0, () => {
      pageLifecycleOwner.onDialogOpen(MENU_KEY)
    });

  });
}