import { RoleEnum } from '@/constants/enums/RoleEnum';
import { BaseEntity } from '@/entities/BaseEntity';
import { IRoleData } from '@/interfaces/entities/user/IRoleData';

export class Role extends BaseEntity {
  private readonly name: RoleEnum;

  constructor(data: IRoleData) {
    super(data);
    this.name = data.name;
  }

  public getName(): RoleEnum {
    return this.name;
  }

  // Méthodes métier simples

  public isAdmin(): boolean {
    return this.name === RoleEnum.ADMIN;
  }

  public isCustomer(): boolean {
    return this.name === RoleEnum.CUSTOMER;
  }
}
