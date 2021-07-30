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
import brightness from '@ohos.brightness';
import storage from '@ohos.data.storage';
import LogUtil from '../../common/baseUtil/LogUtil.js';

const PREFERENCES_PATH = '/data/accounts/account_0/appdata/com.ohos.settings/sharedPreference/SettingPreferences';
var brightnessPreferences = storage.getStorageSync(PREFERENCES_PATH);
let logUtil = new LogUtil();
const BRIGHTNESS_SAVE_VALUE = 'BrightnessSaveValue';
/**
 * brightness service class
 */
export default class BrightnessSettingModel extends BaseModel {
    setBrightnessListener(brightnessValue) {
        logUtil.log('setting setBrightnessListener BrightnessSettingModel start');
        brightness.setValue(brightnessValue);
        logUtil.log('setting setBrightnessListener BrightnessSettingModel end');
    }

    setStorageValue(brightnessValue) {
        logUtil.log('setting setBrightnessListener setStorageListener start brightnessValue:' + brightnessValue);
        brightnessPreferences.putSync(BRIGHTNESS_SAVE_VALUE, brightnessValue);
        brightnessPreferences.flushSync();
        logUtil.log('setting setBrightnessListener setStorageListener end');
    }

    getStorageValue() {
        logUtil.log('setting setBrightnessListener getStorageValue start');
        return brightnessPreferences.getSync(BRIGHTNESS_SAVE_VALUE, 0);
    }
}