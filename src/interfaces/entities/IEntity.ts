export interface IEntity {
  getId(): string | number;
  getCreatedAt(): Date;
  getUpdatedAt(): Date;
}
