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
import Router from '@system.router';
import LogUtil from '../../../common/baseUtil/LogUtil.js';

let mLogUtil = null;

export default {
    props: {
        titleName: {
            default: '',
        },
        backIcon: {},
        backIsShow: {
            default: true,
        },
        buttonStyles: {
            default: 'app-bar-image'
        },
    },

    onInit() {
        mLogUtil = new LogUtil();
    },

    back() {
        mLogUtil.info('setting headComponent back start');
        this.$emit('backType', {});
        mLogUtil.info('setting headComponent back end');
    },

    backChangeBackground() {
        mLogUtil.info('setting headComponent backChangeBackground start');
        this.buttonStyles = 'app-bar-image-change-background';
        mLogUtil.info('setting headComponent backChangeBackground end');
    },

    backRouter() {
        mLogUtil.info('setting headComponent backRouter start');
        Router.back();
        mLogUtil.info('setting headComponent backRouter end');
    }
};

