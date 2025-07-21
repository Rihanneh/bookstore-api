import { IUserData } from '@/interfaces/entities/user/IUserData';
import { BaseEntity } from './BaseEntity';
import { Role } from './Role';

export class User extends BaseEntity {
  private email: string;
  private username: string;
  private readonly role: Role;
  #hashedPassword: string;
  private isActive: boolean;
  private emailVerified: boolean;

  constructor(data: IUserData) {
    super(data);
    this.email = data.email;
    this.username = data.username;
    this.role = data.role;
    this.#hashedPassword = data.hashedPassword;
    this.isActive = data.isActive ?? false;
    this.emailVerified = data.emailVerified ?? false;
  }

   // Getters/accesseur essentiels uniquement
  public getEmail(): string {
    return this.email;
  }

  public getUsername(): string {
    return this.username;
  }

  public getRole(): Role {
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

  // Méthodes métier utiles

  public canLogin(): boolean {
    return this.isActive && this.emailVerified;
  }

  public isAdmin(): boolean {
    return this.role.isAdmin();
  }

  public isCustomer(): boolean {
    return this.role.isCustomer();
  }
}
