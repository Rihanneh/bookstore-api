import { RoleEnum } from '@/constants/enums/RoleEnum';
import { IEntity } from '../IEntity';

export interface IUser extends IEntity {
  getEmail(): string;
  getUsername(): string;
  getRole(): RoleEnum;
  getHashedPassword(): string;
  getIsActive(): boolean;
  getEmailVerified(): boolean;
  getLastLoginAt(): Date | undefined;
  canLogin(): boolean;
  isAdmin(): boolean;
  isCustomer(): boolean;
  setLastLoginAt(date: Date): IUser;
}
