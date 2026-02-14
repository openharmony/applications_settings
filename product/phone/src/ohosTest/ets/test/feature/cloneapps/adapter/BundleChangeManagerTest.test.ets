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
  BundleChangeListener,
  BundleChangeManager } from '@ohos/settings.cloneapps/src/main/ets/adapter/BundleChangeManager';
import { commonEventManager } from '@kit.BasicServicesKit';

class parListener implements BundleChangeListener {
  public name: string = '';
  getListenerName(): string {
    if (this.name === '') {
      this.name = Math.random().toString();
    }
    return this.name;
  }
  onBundleAdd(bundleName: string, userId: number, index: number): void {

  }
  onBundleUpdate(bundleName: string, userId: number): void {

  }
  onBundleRemove(bundleName: string, userId: number, index: number): void {

  }
}
let item: BundleChangeListener = new parListener();
let arr: BundleChangeListener[] = [];
arr.push(item);
export default function BundleChangeManagerTest() {
  let bundleChange = BundleChangeManager.getInstance();
  describe('BundleChangeManagerTest', () => {
    let listener: parListener =
      AppStorage.get<parListener>('null') as parListener;

    it('test_getInstance', 0, (): void => {
      let resA = BundleChangeManager.getInstance();
      let resB = BundleChangeManager.getInstance();
      expect(resA === resB).assertTrue();
    })

    it('test_dispatchBundleAdd', 0, (): void => {
      bundleChange.listeners = arr;
      let resA: Object = (bundleChange as object)['dispatchBundleAdd']('com.detting', 1, 1);
      expect(resA === null).assertFalse();
    })

    it('test_dispatchBundleUpdate', 0, (): void => {
      bundleChange.listeners = arr;
      let resA: Object = (bundleChange as object)['dispatchBundleUpdate']('com.detting', 1);
      expect(resA === null).assertFalse();
    })
    it('test_dispatchBundleRemove', 0, (): void => {
      bundleChange.listeners = arr;
      let resA: Object = (bundleChange as object)['dispatchBundleRemove']('com.detting', 1, 1);
      expect(resA === null).assertFalse();
    })
    it('test_registerStatusChange', 0, (): void => {
      bundleChange.isRegister = false;
      let resA: Object = (bundleChange as object)['registerStatusChange']();
      expect(resA === null).assertFalse();
      bundleChange.isRegister = true;
      let resB: Object = (bundleChange as object)['registerStatusChange']();
      expect(resB === null).assertFalse();
    })

    it('test_dispatchEventMsg', 0, (): void => {
      bundleChange.subscriber = null;
      let resA: Object = (bundleChange as object)['dispatchEventMsg']();
      expect(resA === null).assertFalse();
    })

    it('test_dispatchMsg', 0, (): void => {
      let data: commonEventManager.CommonEventData = {
        event: 'usual.event.PACKAGE_ADDED'
      }
      let resA: Object = (bundleChange as object)['dispatchMsg'](data);
      expect(resA === null).assertFalse();
      data = {
        event: 'usual.event.PACKAGE_REMOVED'
      }
      let resB: Object = (bundleChange as object)['dispatchMsg'](data);
      expect(resB === null).assertFalse();
      data = {
        event: 'usual.event.PACKAGE_CHANGED'
      }
      let resC: Object = (bundleChange as object)['dispatchMsg'](data);
      expect(resC === null).assertFalse();
      data = {
        event: ''
      }
      let resD: Object = (bundleChange as object)['dispatchMsg'](data);
      expect(resD === null).assertFalse();
    })

    it('test_unRegisterStatusChange', 0, (): void => {
      bundleChange.isRegister = false;
      let resA: Object = (bundleChange as object)['unRegisterStatusChange']();
      expect(resA === null).assertFalse();
      bundleChange.isRegister = true;
      bundleChange.subscriber = null;
      let resB: Object = (bundleChange as object)['unRegisterStatusChange']();
      expect(resB === null).assertFalse();
      bundleChange.subscriber = null;
    })

    it('test_registerBundleChangedListener', 0, (): void => {
      listener =
        AppStorage.get<parListener>('null') as parListener;
      let resA = bundleChange.registerBundleChangedListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let arr: BundleChangeListener[] = [];
      (bundleChange as object)["listeners"] = arr;
      let resB = bundleChange.registerBundleChangedListener(listener);
      expect(resB === null).assertFalse();
      let item2: BundleChangeListener = new parListener();
      arr.push(item);
      arr.push(item2);
      (bundleChange as object)["listeners"] = arr;
      let resC = bundleChange.registerBundleChangedListener(listener);
      expect(resC === null).assertFalse();
    })

    it('test_unRegisterBundleChangedListener', 0, (): void => {
      listener =
        AppStorage.get<parListener>('null') as parListener;
      let resA = bundleChange.unRegisterBundleChangedListener(listener);
      expect(resA === null).assertFalse();
      listener = new parListener();
      let arr: BundleChangeListener[] = [];
      (bundleChange as object)["listeners"] = arr;
      let resB = bundleChange.unRegisterBundleChangedListener(listener);
      expect(resB === null).assertFalse();
      let item2: BundleChangeListener = new parListener();
      arr.push(item);
      arr.push(item2);
      (bundleChange as object)["listeners"] = arr;
      let resC = bundleChange.unRegisterBundleChangedListener(listener);
      expect(resC === null).assertFalse();
    })

  });
}
