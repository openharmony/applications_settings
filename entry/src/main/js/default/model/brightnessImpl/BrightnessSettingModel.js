/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import BaseModel from '../BaseModel.js';
import Brightness from '@ohos.brightness';
import Storage from '@ohos.data.storage';
import LogUtil from '../../common/baseUtil/LogUtil.js';

const BRIGHTNESS_SAVE_VALUE = 'BrightnessSaveValue';
const PREFERENCES_PATH = '/data/accounts/account_0/appdata/com.ohos.settings/sharedPreference/SettingPreferences';

let mBrightnessPreferences = Storage.getStorageSync(PREFERENCES_PATH);
let mLogUtil = null;

/**
 * brightness service class
 */
export default class BrightnessSettingModel extends BaseModel {
    constructor() {
        super();
        mLogUtil = new LogUtil();
    }

    setBrightnessListener(brightnessValue) {
        mLogUtil.log('setting setBrightnessListener BrightnessSettingModel start');
        Brightness.setValue(brightnessValue);
        mLogUtil.log('setting setBrightnessListener BrightnessSettingModel end');
    }

    setStorageValue(brightnessValue) {
        mLogUtil.log('setting setBrightnessListener setStorageListener start brightnessValue:' + brightnessValue);
        mBrightnessPreferences.putSync(BRIGHTNESS_SAVE_VALUE, brightnessValue);
        mBrightnessPreferences.flushSync();
        mLogUtil.log('setting setBrightnessListener setStorageListener end');
    }

    getStorageValue() {
        mLogUtil.log('setting setBrightnessListener getStorageValue start');
        return mBrightnessPreferences.getSync(BRIGHTNESS_SAVE_VALUE, 0);
    }
}