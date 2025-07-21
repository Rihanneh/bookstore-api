export interface IPasswordHasher {
  hash(password: string): Promise<string>;
  verify(hashPassword: string, password: string): Promise<boolean>;
}
