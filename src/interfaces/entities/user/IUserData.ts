import { IBaseEntityData } from '../IBaseEntityData';

export interface IUserData extends IBaseEntityData {
  email: string;
  username: string;
  role: Role;
  hashedPassword: string;
  isActive: boolean;
  emailVerified: boolean;
}
