// src/entities/BaseEntity.ts
import { IBaseEntityData } from '@/interfaces/entities/IBaseEntityData';
import { IEntity } from '@/interfaces/entities/IEntity';

/**
 * Classe abstraite de base pour toutes les entités métier
 *
 * Fournit les fonctionnalités communes :
 * - Identifiant unique
 * - Timestamps de création/modification
 * - Mise à jour automatique des timestamps
 *
 * RGPD: Les timestamps permettent la traçabilité légale
 */
export abstract class BaseEntity implements IEntity {
  protected readonly id: string;
  protected readonly createdAt: Date;
  protected updatedAt: Date;

  constructor(data: IBaseEntityData) {
    this.id = data.id;
    this.createdAt = data.createdAt ?? new Date();
    this.updatedAt = data.updatedAt ?? new Date();
  }

  public getId(): string {
    return this.id;
  }

  public getCreatedAt(): Date {
    return this.createdAt;
  }

  public getUpdatedAt(): Date {
    return this.updatedAt;
  }

  protected updateTimestamp(): void {
    this.updatedAt = new Date();
  }
}
