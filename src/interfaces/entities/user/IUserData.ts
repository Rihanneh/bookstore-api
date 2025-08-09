import { RoleEnum } from '@/constants/enums/RoleEnum';
import { IBaseEntityData } from '../IBaseEntityData';

export interface IUserData extends IBaseEntityData {
  email: string;
  username: string;
  role: RoleEnum;
  hashedPassword: string;
  isActive: boolean;
  emailVerified: boolean;
  lastLoginAt: Date | undefined;
}
