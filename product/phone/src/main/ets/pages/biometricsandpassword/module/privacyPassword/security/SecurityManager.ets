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

const TAG: string = 'SecurityManager: ';

/**
 * SecurityManager
 *
 * @since 2024-04-22
 */
export default class SecurityManager {
  private static instance: SecurityManager = new SecurityManager();
  private token: Uint8Array | null = null;
  private challenge: Uint8Array | null = null;
  private password: string | null = null;
  private oldPassword: string | null = null;
  private assetAuthToken: Uint8Array | null = null;

  static getInstance(): SecurityManager {
    return SecurityManager.instance;
  }

  /**
   * 设置密码
   *
   * @param password value
   */
  public setPassword(password: string): void {
    this.password = password;
  }

  /**
   * 获取密码
   *
   * @returns value
   */
  public getPassword(): string {
    return this.password as string;
  }

  /**
   * 设置challenge
   *
   * @param challenge value
   */
  public setChallenge(challenge: Uint8Array): void {
    this.challenge = challenge;
  }

  /**
   * 获取challenge
   *
   * @returns value
   */
  public getChallenge(): Uint8Array {
    return this.challenge as Uint8Array;
  }

  /**
   * 保存token
   *
   * @param token value
   */
  public setToken(token: Uint8Array): void {
    this.token = token;
  }

  /**
   * 获取token
   *
   * @returns value
   */
  public getToken(): Uint8Array {
    return this.token as Uint8Array;
  }

  /**
   * 设置老密码
   *
   * @param password value
   */
  public setOldPassword(password: string): void {
    this.oldPassword = password;
  }

  /**
   * 获取老密码
   *
   * @returns value
   */
  public getOldPassword(): string {
    return this.oldPassword as string;
  }

  public clearCredential(): void {
    this.password = null;
    this.oldPassword = null;
  }
}