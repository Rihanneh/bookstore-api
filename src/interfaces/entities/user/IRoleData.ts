import { RoleEnum } from '@/constants/enums/RoleEnum';
import { IBaseEntityData } from '@/interfaces/entities/IBaseEntityData';

export interface IRoleData extends IBaseEntityData {
  name: RoleEnum;
}
