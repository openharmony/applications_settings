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
import router from '@system.router';

export default {
    props: {
        //Title name
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
    back() {
        console.info('setting headComponent back start');
        this.$emit('backType', {});
        console.info('setting headComponent back end');
    },
    backChangeBackground() {
        console.info('setting headComponent backChangeBackground start');
        this.buttonStyles = 'app-bar-image-change-background'
        console.info('setting headComponent backChangeBackground end');
    },
    backRouter() {
        console.info('setting headComponent backRouter start');
        router.back();
        console.info('setting headComponent backRouter end');
    }
}

