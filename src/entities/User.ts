import { IUserData } from '@/interfaces/entities/user/IUserData';
import { BaseEntity } from './BaseEntity';
import { RoleEnum } from '@/constants/enums/RoleEnum';
import { IUser } from '@/interfaces/entities/user/IUser';

export class User extends BaseEntity {
  private email: string;
  private username: string;
  private role: RoleEnum;
  #hashedPassword: string;
  private isActive: boolean;
  private emailVerified: boolean;
  private lastLoginAt: Date | undefined;

  constructor(data: IUserData) {
    super(data);
    this.email = data.email;
    this.username = data.username;
    this.role = data.role;
    this.#hashedPassword = data.hashedPassword;
    this.isActive = data.isActive ?? false;
    this.emailVerified = data.emailVerified ?? false;
    this.lastLoginAt = data.lastLoginAt;
  }

  // Factory method pour création
  public static create(params: {
    email: string;
    username: string;
    hashedPassword: string;
    role?: RoleEnum;
    isActive?: boolean;
    emailVerified?: boolean;
  }): IUser {
    return new User({
      id: '', // Sera set par le repo ou base de données
      email: params.email,
      username: params.username,
      role: params.role ?? RoleEnum.CUSTOMER,
      hashedPassword: params.hashedPassword,
      isActive: params.isActive ?? false,
      emailVerified: params.emailVerified ?? false,
      lastLoginAt: undefined,
      createdAt: new Date(),
      updatedAt: new Date()
    });
  }

  // Getters/accesseur essentiels uniquement
  public getEmail(): string {
    return this.email;
  }

  public getUsername(): string {
    return this.username;
  }

  public getRole(): RoleEnum {
    return this.role;
  }

  public getHashedPassword(): string {
    return this.#hashedPassword;
  }
  public getIsActive(): boolean {
    return this.isActive;
  }
  public getEmailVerified(): boolean {
    return this.emailVerified;
  }
  public getLastLoginAt(): Date | undefined {
    return this.lastLoginAt;
  }

  // Setters/ mutateurs métier avec chaining
  public setEmail(email: string): this {
    this.email = email;
    this.updateTimestamp();
    return this;
  }

  public setUsername(username: string): this {
    this.username = username;
    this.updateTimestamp();
    return this;
  }

  public setRole(role: RoleEnum): this {
    this.role = role;
    this.updateTimestamp();
    return this;
  }

  public setHashedPassword(hashedPassword: string): this {
    this.#hashedPassword = hashedPassword;
    this.updateTimestamp();
    return this;
  }
  public setIsActive(isActive: boolean): this {
    this.isActive = isActive;
    this.updateTimestamp();
    return this;
  }
  public setEmailVerified(emailVerified: boolean): this {
    this.emailVerified = emailVerified;
    this.updateTimestamp();
    return this;
  }

  public setLastLoginAt(date: Date): IUser {
    this.lastLoginAt = date;
    this.updateTimestamp();
    return this;
  }

  // Méthodes métier utiles

  public canLogin(): boolean {
    return this.isActive && this.emailVerified;
  }

  public isAdmin(): boolean {
    return this.role === RoleEnum.ADMIN;
  }

  public isCustomer(): boolean {
    return this.role === RoleEnum.CUSTOMER;
  }
}
