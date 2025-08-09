import { User } from '@/entities/User';
import { IUserData } from '@/interfaces/entities/user/IUserData';
import { IUserRepository } from '@/interfaces/repositories/IUserRepository';

export class MockUserRepository implements IUserRepository {
  private users: User[] = [];
  private currentId: number = 1;

  async findById(id: string): Promise<User | null> {
    return this.users.find((u: User): boolean => u.getId() === id) || null;
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.users.find((u: User): boolean => u.getEmail() === email) || null;
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.users.find((u: User): boolean => u.getUsername() === username) || null;
  }

  async create(data: IUserData): Promise<User> {
    const idIncrement: number = this.currentId++;
    const user = new User({
      ...data,
      id: idIncrement.toString(),
      createdAt: new Date(),
      updatedAt: new Date()
    });
    this.users.push(user);
    return user;
  }

  // ... autres méthodes CRUD
}
